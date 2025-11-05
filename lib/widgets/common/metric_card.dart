import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';

/// Reusable metric card for displaying key financial metrics
/// Used in Dashboard screen for 4 core metrics
class MetricCard extends StatelessWidget {
  final String title;
  final double value;
  final double? percentage;
  final bool isProfit;
  final String? subtitle;
  final IconData? icon;

  const MetricCard({
    Key? key,
    required this.title,
    required this.value,
    this.percentage,
    this.isProfit = true,
    this.subtitle,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.currency(
      locale: 'ko_KR',
      symbol: '₩',
      decimalDigits: 0,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: AppSpacing.borderRadiusLG,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: AppSpacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title row with optional icon
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16.0,
                  color: AppColors.secondaryText,
                ),
                AppSpacing.horizontalSpaceSM,
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelSmall,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceSM,

          // Main value
          Text(
            numberFormat.format(value),
            style: AppTextStyles.numberMedium.copyWith(
              color: percentage != null
                  ? AppColors.getProfitLossColor(value)
                  : AppColors.primaryText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Percentage and subtitle
          if (percentage != null || subtitle != null) ...[
            AppSpacing.verticalSpaceXS,
            Row(
              children: [
                if (percentage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.getProfitLossColorWithOpacity(value, 0.1),
                      borderRadius: AppSpacing.borderRadiusXS,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          value >= 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 12.0,
                          color: AppColors.getProfitLossColor(value),
                        ),
                        AppSpacing.horizontalSpaceXS,
                        Text(
                          '${percentage!.abs().toStringAsFixed(1)}%',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.getProfitLossColor(value),
                            fontWeight: AppTextStyles.semiBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (subtitle != null) ...[
                  if (percentage != null) AppSpacing.horizontalSpaceSM,
                  Expanded(
                    child: Text(
                      subtitle!,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.neutralGray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
