import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../utils/currency_formatter.dart';

class CategoryGoalSettingScreen extends StatefulWidget {
  final Category category;

  const CategoryGoalSettingScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryGoalSettingScreen> createState() =>
      _CategoryGoalSettingScreenState();
}

class _CategoryGoalSettingScreenState extends State<CategoryGoalSettingScreen> {
  final _targetAmountController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    // 기존 목표값 로드
    if (widget.category.targetAmount != null) {
      _targetAmountController.text =
          widget.category.targetAmount!.toStringAsFixed(0);
    }
    if (widget.category.targetWeight != null) {
      _targetWeightController.text =
          widget.category.targetWeight!.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _targetAmountController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _saveGoals() async {
    final targetAmount = double.tryParse(_targetAmountController.text);
    final targetWeight = double.tryParse(_targetWeightController.text);

    // 유효성 검사
    if (targetAmount == null || targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('올바른 목표 금액을 입력해주세요'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await _db.updateCategoryGoals(
      categoryId: widget.category.id,
      targetAmount: targetAmount,
      targetWeight: targetWeight,
    );

    if (!mounted) return;

    // 축하 다이얼로그 표시
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.profitGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.celebration,
                size: 64,
                color: AppColors.profitGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '목표 설정 완료!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.category.icon} ${widget.category.displayName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '목표 금액',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        formatCurrency(targetAmount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (targetWeight != null && targetWeight > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '목표 비중',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${targetWeight.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '목표를 향해 차근차근\n투자해보세요! 💪',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              '확인',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;
    Navigator.pop(context, true); // true를 반환하여 새로고침 필요 알림
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('${widget.category.icon} ${widget.category.displayName} 목표 설정'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '포메뽀꼬 전략 목표 설정',
              style: AppTextStyles.headlineMedium,
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              '"n억 모으기" 목표와 리밸런싱 비중을 설정하세요',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            AppSpacing.verticalSpaceXL,

            // 목표 금액 입력
            Text(
              '목표 금액',
              style: AppTextStyles.titleMedium,
            ),
            AppSpacing.verticalSpaceSM,
            TextField(
              controller: _targetAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '예: 300000000 (3억원)',
                suffixText: '원',
                border: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMD,
                ),
              ),
              style: AppTextStyles.bodyLarge,
            ),
            AppSpacing.verticalSpaceLG,

            // 목표 비중 입력
            Text(
              '목표 비중 (%)',
              style: AppTextStyles.titleMedium,
            ),
            AppSpacing.verticalSpaceSM,
            TextField(
              controller: _targetWeightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '예: 40 (40%)',
                suffixText: '%',
                border: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMD,
                ),
              ),
              style: AppTextStyles.bodyLarge,
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              '💡 리밸런싱: 목표 비중 ± 5% 벗어나면 알림',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            AppSpacing.verticalSpaceXL,

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveGoals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusMD,
                  ),
                ),
                child: Text(
                  '목표 저장',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
