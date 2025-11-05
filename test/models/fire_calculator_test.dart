import 'package:flutter_test/flutter_test.dart';
import 'package:stocklio/models/fire_calculator.dart';

void main() {
  group('FireCalculator 테스트', () {
    test('필요 자산이 올바르게 계산됨 (4% 룰)', () {
      // Given: 월 400만원 생활비
      const monthlyExpense = 4000000.0;

      // When
      final requiredAsset = FireCalculator.calculateRequiredAsset(monthlyExpense);

      // Then: 연간 4,800만원 / 0.04 = 12억원
      expect(requiredAsset, 1200000000.0);
    });

    test('현재 자산으로 가능한 월 소득이 올바르게 계산됨', () {
      // Given: 12억원 자산
      const currentAsset = 1200000000.0;

      // When
      final monthlyIncome = FireCalculator.calculateMonthlyIncome(currentAsset);

      // Then: 12억 × 0.04 ÷ 12 = 400만원
      expect(monthlyIncome, 4000000.0);
    });

    test('달성률이 올바르게 계산됨', () {
      // Given
      const currentAsset = 300000000.0; // 3억
      const targetAsset = 1200000000.0; // 12억

      // When
      final progress = FireCalculator.calculateProgress(currentAsset, targetAsset);

      // Then: 3억 / 12억 = 25%
      expect(progress, 25.0);
    });

    test('달성률이 100%를 초과하지 않음', () {
      // Given: 현재 자산이 목표보다 많음
      const currentAsset = 1500000000.0;
      const targetAsset = 1200000000.0;

      // When
      final progress = FireCalculator.calculateProgress(currentAsset, targetAsset);

      // Then: 100%로 제한
      expect(progress, 100.0);
    });

    test('목표 달성 개월 수가 계산됨 (월 100만원 투자)', () {
      // Given
      const currentAsset = 100000000.0; // 1억
      const targetAsset = 1200000000.0; // 12억
      const monthlyInvestment = 1000000.0; // 100만원

      // When
      final months = FireCalculator.calculateMonthsToFire(
        currentAsset: currentAsset,
        targetAsset: targetAsset,
        monthlyInvestment: monthlyInvestment,
      );

      // Then: 복리 고려하면 약 100개월 내외 (정확한 값은 복리 계산 결과)
      expect(months, greaterThan(0));
      expect(months, lessThan(1200)); // 100년 미만
    });

    test('이미 달성한 경우 0개월 반환', () {
      // Given: 이미 목표 달성
      const currentAsset = 1200000000.0;
      const targetAsset = 1200000000.0;
      const monthlyInvestment = 1000000.0;

      // When
      final months = FireCalculator.calculateMonthsToFire(
        currentAsset: currentAsset,
        targetAsset: targetAsset,
        monthlyInvestment: monthlyInvestment,
      );

      // Then
      expect(months, 0);
    });

    test('월 투자가 0이면 -1 반환 (달성 불가)', () {
      // Given
      const currentAsset = 100000000.0;
      const targetAsset = 1200000000.0;
      const monthlyInvestment = 0.0;

      // When
      final months = FireCalculator.calculateMonthsToFire(
        currentAsset: currentAsset,
        targetAsset: targetAsset,
        monthlyInvestment: monthlyInvestment,
      );

      // Then
      expect(months, -1);
    });

    test('배당 커버리지 비율이 올바르게 계산됨', () {
      // Given
      const annualDividend = 24000000.0; // 연 2,400만원
      const monthlyExpense = 4000000.0; // 월 400만원 (연 4,800만원)

      // When
      final coverage = FireCalculator.calculateDividendCoverageRatio(
        annualDividend,
        monthlyExpense,
      );

      // Then: 2,400만원 / 4,800만원 = 50%
      expect(coverage, 50.0);
    });

    test('배당 커버리지가 100%를 초과하지 않음', () {
      // Given: 배당금이 생활비보다 많음
      const annualDividend = 60000000.0; // 연 6,000만원
      const monthlyExpense = 4000000.0; // 월 400만원 (연 4,800만원)

      // When
      final coverage = FireCalculator.calculateDividendCoverageRatio(
        annualDividend,
        monthlyExpense,
      );

      // Then: 100%로 제한
      expect(coverage, 100.0);
    });

    test('추가 인출 필요 금액이 올바르게 계산됨', () {
      // Given
      const monthlyExpense = 4000000.0; // 400만원
      const monthlyDividend = 1500000.0; // 150만원

      // When
      final needed = FireCalculator.calculateMonthlyWithdrawalNeeded(
        monthlyExpense,
        monthlyDividend,
      );

      // Then: 400 - 150 = 250만원
      expect(needed, 2500000.0);
    });

    test('배당금이 생활비를 초과하면 인출 불필요', () {
      // Given: 배당금 > 생활비
      const monthlyExpense = 4000000.0;
      const monthlyDividend = 5000000.0;

      // When
      final needed = FireCalculator.calculateMonthlyWithdrawalNeeded(
        monthlyExpense,
        monthlyDividend,
      );

      // Then: 0원
      expect(needed, 0.0);
    });
  });

  group('FireSimulation 테스트', () {
    test('시뮬레이션이 올바르게 생성됨', () {
      // Given
      const currentAsset = 300000000.0; // 3억
      const monthlyExpense = 4000000.0; // 400만원
      const monthlyInvestment = 1000000.0; // 100만원

      // When
      final simulation = FireSimulation.calculate(
        currentAsset: currentAsset,
        monthlyExpense: monthlyExpense,
        monthlyInvestment: monthlyInvestment,
      );

      // Then
      expect(simulation.currentAsset, currentAsset);
      expect(simulation.targetAsset, 1200000000.0);
      expect(simulation.monthlyExpense, monthlyExpense);
      expect(simulation.progress, 25.0);
      expect(simulation.remainingAsset, 900000000.0);
      expect(simulation.isAchievable, true);
      expect(simulation.isAchieved, false);
    });

    test('이미 달성한 경우 isAchieved가 true', () {
      // Given: 목표 이상 자산 보유
      const currentAsset = 1200000000.0;
      const monthlyExpense = 4000000.0;

      // When
      final simulation = FireSimulation.calculate(
        currentAsset: currentAsset,
        monthlyExpense: monthlyExpense,
      );

      // Then
      expect(simulation.isAchieved, true);
      expect(simulation.progress, 100.0);
    });

    test('남은 연수가 올바르게 계산됨', () {
      // Given
      const currentAsset = 100000000.0;
      const monthlyExpense = 4000000.0;
      const monthlyInvestment = 1000000.0;

      // When
      final simulation = FireSimulation.calculate(
        currentAsset: currentAsset,
        monthlyExpense: monthlyExpense,
        monthlyInvestment: monthlyInvestment,
      );

      // Then
      expect(simulation.yearsToFire, isNotNull);
      expect(simulation.yearsToFire! > 0, true);
    });
  });
}
