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
