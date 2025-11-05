/// 월별 성과 리포트 모델
class MonthlyReport {
  final int year;
  final int month;
  final double startValue; // 월초 평가금액
  final double endValue; // 월말 평가금액
  final double totalInvested; // 월간 투자 원금
  final double totalProfit; // 월간 수익
  final double profitRate; // 월간 수익률
  final double totalDividend; // 월간 배당금
  final Map<String, CategoryPerformance> categoryPerformance; // 카테고리별 성과

  MonthlyReport({
    required this.year,
    required this.month,
    required this.startValue,
    required this.endValue,
    required this.totalInvested,
    required this.totalProfit,
    required this.profitRate,
    required this.totalDividend,
    required this.categoryPerformance,
  });

  /// 월 표시 문자열 (예: "2025년 1월")
  String get monthLabel => '$year년 $month월';

  /// 간단한 월 표시 (예: "1월")
  String get shortMonthLabel => '$month월';

  factory MonthlyReport.fromMap(Map<String, dynamic> map) {
    return MonthlyReport(
      year: map['year'] as int,
      month: map['month'] as int,
      startValue: map['startValue'] as double,
      endValue: map['endValue'] as double,
      totalInvested: map['totalInvested'] as double,
      totalProfit: map['totalProfit'] as double,
      profitRate: map['profitRate'] as double,
      totalDividend: map['totalDividend'] as double,
      categoryPerformance: (map['categoryPerformance'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(
                    key,
                    CategoryPerformance.fromMap(value as Map<String, dynamic>),
                  )) ??
          {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'startValue': startValue,
      'endValue': endValue,
      'totalInvested': totalInvested,
      'totalProfit': totalProfit,
      'profitRate': profitRate,
      'totalDividend': totalDividend,
      'categoryPerformance': categoryPerformance.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
    };
  }
}

/// 카테고리별 성과
class CategoryPerformance {
  final String categoryName;
  final double startValue;
  final double endValue;
  final double profit;
  final double profitRate;
  final double currentWeight; // 현재 비중
  final double targetWeight; // 목표 비중

  CategoryPerformance({
    required this.categoryName,
    required this.startValue,
    required this.endValue,
    required this.profit,
    required this.profitRate,
    required this.currentWeight,
    required this.targetWeight,
  });

  factory CategoryPerformance.fromMap(Map<String, dynamic> map) {
    return CategoryPerformance(
      categoryName: map['categoryName'] as String,
      startValue: map['startValue'] as double,
      endValue: map['endValue'] as double,
      profit: map['profit'] as double,
      profitRate: map['profitRate'] as double,
      currentWeight: map['currentWeight'] as double,
      targetWeight: map['targetWeight'] as double,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryName': categoryName,
      'startValue': startValue,
      'endValue': endValue,
      'profit': profit,
      'profitRate': profitRate,
      'currentWeight': currentWeight,
      'targetWeight': targetWeight,
    };
  }
}

/// 월별 리포트 서비스
class MonthlyReportService {
  /// 특정 월의 성과 리포트 생성
  static Future<MonthlyReport> generateReport({
    required int year,
    required int month,
    required double startValue,
    required double endValue,
    required double totalInvested,
    required double totalDividend,
    required Map<String, CategoryPerformance> categoryPerformance,
  }) async {
    final profit = endValue - startValue;
    final profitRate = startValue > 0 ? (profit / startValue) * 100 : 0.0;

    return MonthlyReport(
      year: year,
      month: month,
      startValue: startValue,
      endValue: endValue,
      totalInvested: totalInvested,
      totalProfit: profit,
      profitRate: profitRate.toDouble(),
      totalDividend: totalDividend,
      categoryPerformance: categoryPerformance,
    );
  }

  /// 이번 달 vs 지난 달 비교
  static Map<String, dynamic> compareMonths(
    MonthlyReport current,
    MonthlyReport? previous,
  ) {
    if (previous == null) {
      return {
        'valueDiff': current.endValue,
        'profitDiff': current.totalProfit,
        'profitRateDiff': current.profitRate,
        'hasIncrease': true,
      };
    }

    return {
      'valueDiff': current.endValue - previous.endValue,
      'profitDiff': current.totalProfit - previous.totalProfit,
      'profitRateDiff': current.profitRate - previous.profitRate,
      'hasIncrease': current.endValue > previous.endValue,
    };
  }
}
