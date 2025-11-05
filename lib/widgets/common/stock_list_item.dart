import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/portfolio.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';

/// Reusable stock list item for portfolio display
class StockListItem extends StatelessWidget {
  final Portfolio portfolio;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const StockListItem({
    Key? key,
    required this.portfolio,
    this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.currency(
      locale: 'ko_KR',
      symbol: '₩',
      decimalDigits: 0,
    );

    final totalValue = portfolio.currentPrice * portfolio.quantity;
    final totalCost = portfolio.averagePrice * portfolio.quantity;
    final profit = totalValue - totalCost;
    final profitPercentage = totalCost > 0
        ? (profit / totalCost) * 100
        : 0.0;

    return Dismissible(
      key: Key(portfolio.id.toString()),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (onDelete != null) {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('종목 삭제'),
              content: Text('${portfolio.stockName} 종목을 삭제하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('취소'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.lossRed,
                  ),
                  child: const Text('삭제'),
                ),
              ],
            ),
          );
        }
        return false;
      },
      onDismissed: (direction) {
        if (onDelete != null) {
          onDelete!();
        }
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.lossRed,
          borderRadius: AppSpacing.borderRadiusLG,
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28.0,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusLG,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.primaryBackground,
            borderRadius: AppSpacing.borderRadiusLG,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stock name and ticker row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          portfolio.stockName,
                          style: AppTextStyles.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        AppSpacing.verticalSpaceXS,
                        Text(
                          '${portfolio.quantity}주 × ${numberFormat.format(portfolio.currentPrice)}',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.horizontalSpaceMD,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        numberFormat.format(profit),
                        style: AppTextStyles.profitLoss(profit),
                      ),
                      AppSpacing.verticalSpaceXS,
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.getProfitLossColorWithOpacity(
                            profit,
                            0.1,
                          ),
                          borderRadius: AppSpacing.borderRadiusXS,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              profit >= 0
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 12.0,
                              color: AppColors.getProfitLossColor(profit),
                            ),
                            AppSpacing.horizontalSpaceXS,
                            Text(
                              '${profitPercentage.abs().toStringAsFixed(1)}%',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.getProfitLossColor(profit),
                                fontWeight: AppTextStyles.semiBold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              AppSpacing.verticalSpaceMD,

              // Average price info
              Row(
                children: [
                  Text(
                    '평단: ${numberFormat.format(portfolio.averagePrice)}',
                    style: AppTextStyles.labelSmall,
                  ),
                  AppSpacing.horizontalSpaceMD,
                  Text(
                    '총액: ${numberFormat.format(totalValue)}',
                    style: AppTextStyles.labelSmall,
                  ),
                ],
              ),

              // Portfolio allocation bar
              AppSpacing.verticalSpaceSM,
              ClipRRect(
                borderRadius: AppSpacing.borderRadiusXS,
                child: LinearProgressIndicator(
                  value: 0.15, // TODO: Calculate actual portfolio percentage
                  backgroundColor: AppColors.secondaryBackground,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.getProfitLossColor(profit),
                  ),
                  minHeight: 4.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
