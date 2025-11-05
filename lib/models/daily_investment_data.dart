/// 일일 투자 수익 데이터 모델
class DailyInvestmentData {
  final DateTime date; // 날짜
  final double dailyProfit; // 일일 수익 (원)
  final double monthlyAccumulated; // 월 누적 수익 (원)
  final double yearlyAccumulated; // 연 누적 수익 (원)

  DailyInvestmentData({
    required this.date,
    required this.dailyProfit,
    required this.monthlyAccumulated,
    required this.yearlyAccumulated,
  });

  /// 데이터베이스 결과에서 변환
  factory DailyInvestmentData.fromMap(Map<String, dynamic> map) {
    return DailyInvestmentData(
      date: DateTime.parse(map['date'] as String),
      dailyProfit: (map['dailyProfit'] as num).toDouble(),
      monthlyAccumulated: (map['monthlyAccumulated'] as num?)?.toDouble() ?? 0.0,
      yearlyAccumulated: (map['yearlyAccumulated'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// 데이터베이스 저장용 Map으로 변환
  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'dailyProfit': dailyProfit,
      'monthlyAccumulated': monthlyAccumulated,
      'yearlyAccumulated': yearlyAccumulated,
    };
  }

  @override
  String toString() {
    return 'DailyInvestmentData(date: $date, daily: $dailyProfit, monthly: $monthlyAccumulated, yearly: $yearlyAccumulated)';
  }
}
