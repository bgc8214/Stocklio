import 'package:flutter_test/flutter_test.dart';
import 'package:stocklio/utils/currency_formatter.dart';

void main() {
  group('formatCurrency 테스트', () {
    test('정수가 올바르게 포맷됨', () {
      expect(formatCurrency(1000000), '1,000,000원');
      expect(formatCurrency(5000), '5,000원');
      expect(formatCurrency(100), '100원');
    });

    test('소수점이 반올림됨', () {
      expect(formatCurrency(1234.56), '1,235원');
      expect(formatCurrency(1234.44), '1,234원');
    });

    test('음수가 올바르게 포맷됨', () {
      expect(formatCurrency(-1000000), '-1,000,000원');
      expect(formatCurrency(-5000), '-5,000원');
    });

    test('0이 올바르게 포맷됨', () {
      expect(formatCurrency(0), '0원');
    });

    test('큰 숫자가 올바르게 포맷됨', () {
      expect(formatCurrency(123456789), '123,456,789원');
    });
  });

  group('formatPercentage 테스트', () {
    test('양수 퍼센트에 + 기호 포함', () {
      expect(formatPercentage(5.5), '+5.50%');
      expect(formatPercentage(10.123), '+10.12%');
    });

    test('음수 퍼센트에 - 기호만', () {
      expect(formatPercentage(-5.5), '-5.50%');
      expect(formatPercentage(-10.123), '-10.12%');
    });

    test('0 퍼센트에 + 기호 포함', () {
      expect(formatPercentage(0), '+0.00%');
    });

    test('소수점 둘째 자리까지 표시', () {
      expect(formatPercentage(5.12345), '+5.12%');
      expect(formatPercentage(-3.98765), '-3.99%');
    });
  });

  group('formatDate 테스트', () {
    test('날짜가 yyyy.MM.dd 형식으로 포맷됨', () {
      final date = DateTime(2025, 3, 27);
      expect(formatDate(date), '2025.03.27');
    });

    test('한 자리 월/일이 0으로 패딩됨', () {
      final date = DateTime(2025, 1, 5);
      expect(formatDate(date), '2025.01.05');
    });
  });

  group('formatDateShort 테스트', () {
    test('날짜가 MM/dd 형식으로 포맷됨', () {
      final date = DateTime(2025, 3, 27);
      expect(formatDateShort(date), '03/27');
    });

    test('한 자리 월/일이 0으로 패딩됨', () {
      final date = DateTime(2025, 1, 5);
      expect(formatDateShort(date), '01/05');
    });
  });

  group('formatCurrencyCompact 테스트', () {
    test('1억 이상은 억 단위로 표시', () {
      expect(formatCurrencyCompact(100000000), '1.0억');
      expect(formatCurrencyCompact(350000000), '3.5억');
      expect(formatCurrencyCompact(1200000000), '12.0억');
    });

    test('1만 이상은 만 단위로 표시', () {
      expect(formatCurrencyCompact(10000), '1만');
      expect(formatCurrencyCompact(50000), '5만');
      expect(formatCurrencyCompact(99999999), '10000만'); // 1억 직전
    });

    test('1천 이상은 천 단위로 표시', () {
      expect(formatCurrencyCompact(1000), '1.0천');
      expect(formatCurrencyCompact(5500), '5.5천');
      expect(formatCurrencyCompact(9999), '10.0천');
    });

    test('1천 미만은 그대로 표시', () {
      expect(formatCurrencyCompact(999), '999');
      expect(formatCurrencyCompact(500), '500');
      expect(formatCurrencyCompact(100), '100');
    });

    test('음수도 올바르게 포맷됨', () {
      expect(formatCurrencyCompact(-100000000), '-1.0억');
      expect(formatCurrencyCompact(-50000), '-5만');
      expect(formatCurrencyCompact(-5500), '-5.5천');
    });

    test('0이 올바르게 포맷됨', () {
      expect(formatCurrencyCompact(0), '0');
    });
  });
}
