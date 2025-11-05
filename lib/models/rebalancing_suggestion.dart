import 'category.dart';

/// 리밸런싱 제안 모델
class RebalancingSuggestion {
  final Category category;
  final double currentWeight; // 현재 비중 (%)
  final double targetWeight; // 목표 비중 (%)
  final double deviation; // 편차 (현재 - 목표)
  final double currentValue; // 현재 금액
  final double targetValue; // 목표 금액
  final bool needsRebalancing; // 리밸런싱 필요 여부 (±5% 초과)

  RebalancingSuggestion({
    required this.category,
    required this.currentWeight,
    required this.targetWeight,
    required this.deviation,
    required this.currentValue,
    required this.targetValue,
    required this.needsRebalancing,
  });

  /// 편차가 양수면 초과, 음수면 부족
  bool get isOverweight => deviation > 0;

  /// 필요한 조정 금액 (절댓값)
  double get adjustmentAmount => (targetValue - currentValue).abs();

  /// 조정 방향 설명
  String get actionDescription {
    if (!needsRebalancing) return '정상 범위';
    if (isOverweight) return '매도 필요';
    return '매수 필요';
  }
}

/// 전체 리밸런싱 분석 결과
class RebalancingAnalysis {
  final List<RebalancingSuggestion> suggestions;
  final double totalValue; // 총 자산
  final bool needsRebalancing; // 하나라도 리밸런싱 필요한지
  final DateTime analyzedAt;

  RebalancingAnalysis({
    required this.suggestions,
    required this.totalValue,
    required this.needsRebalancing,
    required this.analyzedAt,
  });

  /// 초과된 카테고리 목록
  List<RebalancingSuggestion> get overweightCategories =>
      suggestions.where((s) => s.needsRebalancing && s.isOverweight).toList();

  /// 부족한 카테고리 목록
  List<RebalancingSuggestion> get underweightCategories =>
      suggestions.where((s) => s.needsRebalancing && !s.isOverweight).toList();

  /// 정상 범위 카테고리 목록
  List<RebalancingSuggestion> get balancedCategories =>
      suggestions.where((s) => !s.needsRebalancing).toList();
}
