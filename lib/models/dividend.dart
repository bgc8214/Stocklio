/// 배당 기록 모델
class Dividend {
  final int? id;
  final String ticker; // ETF 티커 (SCHD, VOO 등)
  final DateTime paymentDate; // 배당 지급일
  final double amountPerShare; // 주당 배당금 (USD)
  final double quantity; // 보유 수량
  final double totalAmount; // 총 배당금 (USD)
  final DateTime? recordDate; // 배당 기준일
  final DateTime? exDividendDate; // 배당락일
  final String? notes; // 메모

  Dividend({
    this.id,
    required this.ticker,
    required this.paymentDate,
    required this.amountPerShare,
    required this.quantity,
    required this.totalAmount,
    this.recordDate,
    this.exDividendDate,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticker': ticker,
      'payment_date': paymentDate.toIso8601String(),
      'amount_per_share': amountPerShare,
      'quantity': quantity,
      'total_amount': totalAmount,
      'record_date': recordDate?.toIso8601String(),
      'ex_dividend_date': exDividendDate?.toIso8601String(),
      'notes': notes,
    };
  }

  factory Dividend.fromMap(Map<String, dynamic> map) {
    return Dividend(
      id: map['id'] as int?,
      ticker: map['ticker'] as String,
      paymentDate: DateTime.parse(map['payment_date'] as String),
      amountPerShare: (map['amount_per_share'] as num).toDouble(),
      quantity: (map['quantity'] as num).toDouble(),
      totalAmount: (map['total_amount'] as num).toDouble(),
      recordDate: map['record_date'] != null
          ? DateTime.parse(map['record_date'] as String)
          : null,
      exDividendDate: map['ex_dividend_date'] != null
          ? DateTime.parse(map['ex_dividend_date'] as String)
          : null,
      notes: map['notes'] as String?,
    );
  }

  Dividend copyWith({
    int? id,
    String? ticker,
    DateTime? paymentDate,
    double? amountPerShare,
    double? quantity,
    double? totalAmount,
    DateTime? recordDate,
    DateTime? exDividendDate,
    String? notes,
  }) {
    return Dividend(
      id: id ?? this.id,
      ticker: ticker ?? this.ticker,
      paymentDate: paymentDate ?? this.paymentDate,
      amountPerShare: amountPerShare ?? this.amountPerShare,
      quantity: quantity ?? this.quantity,
      totalAmount: totalAmount ?? this.totalAmount,
      recordDate: recordDate ?? this.recordDate,
      exDividendDate: exDividendDate ?? this.exDividendDate,
      notes: notes ?? this.notes,
    );
  }
}

/// ETF별 배당 일정 정보
class DividendSchedule {
  final String ticker;
  final List<DateTime> paymentDates; // 연간 배당 지급 예정일
  final double annualYield; // 연 배당률 (%)

  DividendSchedule({
    required this.ticker,
    required this.paymentDates,
    required this.annualYield,
  });

  /// 다음 배당 지급일
  DateTime? get nextPaymentDate {
    final now = DateTime.now();
    for (var date in paymentDates) {
      if (date.isAfter(now)) {
        return date;
      }
    }
    return null;
  }

  /// 남은 배당 횟수 (올해)
  int get remainingPayments {
    final now = DateTime.now();
    return paymentDates.where((date) => date.isAfter(now)).length;
  }
}

/// ETF별 배당 스케줄 상수
class DividendSchedules {
  // 배당 일정 (2025년 기준, 분기별)
  static final Map<String, DividendSchedule> schedules = {
    'SCHD': DividendSchedule(
      ticker: 'SCHD',
      paymentDates: [
        DateTime(2025, 3, 27),
        DateTime(2025, 6, 26),
        DateTime(2025, 9, 25),
        DateTime(2025, 12, 27),
      ],
      annualYield: 3.8,
    ),
    'VOO': DividendSchedule(
      ticker: 'VOO',
      paymentDates: [
        DateTime(2025, 3, 28),
        DateTime(2025, 6, 27),
        DateTime(2025, 9, 26),
        DateTime(2025, 12, 26),
      ],
      annualYield: 1.5,
    ),
    'SPY': DividendSchedule(
      ticker: 'SPY',
      paymentDates: [
        DateTime(2025, 3, 28),
        DateTime(2025, 6, 27),
        DateTime(2025, 9, 26),
        DateTime(2025, 12, 26),
      ],
      annualYield: 1.5,
    ),
    'QQQ': DividendSchedule(
      ticker: 'QQQ',
      paymentDates: [
        DateTime(2025, 3, 28),
        DateTime(2025, 6, 27),
        DateTime(2025, 9, 26),
        DateTime(2025, 12, 26),
      ],
      annualYield: 0.6,
    ),
    'QQQM': DividendSchedule(
      ticker: 'QQQM',
      paymentDates: [
        DateTime(2025, 3, 28),
        DateTime(2025, 6, 27),
        DateTime(2025, 9, 26),
        DateTime(2025, 12, 26),
      ],
      annualYield: 0.6,
    ),
    'IVV': DividendSchedule(
      ticker: 'IVV',
      paymentDates: [
        DateTime(2025, 3, 28),
        DateTime(2025, 6, 27),
        DateTime(2025, 9, 26),
        DateTime(2025, 12, 26),
      ],
      annualYield: 1.5,
    ),
  };

  /// 티커로 배당 스케줄 가져오기
  static DividendSchedule? getSchedule(String ticker) {
    return schedules[ticker.toUpperCase()];
  }

  /// 예상 배당금 계산
  static double estimateDividend({
    required String ticker,
    required double quantity,
    required double currentPrice,
  }) {
    final schedule = getSchedule(ticker);
    if (schedule == null) return 0;

    final totalValue = quantity * currentPrice;
    final annualDividend = totalValue * (schedule.annualYield / 100);
    return annualDividend / 4; // 분기별 배당금
  }
}
