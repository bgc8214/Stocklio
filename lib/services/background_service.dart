import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'database_service.dart';
import 'yahoo_finance_service.dart';

/// 백그라운드 작업 태스크 이름
const String dailyUpdateTaskName = "dailyPortfolioUpdate";

/// 백그라운드 작업 실행 함수
/// 이 함수는 별도의 isolate에서 실행되므로 main 함수와 독립적입니다.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('🔄 백그라운드 작업 시작: $task');

    try {
      if (task == dailyUpdateTaskName) {
        await _performDailyUpdate();
        debugPrint('✅ 백그라운드 작업 완료');
        return Future.value(true);
      }
    } catch (e) {
      debugPrint('❌ 백그라운드 작업 실패: $e');
      return Future.value(false);
    }

    return Future.value(false);
  });
}

/// 일일 포트폴리오 업데이트 작업
Future<void> _performDailyUpdate() async {
  debugPrint('📊 일일 포트폴리오 업데이트 시작...');

  final db = DatabaseService();
  final yahooFinance = YahooFinanceService();

  try {
    // 1. 포트폴리오 데이터 로드
    final portfolios = await db.getPortfolio();

    if (portfolios.isEmpty) {
      debugPrint('⚠️  포트폴리오가 비어있습니다. 작업을 건너뜁니다.');
      return;
    }

    debugPrint('📦 포트폴리오 종목 수: ${portfolios.length}');

    // 2. 각 종목의 현재가 업데이트
    double totalValue = 0;
    double totalCost = 0;

    for (var portfolio in portfolios) {
      try {
        final priceData = await yahooFinance.getCurrentPrice(portfolio.ticker);

        if (priceData != null) {
          final currentPrice = priceData['currentPrice'] as double;

          // 데이터베이스에 현재가 업데이트
          await db.updatePortfolioCurrentPrice(portfolio.id!, currentPrice);

          // 평가금액 및 투자금액 누적
          totalValue += currentPrice * portfolio.quantity;
          totalCost += portfolio.averagePrice * portfolio.quantity;

          debugPrint('  ✓ ${portfolio.name} (${portfolio.ticker}): ${currentPrice.toStringAsFixed(2)}');
        }

        // API 부담 줄이기 위한 딜레이
        await Future.delayed(const Duration(milliseconds: 300));
      } catch (e) {
        debugPrint('  ✗ ${portfolio.ticker} 업데이트 실패: $e');
      }
    }

    // 3. 어제 스냅샷 데이터 가져오기 (일일 수익 계산용)
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayValue = await db.getTotalValueByDate(yesterday);

    double dailyProfit = 0;
    if (yesterdayValue != null && yesterdayValue > 0) {
      dailyProfit = totalValue - yesterdayValue;
    }

    // 4. 일일 스냅샷 저장
    final today = DateTime.now();
    await db.insertDailySnapshot(
      date: today,
      totalValue: totalValue,
      totalCost: totalCost,
      dailyProfit: dailyProfit,
    );

    debugPrint('💾 일일 스냅샷 저장 완료');
    debugPrint('  총 평가금액: ${totalValue.toStringAsFixed(0)}원');
    debugPrint('  총 투자금액: ${totalCost.toStringAsFixed(0)}원');
    debugPrint('  일일 수익: ${dailyProfit >= 0 ? '+' : ''}${dailyProfit.toStringAsFixed(0)}원');
  } catch (e) {
    debugPrint('❌ 일일 업데이트 중 오류 발생: $e');
    rethrow;
  }
}

/// 백그라운드 서비스 클래스
class BackgroundService {
  /// WorkManager 초기화
  static Future<void> initialize() async {
    debugPrint('🚀 백그라운드 서비스 초기화 중...');

    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false, // 프로덕션에서는 false로 설정
    );

    debugPrint('✅ 백그라운드 서비스 초기화 완료');
  }

  /// 일일 자동 업데이트 작업 등록
  /// 매일 새벽 6시(한국/미국 시장 모두 마감 후)에 실행되도록 설정
  static Future<void> registerDailyUpdate() async {
    debugPrint('📅 일일 자동 업데이트 작업 등록 중...');

    try {
      // 기존 작업이 있으면 취소
      await Workmanager().cancelByUniqueName(dailyUpdateTaskName);

      // 새로운 작업 등록
      // initialDelay: 앱 시작 후 최초 실행까지의 지연 시간
      // frequency: 반복 주기 (최소 15분)
      await Workmanager().registerPeriodicTask(
        dailyUpdateTaskName,
        dailyUpdateTaskName,
        frequency: const Duration(hours: 24), // 24시간마다 실행
        initialDelay: _calculateInitialDelay(), // 다음 오후 4시까지의 시간
        constraints: Constraints(
          networkType: NetworkType.connected, // 인터넷 연결 필요
          requiresCharging: false,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
      );

      debugPrint('✅ 일일 자동 업데이트 작업 등록 완료');
      debugPrint('   다음 실행: ${_getNextExecutionTime()}');
    } catch (e) {
      debugPrint('❌ 작업 등록 실패: $e');
      rethrow;
    }
  }

  /// 다음 새벽 6시까지의 지연 시간 계산
  static Duration _calculateInitialDelay() {
    final now = DateTime.now();
    var nextExecution = DateTime(now.year, now.month, now.day, 6, 0); // 오늘 새벽 6시

    // 이미 새벽 6시가 지났으면 내일 새벽 6시로 설정
    if (now.isAfter(nextExecution)) {
      nextExecution = nextExecution.add(const Duration(days: 1));
    }

    return nextExecution.difference(now);
  }

  /// 다음 실행 시간 반환 (로깅용)
  static DateTime _getNextExecutionTime() {
    final now = DateTime.now();
    var nextExecution = DateTime(now.year, now.month, now.day, 6, 0);

    if (now.isAfter(nextExecution)) {
      nextExecution = nextExecution.add(const Duration(days: 1));
    }

    return nextExecution;
  }

  /// 등록된 모든 작업 취소
  static Future<void> cancelAll() async {
    debugPrint('🛑 모든 백그라운드 작업 취소 중...');
    await Workmanager().cancelAll();
    debugPrint('✅ 모든 백그라운드 작업 취소 완료');
  }

  /// 즉시 업데이트 실행 (테스트용)
  static Future<void> runImmediately() async {
    debugPrint('⚡ 즉시 업데이트 실행...');

    await Workmanager().registerOneOffTask(
      'immediateUpdate',
      dailyUpdateTaskName,
      initialDelay: const Duration(seconds: 5),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );

    debugPrint('✅ 즉시 업데이트 작업 예약 완료 (5초 후 실행)');
  }
}
