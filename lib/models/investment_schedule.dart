/// 자동투자 일정 모델
class InvestmentSchedule {
  final int? id;
  final String title; // 일정 제목 (예: "월급날 정기투자")
  final int dayOfMonth; // 매월 몇일 (1-31)
  final double totalAmount; // 투자 총액
  final Map<int, double> categoryAllocation; // 카테고리별 배분 {categoryId: amount}
  final bool isActive; // 활성화 여부
  final DateTime? lastExecuted; // 마지막 실행 날짜
  final String? memo; // 메모

  InvestmentSchedule({
    this.id,
    required this.title,
    required this.dayOfMonth,
    required this.totalAmount,
    required this.categoryAllocation,
    this.isActive = true,
    this.lastExecuted,
    this.memo,
  });

  /// 다음 실행 날짜 계산
  DateTime get nextExecutionDate {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, dayOfMonth);

    // 이번 달 날짜가 지났으면 다음 달로
    if (next.isBefore(now) || next.day == now.day) {
      next = DateTime(now.year, now.month + 1, dayOfMonth);
    }

    return next;
  }

  /// D-Day 계산
  int get daysUntilNext {
    final next = nextExecutionDate;
    final now = DateTime.now();
    return next.difference(now).inDays;
  }

  /// 오늘 실행해야 하는지 체크
  bool get shouldExecuteToday {
    final today = DateTime.now();
    return dayOfMonth == today.day &&
           (lastExecuted == null ||
            lastExecuted!.month != today.month ||
            lastExecuted!.year != today.year);
  }

  factory InvestmentSchedule.fromMap(Map<String, dynamic> map) {
    // categoryAllocation JSON 파싱
    final allocationData = map['category_allocation'] as String?;
    Map<int, double> allocation = {};

    if (allocationData != null && allocationData.isNotEmpty) {
      final parts = allocationData.split(',');
      for (var part in parts) {
        final kv = part.split(':');
        if (kv.length == 2) {
          allocation[int.parse(kv[0])] = double.parse(kv[1]);
        }
      }
    }

    return InvestmentSchedule(
      id: map['id'] as int?,
      title: map['title'] as String,
      dayOfMonth: map['day_of_month'] as int,
      totalAmount: map['total_amount'] as double,
      categoryAllocation: allocation,
      isActive: (map['is_active'] as int) == 1,
      lastExecuted: map['last_executed'] != null
          ? DateTime.parse(map['last_executed'] as String)
          : null,
      memo: map['memo'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    // categoryAllocation을 문자열로 변환 (예: "1:500000,2:300000")
    final allocationStr = categoryAllocation.entries
        .map((e) => '${e.key}:${e.value}')
        .join(',');

    return {
      'id': id,
      'title': title,
      'day_of_month': dayOfMonth,
      'total_amount': totalAmount,
      'category_allocation': allocationStr,
      'is_active': isActive ? 1 : 0,
      'last_executed': lastExecuted?.toIso8601String(),
      'memo': memo,
    };
  }

  InvestmentSchedule copyWith({
    int? id,
    String? title,
    int? dayOfMonth,
    double? totalAmount,
    Map<int, double>? categoryAllocation,
    bool? isActive,
    DateTime? lastExecuted,
    String? memo,
  }) {
    return InvestmentSchedule(
      id: id ?? this.id,
      title: title ?? this.title,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      totalAmount: totalAmount ?? this.totalAmount,
      categoryAllocation: categoryAllocation ?? this.categoryAllocation,
      isActive: isActive ?? this.isActive,
      lastExecuted: lastExecuted ?? this.lastExecuted,
      memo: memo ?? this.memo,
    );
  }
}
