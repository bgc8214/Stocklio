/// Fire (Financial Independence, Retire Early) 전략 계산기
/// 4% 인출 룰 기반
class FireCalculator {
  /// 4% 인출 룰 비율
  static const double withdrawalRate = 0.04;

  /// 월 생활비로부터 필요한 총 자산 계산
  ///
  /// 4% 룰: 연간 생활비 = 필요 자산 × 0.04
  /// 따라서: 필요 자산 = 연간 생활비 ÷ 0.04 (= 연간 생활비 × 25)
  ///
  /// [monthlyExpense]: 월 생활비 (원)
  /// 반환: 필요한 총 자산 (원)
  static double calculateRequiredAsset(double monthlyExpense) {
    final annualExpense = monthlyExpense * 12;
    return annualExpense / withdrawalRate;
  }

  /// 현재 자산으로 가능한 월 생활비 계산
  ///
  /// [currentAsset]: 현재 총 자산 (원)
  /// 반환: 연 4% 인출 시 월 생활비 (원)
  static double calculateMonthlyIncome(double currentAsset) {
    final annualWithdrawal = currentAsset * withdrawalRate;
    return annualWithdrawal / 12;
  }

  /// Fire 달성률 계산
  ///
  /// [currentAsset]: 현재 총 자산 (원)
  /// [targetAsset]: 목표 총 자산 (원)
  /// 반환: 달성률 (0~100%)
  static double calculateProgress(double currentAsset, double targetAsset) {
    if (targetAsset == 0) return 0;
    return (currentAsset / targetAsset * 100).clamp(0, 100);
  }

  /// 목표 달성까지 남은 기간 계산 (단순 선형 추정)
  ///
  /// [currentAsset]: 현재 총 자산 (원)
  /// [targetAsset]: 목표 총 자산 (원)
  /// [monthlyInvestment]: 월 투자 금액 (원)
  /// [expectedAnnualReturn]: 예상 연 수익률 (기본값: 7%)
  /// 반환: 달성까지 남은 개월 수
  static int calculateMonthsToFire({
    required double currentAsset,
    required double targetAsset,
    required double monthlyInvestment,
    double expectedAnnualReturn = 0.07,
  }) {
    if (currentAsset >= targetAsset) return 0;
    if (monthlyInvestment <= 0) return -1; // 불가능

    final monthlyReturn = expectedAnnualReturn / 12;

    // 복리 계산 (미래 가치 공식)
    // FV = PV * (1 + r)^n + PMT * [((1 + r)^n - 1) / r]
    // 이진 탐색으로 n 계산
    int months = 0;
    double futureValue = currentAsset;

    while (futureValue < targetAsset && months < 1200) {
      // 최대 100년
      futureValue = futureValue * (1 + monthlyReturn) + monthlyInvestment;
      months++;
    }

    return months < 1200 ? months : -1;
  }

  /// 목표 달성 연도 계산
  ///
  /// [monthsToFire]: calculateMonthsToFire 결과
  /// 반환: 달성 예상 연도
  static int? calculateFireYear(int monthsToFire) {
    if (monthsToFire < 0) return null;
    final now = DateTime.now();
    final targetDate = now.add(Duration(days: monthsToFire * 30));
    return targetDate.year;
  }

  /// 배당 수익으로 커버 가능한 생활비 비율 계산
  ///
  /// [annualDividend]: 연간 배당금 (원)
  /// [monthlyExpense]: 월 생활비 (원)
  /// 반환: 배당금으로 커버되는 비율 (0~100%)
  static double calculateDividendCoverageRatio(
    double annualDividend,
    double monthlyExpense,
  ) {
    final annualExpense = monthlyExpense * 12;
    if (annualExpense == 0) return 100;
    return (annualDividend / annualExpense * 100).clamp(0, 100);
  }

  /// 매월 필요한 인출 금액 계산 (배당금 제외)
  ///
  /// [monthlyExpense]: 월 생활비 (원)
  /// [monthlyDividend]: 월 배당금 (원)
  /// 반환: 추가로 인출이 필요한 금액 (원)
  static double calculateMonthlyWithdrawalNeeded(
    double monthlyExpense,
    double monthlyDividend,
  ) {
    final needed = monthlyExpense - monthlyDividend;
    return needed > 0 ? needed : 0;
  }
}

/// Fire 전략 시뮬레이션 결과
class FireSimulation {
  final double currentAsset; // 현재 자산
  final double targetAsset; // 목표 자산
  final double monthlyExpense; // 월 생활비
  final double monthlyInvestment; // 월 투자 금액
  final double progress; // 달성률 (%)
  final int? monthsToFire; // 달성까지 개월 수
  final int? fireYear; // 달성 연도
  final double currentMonthlyIncome; // 현재 자산으로 가능한 월 소득
  final double targetMonthlyIncome; // 목표 달성 시 월 소득
  final double remainingAsset; // 부족 금액

  FireSimulation({
    required this.currentAsset,
    required this.targetAsset,
    required this.monthlyExpense,
    required this.monthlyInvestment,
    required this.progress,
    this.monthsToFire,
    this.fireYear,
    required this.currentMonthlyIncome,
    required this.targetMonthlyIncome,
    required this.remainingAsset,
  });

  factory FireSimulation.calculate({
    required double currentAsset,
    required double monthlyExpense,
    double monthlyInvestment = 0,
    double expectedAnnualReturn = 0.07,
  }) {
    final targetAsset = FireCalculator.calculateRequiredAsset(monthlyExpense);
    final progress = FireCalculator.calculateProgress(currentAsset, targetAsset);
    final monthsToFire = monthlyInvestment > 0
        ? FireCalculator.calculateMonthsToFire(
            currentAsset: currentAsset,
            targetAsset: targetAsset,
            monthlyInvestment: monthlyInvestment,
            expectedAnnualReturn: expectedAnnualReturn,
          )
        : null;
    final fireYear =
        monthsToFire != null ? FireCalculator.calculateFireYear(monthsToFire) : null;
    final currentMonthlyIncome =
        FireCalculator.calculateMonthlyIncome(currentAsset);
    final targetMonthlyIncome = monthlyExpense;
    final remainingAsset = targetAsset - currentAsset;

    return FireSimulation(
      currentAsset: currentAsset,
      targetAsset: targetAsset,
      monthlyExpense: monthlyExpense,
      monthlyInvestment: monthlyInvestment,
      progress: progress,
      monthsToFire: monthsToFire,
      fireYear: fireYear,
      currentMonthlyIncome: currentMonthlyIncome,
      targetMonthlyIncome: targetMonthlyIncome,
      remainingAsset: remainingAsset,
    );
  }

  /// 달성 가능 여부
  bool get isAchievable => monthsToFire != null && monthsToFire! > 0;

  /// 이미 달성했는지
  bool get isAchieved => progress >= 100;

  /// 남은 연수
  double? get yearsToFire =>
      monthsToFire != null ? monthsToFire! / 12.0 : null;
}
