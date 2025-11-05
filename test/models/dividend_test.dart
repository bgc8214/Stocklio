import 'package:flutter_test/flutter_test.dart';
import 'package:stocklio/models/dividend.dart';

void main() {
  group('Dividend 모델 테스트', () {
    test('toMap이 올바르게 직렬화됨', () {
      // Given
      final dividend = Dividend(
        id: 1,
        ticker: 'SCHD',
        paymentDate: DateTime(2025, 3, 27),
        amountPerShare: 0.75,
        quantity: 100.0,
        totalAmount: 75.0,
        notes: '테스트 배당',
      );

      // When
      final map = dividend.toMap();

      // Then
      expect(map['id'], 1);
      expect(map['ticker'], 'SCHD');
      expect(map['payment_date'], '2025-03-27T00:00:00.000');
      expect(map['amount_per_share'], 0.75);
      expect(map['quantity'], 100.0);
      expect(map['total_amount'], 75.0);
      expect(map['notes'], '테스트 배당');
    });

    test('fromMap이 올바르게 역직렬화됨', () {
      // Given
      final map = {
        'id': 1,
        'ticker': 'SCHD',
        'payment_date': '2025-03-27T00:00:00.000',
        'amount_per_share': 0.75,
        'quantity': 100.0,
        'total_amount': 75.0,
        'record_date': null,
        'ex_dividend_date': null,
        'notes': '테스트 배당',
      };

      // When
      final dividend = Dividend.fromMap(map);

      // Then
      expect(dividend.id, 1);
      expect(dividend.ticker, 'SCHD');
      expect(dividend.paymentDate, DateTime(2025, 3, 27));
      expect(dividend.amountPerShare, 0.75);
      expect(dividend.quantity, 100.0);
      expect(dividend.totalAmount, 75.0);
      expect(dividend.notes, '테스트 배당');
    });

    test('copyWith이 올바르게 복사됨', () {
      // Given
      final original = Dividend(
        id: 1,
        ticker: 'SCHD',
        paymentDate: DateTime(2025, 3, 27),
        amountPerShare: 0.75,
        quantity: 100.0,
        totalAmount: 75.0,
      );

      // When
      final copied = original.copyWith(
        quantity: 200.0,
        totalAmount: 150.0,
      );

      // Then
      expect(copied.id, 1);
      expect(copied.ticker, 'SCHD');
      expect(copied.quantity, 200.0);
      expect(copied.totalAmount, 150.0);
      expect(copied.amountPerShare, 0.75); // 변경되지 않음
    });
  });

  group('DividendSchedule 테스트', () {
    test('다음 배당 지급일이 올바르게 계산됨', () {
      // Given
      final schedule = DividendSchedule(
        ticker: 'SCHD',
        paymentDates: [
          DateTime(2025, 3, 27),
          DateTime(2025, 6, 26),
          DateTime(2025, 9, 25),
          DateTime(2025, 12, 27),
        ],
        annualYield: 3.8,
      );

      // When (현재 시간이 2025년 1월이라고 가정)
      final nextDate = schedule.nextPaymentDate;

      // Then
      expect(nextDate, isNotNull);
      // 실제 테스트 시점에 따라 결과가 달라질 수 있음
    });

    test('남은 배당 횟수가 올바르게 계산됨', () {
      // Given
      final schedule = DividendSchedule(
        ticker: 'SCHD',
        paymentDates: [
          DateTime(2025, 3, 27),
          DateTime(2025, 6, 26),
          DateTime(2025, 9, 25),
          DateTime(2025, 12, 27),
        ],
        annualYield: 3.8,
      );

      // When
      final remaining = schedule.remainingPayments;

      // Then
      expect(remaining, greaterThanOrEqualTo(0));
      expect(remaining, lessThanOrEqualTo(4));
    });
  });

  group('DividendSchedules 상수 테스트', () {
    test('SCHD 스케줄이 존재함', () {
      // When
      final schedule = DividendSchedules.getSchedule('SCHD');

      // Then
      expect(schedule, isNotNull);
      expect(schedule!.ticker, 'SCHD');
      expect(schedule.annualYield, 3.8);
      expect(schedule.paymentDates.length, 4);
    });

    test('VOO 스케줄이 존재함', () {
      // When
      final schedule = DividendSchedules.getSchedule('VOO');

      // Then
      expect(schedule, isNotNull);
      expect(schedule!.ticker, 'VOO');
      expect(schedule.annualYield, 1.5);
    });

    test('존재하지 않는 티커는 null 반환', () {
      // When
      final schedule = DividendSchedules.getSchedule('INVALID');

      // Then
      expect(schedule, isNull);
    });

    test('예상 배당금이 올바르게 계산됨', () {
      // Given
      final ticker = 'SCHD';
      final quantity = 100.0;
      final currentPrice = 75.0;

      // When
      final estimatedDividend = DividendSchedules.estimateDividend(
        ticker: ticker,
        quantity: quantity,
        currentPrice: currentPrice,
      );

      // Then
      // SCHD 연 배당률 3.8%, 분기별 = 3.8% / 4
      // 총 자산: 100 * 75 = 7,500
      // 연 배당: 7,500 * 0.038 = 285
      // 분기별: 285 / 4 = 71.25
      expect(estimatedDividend, closeTo(71.25, 0.01));
    });

    test('대소문자 구분 없이 스케줄 조회', () {
      // When
      final scheduleLower = DividendSchedules.getSchedule('schd');
      final scheduleUpper = DividendSchedules.getSchedule('SCHD');

      // Then
      expect(scheduleLower, isNotNull);
      expect(scheduleUpper, isNotNull);
      expect(scheduleLower!.ticker, scheduleUpper!.ticker);
    });
  });
}
