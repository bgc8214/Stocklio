import 'package:flutter/foundation.dart';
import '../models/portfolio.dart';
import '../services/database_service.dart';
import '../services/yahoo_finance_service.dart';

class PortfolioProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final YahooFinanceService _yahooFinance = YahooFinanceService();

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

      // 각 종목의 현재가 업데이트
      await _updateCurrentPrices();

      // 당일 수익 계산
      await _calculateTodayProfit();
    } catch (e) {
      debugPrint('포트폴리오 로드 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 현재가 업데이트
  Future<void> _updateCurrentPrices() async {
    for (var portfolio in _portfolioList) {
      try {
        final currentPrice = await _yahooFinance.getCurrentPrice(portfolio.ticker);
        if (currentPrice != null) {
          portfolio.currentPrice = currentPrice;
          // 데이터베이스에 현재가 업데이트
          await _db.updatePortfolioCurrentPrice(portfolio.id!, currentPrice);
        }
      } catch (e) {
        debugPrint('${portfolio.ticker} 현재가 업데이트 실패: $e');
      }
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

  // 종목 추가
  Future<void> addPortfolio({
    required String ticker,
    required String stockName,
    required int quantity,
    required double averagePrice,
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
      );

      await _db.insertPortfolio(portfolio);
      await loadPortfolio();
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
