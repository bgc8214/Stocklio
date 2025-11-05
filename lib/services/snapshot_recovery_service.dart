import 'package:flutter/foundation.dart';
import 'database_service.dart';
import 'yahoo_finance_service.dart';

/// 스냅샷 복구 서비스
/// 누락된 날짜의 스냅샷을 자동으로 채웁니다.
class SnapshotRecoveryService {
  final DatabaseService _db = DatabaseService();
  final YahooFinanceService _yahooFinance = YahooFinanceService();

  /// 마지막 스냅샷 이후 누락된 날짜 확인 및 복구
  Future<int> recoverMissingSnapshots() async {
    try {
      debugPrint('🔍 누락된 스냅샷 확인 중...');

      // 1. 마지막 스냅샷 날짜 조회
      final lastSnapshot = await _db.getLastSnapshot();

      if (lastSnapshot == null) {
        debugPrint('⚠️  스냅샷 기록이 없습니다.');
        return 0;
      }

      final lastDate = lastSnapshot['date'] as DateTime;
      final today = DateTime.now();

      // 2. 마지막 스냅샷부터 오늘까지의 날짜 목록 생성
      final missingDates = _getMissingDates(lastDate, today);

      if (missingDates.isEmpty) {
        debugPrint('✅ 누락된 스냅샷이 없습니다.');
        return 0;
      }

      debugPrint('📋 누락된 날짜 수: ${missingDates.length}');

      // 3. 각 누락 날짜에 대해 스냅샷 생성
      int recovered = 0;

      for (var date in missingDates) {
        try {
          // 휴장일 체크 (주말은 스킵)
          if (_isWeekend(date)) {
            debugPrint('  ⏭️  주말 스킵: ${_formatDate(date)}');
            continue;
          }

          // 해당 날짜의 스냅샷 생성
          final success = await _createSnapshotForDate(date);

          if (success) {
            recovered++;
            debugPrint('  ✅ 복구 완료: ${_formatDate(date)}');
          } else {
            debugPrint('  ⚠️  복구 실패: ${_formatDate(date)}');
          }

          // API 부담 줄이기
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          debugPrint('  ❌ ${_formatDate(date)} 복구 중 오류: $e');
        }
      }

      debugPrint('✅ 스냅샷 복구 완료: $recovered개 복구');
      return recovered;
    } catch (e) {
      debugPrint('❌ 스냅샷 복구 실패: $e');
      return 0;
    }
  }

  /// 특정 날짜의 스냅샷 생성
  Future<bool> _createSnapshotForDate(DateTime date) async {
    try {
      // 1. 포트폴리오 데이터 로드
      final portfolios = await _db.getPortfolio();

      if (portfolios.isEmpty) {
        return false;
      }

      // 2. 각 종목의 과거 가격 조회
      double totalValue = 0;
      double totalCost = 0;
      int successCount = 0;

      for (var portfolio in portfolios) {
        try {
          // 과거 특정 날짜의 종가 조회
          final historicalPrice = await _yahooFinance.getHistoricalPrice(
            portfolio.ticker,
            date,
          );

          if (historicalPrice != null && historicalPrice > 0) {
            totalValue += historicalPrice * portfolio.quantity;
            totalCost += portfolio.averagePrice * portfolio.quantity;
            successCount++;
          }
        } catch (e) {
          debugPrint('    ⚠️  ${portfolio.ticker} 가격 조회 실패');
        }
      }

      // 3. 최소 1개 이상 성공했을 때만 저장
      if (successCount == 0) {
        return false;
      }

      // 4. 전날 스냅샷 조회 (일일 수익 계산용)
      final yesterday = date.subtract(const Duration(days: 1));
      final yesterdayValue = await _db.getTotalValueByDate(yesterday);

      double dailyProfit = 0;
      if (yesterdayValue != null && yesterdayValue > 0) {
        dailyProfit = totalValue - yesterdayValue;
      }

      // 5. 스냅샷 저장
      await _db.insertDailySnapshot(
        date: date,
        totalValue: totalValue,
        totalCost: totalCost,
        dailyProfit: dailyProfit,
      );

      return true;
    } catch (e) {
      debugPrint('    ❌ 스냅샷 생성 실패: $e');
      return false;
    }
  }

  /// 마지막 스냅샷부터 오늘까지 누락된 날짜 목록 반환
  List<DateTime> _getMissingDates(DateTime lastDate, DateTime today) {
    final missingDates = <DateTime>[];
    var current = lastDate.add(const Duration(days: 1));

    while (current.isBefore(today) || _isSameDay(current, today)) {
      missingDates.add(current);
      current = current.add(const Duration(days: 1));
    }

    return missingDates;
  }

  /// 주말 여부 확인
  bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  /// 같은 날인지 확인
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
