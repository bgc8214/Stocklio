import 'package:flutter/material.dart';
import '../models/category.dart' as app_category;

class CategoryAllocationCard extends StatelessWidget {
  final List<app_category.Category> categories;
  final Map<int, double> currentPercentages;
  final Map<int, double> targetPercentages;
  final VoidCallback? onRebalanceTap;

  const CategoryAllocationCard({
    super.key,
    required this.categories,
    required this.currentPercentages,
    required this.targetPercentages,
    this.onRebalanceTap,
  });

  @override
  Widget build(BuildContext context) {
    final needsRebalancing = _checkNeedsRebalancing();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '카테고리별 비중',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (needsRebalancing && onRebalanceTap != null)
                  TextButton.icon(
                    onPressed: onRebalanceTap,
                    icon: const Icon(Icons.balance, size: 16),
                    label: const Text('리밸런싱'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            ...categories.map((category) {
              final current = currentPercentages[category.id] ?? 0.0;
              final target = targetPercentages[category.id] ?? 0.0;
              final diff = current - target;
              final needsAdjustment = diff.abs() >= 5.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCategoryRow(
                  category,
                  current,
                  target,
                  needsAdjustment,
                  diff,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(
    app_category.Category category,
    double current,
    double target,
    bool needsAdjustment,
    double diff,
  ) {
    final color = _parseColor(category.color);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              category.icon,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                category.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${current.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '/ ${target.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            if (needsAdjustment)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  diff > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 16,
                  color: Colors.orange,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                // 배경 (목표 비중)
                Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                ),
                // 현재 비중 (목표 대비 달성률로 계산)
                FractionallySizedBox(
                  widthFactor: target > 0
                    ? (current / target).clamp(0.0, 1.0)
                    : 0.0,
                  child: Container(
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _checkNeedsRebalancing() {
    for (var category in categories) {
      final current = currentPercentages[category.id] ?? 0.0;
      final target = targetPercentages[category.id] ?? 0.0;
      if ((current - target).abs() >= 5.0) {
        return true;
      }
    }
    return false;
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.blue;
    }
  }
}
