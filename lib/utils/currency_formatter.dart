import 'package:intl/intl.dart';

/// 금액을 원화 형식으로 포맷
String formatCurrency(double amount) {
  final formatter = NumberFormat('#,###');
  return '${formatter.format(amount.round())}원';
}

/// 수익률을 퍼센트 형식으로 포맷
String formatPercentage(double percentage) {
  return '${percentage >= 0 ? '+' : ''}${percentage.toStringAsFixed(2)}%';
}

/// 날짜를 'yyyy.MM.dd' 형식으로 포맷
String formatDate(DateTime date) {
  return DateFormat('yyyy.MM.dd').format(date);
}

/// 날짜를 'MM/dd' 형식으로 포맷 (차트용)
String formatDateShort(DateTime date) {
  return DateFormat('MM/dd').format(date);
}

/// 금액을 간략하게 포맷 (차트 Y축용)
String formatCurrencyCompact(double amount) {
  final absAmount = amount.abs();
  String formatted;

  if (absAmount >= 100000000) {
    // 1억 이상
    formatted = '${(amount / 100000000).toStringAsFixed(1)}억';
  } else if (absAmount >= 10000) {
    // 1만 이상
    formatted = '${(amount / 10000).toStringAsFixed(0)}만';
  } else if (absAmount >= 1000) {
    // 1천 이상
    formatted = '${(amount / 1000).toStringAsFixed(1)}천';
  } else {
    formatted = '${amount.toStringAsFixed(0)}';
  }

  return formatted;
}
