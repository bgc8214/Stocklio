import 'package:flutter/foundation.dart';
import '../models/portfolio.dart';
import '../services/database_service.dart';
import '../services/yahoo_finance_service.dart';
import '../services/snapshot_recovery_service.dart';

class PortfolioProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final YahooFinanceService _yahooFinance = YahooFinanceService();
  final SnapshotRecoveryService _recoveryService = SnapshotRecoveryService();

  List<Portfolio> _portfolioList = [];
  bool _isLoading = false;
  double _todayProfit = 0;
  double _todayProfitRate = 0;

  List<Portfolio> get portfolioList => _portfolioList;
  bool get isLoading => _isLoading;
  double get todayProfit => _todayProfit;
  double get todayProfitRate => _todayProfitRate;

  // 총 평가금액 계산
  double get totalMarketValue {
    return _portfolioList.fold(
      0,
      (sum, p) => sum + (p.currentPrice * p.quantity),
    );
  }

  // 총 투자금액 계산
  double get totalInvestment {
    return _portfolioList.fold(
      0,
      (sum, p) => sum + (p.averagePrice * p.quantity),
    );
  }

  // 포트폴리오 데이터 로드
  Future<void> loadPortfolio() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 데이터베이스에서 포트폴리오 로드
      _portfolioList = await _db.getPortfolio();

      // 포트폴리오가 있을 때만 가격 업데이트 및 스냅샷 저장
      if (_portfolioList.isNotEmpty) {
        // 누락된 스냅샷 복구 (백그라운드 실패 대응)
        await _recoverMissingSnapshots();

        // 각 종목의 현재가 업데이트
        await _updateCurrentPrices();

        // 당일 수익 계산
        await _calculateTodayProfit();

        // 당일 스냅샷 자동 저장 (하루에 한 번만)
        await _saveTodaySnapshotIfNeeded();
      }
    } catch (e) {
      debugPrint('포트폴리오 로드 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 누락된 스냅샷 복구
  Future<void> _recoverMissingSnapshots() async {
    try {
      final recovered = await _recoveryService.recoverMissingSnapshots();
      if (recovered > 0) {
        debugPrint('📝 누락 스냅샷 $recovered개 복구 완료');
      }
    } catch (e) {
      debugPrint('⚠️  스냅샷 복구 실패 (무시하고 계속): $e');
    }
  }

  // 당일 스냅샷이 없으면 저장
  Future<void> _saveTodaySnapshotIfNeeded() async {
    try {
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // 오늘 스냅샷이 이미 있는지 확인
      final existingSnapshot = await _db.getSnapshotByDate(todayStr);

      if (existingSnapshot == null) {
        // 없으면 새로 저장
        await saveDailySnapshot();
        debugPrint('✅ 당일 스냅샷 저장 완료: $todayStr');
      }
    } catch (e) {
      debugPrint('당일 스냅샷 확인/저장 실패: $e');
    }
  }

  // 현재가 업데이트 (병렬 처리로 성능 개선)
  Future<void> _updateCurrentPrices() async {
    try {
      // 모든 종목의 가격을 병렬로 조회
      final priceUpdates = await Future.wait(
        _portfolioList.map((portfolio) async {
          try {
            final currentPrice = await _yahooFinance.getCurrentPrice(portfolio.ticker);
            return {'portfolio': portfolio, 'price': currentPrice};
          } catch (e) {
            debugPrint('${portfolio.ticker} 현재가 조회 실패: $e');
            return {'portfolio': portfolio, 'price': null};
          }
        }),
      );

      // 조회된 가격을 업데이트
      for (var update in priceUpdates) {
        final portfolio = update['portfolio'] as Portfolio;
        final price = update['price'] as double?;

        if (price != null) {
          portfolio.currentPrice = price;
          // 데이터베이스에 현재가 업데이트
          await _db.updatePortfolioCurrentPrice(portfolio.id!, price);
        }
      }
    } catch (e) {
      debugPrint('현재가 일괄 업데이트 실패: $e');
    }
  }

  // 당일 수익 계산
  Future<void> _calculateTodayProfit() async {
    try {
      // 어제의 총 평가금액 가져오기
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayValue = await _db.getTotalValueByDate(yesterday);

      if (yesterdayValue != null && yesterdayValue > 0) {
        final todayValue = totalMarketValue;
        _todayProfit = todayValue - yesterdayValue;
        _todayProfitRate = (todayValue - yesterdayValue) / yesterdayValue * 100;
      } else {
        _todayProfit = 0;
        _todayProfitRate = 0;
      }
    } catch (e) {
      debugPrint('당일 수익 계산 실패: $e');
      _todayProfit = 0;
      _todayProfitRate = 0;
    }
  }

  // 종목 추가 (최적화: 전체 reload 대신 추가만)
  Future<void> addPortfolio({
    required String ticker,
    required String stockName,
    required int quantity,
    required double averagePrice,
    int? categoryId,
  }) async {
    try {
      // 현재가 조회
      double currentPrice = averagePrice;
      try {
        final price = await _yahooFinance.getCurrentPrice(ticker);
        if (price != null) {
          currentPrice = price;
        }
      } catch (e) {
        debugPrint('현재가 조회 실패, 평균 단가로 설정: $e');
      }

      final portfolio = Portfolio(
        ticker: ticker,
        name: stockName,
        quantity: quantity,
        averageCost: averagePrice,
        currentPrice: currentPrice,
        market: ticker.contains('.KS') || ticker.contains('.KQ') ? 'KRX' : 'US',
        categoryId: categoryId,
      );

      final insertedId = await _db.insertPortfolio(portfolio);

      // 전체 reload 대신 새 항목만 추가
      final portfolioWithId = portfolio.copyWith(id: insertedId);
      _portfolioList.add(portfolioWithId);

      // 당일 수익 재계산
      await _calculateTodayProfit();

      notifyListeners();
    } catch (e) {
      debugPrint('종목 추가 실패: $e');
      rethrow;
    }
  }

  // 종목 수정
  Future<void> updatePortfolio(
    int id,
    int quantity,
    double averagePrice,
  ) async {
    try {
      await _db.updatePortfolioQuantityAndPrice(id, quantity, averagePrice);
      await loadPortfolio();
    } catch (e) {
      debugPrint('종목 수정 실패: $e');
      rethrow;
    }
  }

  // 종목 삭제
  Future<void> deletePortfolio(int id) async {
    try {
      await _db.deletePortfolio(id);
      await loadPortfolio();
    } catch (e) {
      debugPrint('종목 삭제 실패: $e');
      rethrow;
    }
  }

  // 일일 스냅샷 저장
  Future<void> saveDailySnapshot() async {
    try {
      final totalValue = totalMarketValue;
      final totalCost = totalInvestment;
      final date = DateTime.now();

      await _db.insertDailySnapshot(
        date: date,
        totalValue: totalValue,
        totalCost: totalCost,
        dailyProfit: _todayProfit,
      );
    } catch (e) {
      debugPrint('일일 스냅샷 저장 실패: $e');
      rethrow;
    }
  }
}
