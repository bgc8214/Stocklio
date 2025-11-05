import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/daily_investment_data.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../utils/currency_formatter.dart';

/// 투자 수익 차트 위젯
/// 일일 수익, 월 누적 수익, 연 누적 수익을 꺾은선 그래프로 표시
class InvestmentProfitChart extends StatefulWidget {
  final List<DailyInvestmentData> data;
  final String selectedMonth; // 예: "10월"
  final double totalMonthlyProfit; // 해당 월 총 수익

  const InvestmentProfitChart({
    super.key,
    required this.data,
    required this.selectedMonth,
    required this.totalMonthlyProfit,
  });

  @override
  State<InvestmentProfitChart> createState() => _InvestmentProfitChartState();
}

class _InvestmentProfitChartState extends State<InvestmentProfitChart> {
  // 범례 토글 상태
  bool _showDaily = true; // 일일 수익 (빨강)
  bool _showMonthly = true; // 월 누적 수익 (파랑)
  bool _showYearly = true; // 연 누적 수익 (녹색)

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return _buildEmptyState();
    }

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
        children: [
          // 헤더
          _buildHeader(),
          AppSpacing.verticalSpaceLG,

          // 범례
          _buildLegend(),
          AppSpacing.verticalSpaceLG,

          // 차트
          SizedBox(
            height: 300,
            child: _buildChart(),
          ),
        ],
      ),
    );
  }

  /// 헤더 (선택된 월 + 총 수익)
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.selectedMonth,
          style: AppTextStyles.titleLarge,
        ),
        AppSpacing.verticalSpaceXS,
        Text(
          '투자 수익 ${formatCurrency(widget.totalMonthlyProfit)}',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.getProfitLossColor(widget.totalMonthlyProfit),
          ),
        ),
      ],
    );
  }

  /// 범례 (터치하여 표시/숨김 토글)
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          '일일 수익',
          AppColors.lossRed,
          _showDaily,
          () => setState(() => _showDaily = !_showDaily),
        ),
        AppSpacing.horizontalSpaceLG,
        _buildLegendItem(
          '${widget.selectedMonth.split('월')[0]}월 누적 수익',
          AppColors.primaryBlue,
          _showMonthly,
          () => setState(() => _showMonthly = !_showMonthly),
        ),
        AppSpacing.horizontalSpaceLG,
        _buildLegendItem(
          '${DateTime.now().year % 100}년 누적수익',
          AppColors.profitGreen,
          _showYearly,
          () => setState(() => _showYearly = !_showYearly),
        ),
      ],
    );
  }

  /// 개별 범례 항목
  Widget _buildLegendItem(
    String label,
    Color color,
    bool isActive,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusXS,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: AppSpacing.borderRadiusXS,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 3,
              decoration: BoxDecoration(
                color: isActive ? color : color.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AppSpacing.horizontalSpaceXS,
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isActive
                    ? AppColors.primaryText
                    : AppColors.secondaryText,
                fontWeight: isActive
                    ? AppTextStyles.semiBold
                    : AppTextStyles.regular,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 차트 본체
  Widget _buildChart() {
    final spots = _prepareChartData();
    final minMaxY = _calculateMinMaxY(spots);

    return LineChart(
      LineChartData(
        minY: minMaxY['min']!,
        maxY: minMaxY['max']!,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (minMaxY['max']! - minMaxY['min']!) / 5,
          getDrawingHorizontalLine: (value) {
            // 0선 강조
            if (value == 0) {
              return FlLine(
                color: AppColors.primaryText.withOpacity(0.3),
                strokeWidth: 1.5,
                dashArray: [5, 5],
              );
            }
            return FlLine(
              color: AppColors.neutralGray.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          // Y축 (왼쪽)
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                return Text(
                  formatCurrencyCompact(value),
                  style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
                  textAlign: TextAlign.right,
                );
              },
            ),
          ),
          // X축 (하단)
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: widget.data.length > 10 ? widget.data.length / 5 : 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < widget.data.length) {
                  final date = widget.data[index].date;
                  return Text(
                    '${date.day}',
                    style: AppTextStyles.labelSmall.copyWith(fontSize: 9),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          // 연 누적 수익 (녹색)
          if (_showYearly)
            LineChartBarData(
              spots: spots['yearly']!,
              isCurved: false,
              color: AppColors.profitGreen,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, barData) {
                  // 5일마다 또는 첫/마지막 포인트에만 표시
                  final index = spot.x.toInt();
                  return index % 5 == 0 || index == 0 || index == widget.data.length - 1;
                },
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: AppColors.profitGreen,
                    strokeWidth: 1.5,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),

          // 월 누적 수익 (파랑)
          if (_showMonthly)
            LineChartBarData(
              spots: spots['monthly']!,
              isCurved: false,
              color: AppColors.primaryBlue,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, barData) {
                  final index = spot.x.toInt();
                  return index % 5 == 0 || index == 0 || index == widget.data.length - 1;
                },
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: AppColors.primaryBlue,
                    strokeWidth: 1.5,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),

          // 일일 수익 (빨강)
          if (_showDaily)
            LineChartBarData(
              spots: spots['daily']!,
              isCurved: false,
              color: AppColors.lossRed,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, barData) {
                  final index = spot.x.toInt();
                  return index % 5 == 0 || index == 0 || index == widget.data.length - 1;
                },
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: AppColors.lossRed,
                    strokeWidth: 1.5,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(show: false),
            ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index < 0 || index >= widget.data.length) {
                  return null;
                }

                final data = widget.data[index];
                final date = data.date;

                // 터치한 라인에 따라 레이블 결정
                String label = '';
                double value = spot.y;

                // 활성화된 시리즈의 인덱스 계산
                int activeIndex = 0;
                if (_showYearly) {
                  if (spot.barIndex == activeIndex) {
                    label = '연 누적';
                    value = data.yearlyAccumulated;
                  }
                  activeIndex++;
                }
                if (_showMonthly) {
                  if (spot.barIndex == activeIndex) {
                    label = '월 누적';
                    value = data.monthlyAccumulated;
                  }
                  activeIndex++;
                }
                if (_showDaily) {
                  if (spot.barIndex == activeIndex) {
                    label = '일일';
                    value = data.dailyProfit;
                  }
                }

                return LineTooltipItem(
                  '${date.month}/${date.day}\n$label\n${formatCurrency(value)}',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  /// 차트 데이터 준비
  Map<String, List<FlSpot>> _prepareChartData() {
    final dailySpots = <FlSpot>[];
    final monthlySpots = <FlSpot>[];
    final yearlySpots = <FlSpot>[];

    for (int i = 0; i < widget.data.length; i++) {
      final data = widget.data[i];
      dailySpots.add(FlSpot(i.toDouble(), data.dailyProfit));
      monthlySpots.add(FlSpot(i.toDouble(), data.monthlyAccumulated));
      yearlySpots.add(FlSpot(i.toDouble(), data.yearlyAccumulated));
    }

    return {
      'daily': dailySpots,
      'monthly': monthlySpots,
      'yearly': yearlySpots,
    };
  }

  /// Y축 최소/최대값 계산
  Map<String, double> _calculateMinMaxY(Map<String, List<FlSpot>> spots) {
    final allValues = <double>[];

    if (_showDaily) allValues.addAll(spots['daily']!.map((s) => s.y));
    if (_showMonthly) allValues.addAll(spots['monthly']!.map((s) => s.y));
    if (_showYearly) allValues.addAll(spots['yearly']!.map((s) => s.y));

    if (allValues.isEmpty) {
      return {'min': -100, 'max': 100};
    }

    double minY = allValues.reduce((a, b) => a < b ? a : b);
    double maxY = allValues.reduce((a, b) => a > b ? a : b);

    // 여백 추가
    final range = maxY - minY;
    if (range == 0) {
      if (minY == 0) {
        minY = -100;
        maxY = 100;
      } else {
        minY = minY - minY.abs() * 0.1;
        maxY = maxY + maxY.abs() * 0.1;
      }
    } else {
      minY -= range * 0.1;
      maxY += range * 0.1;
    }

    // 0을 포함하도록 조정
    if (minY > 0) minY = 0;
    if (maxY < 0) maxY = 0;

    return {'min': minY, 'max': maxY};
  }

  /// 빈 상태 표시
  Widget _buildEmptyState() {
    return Container(
      height: 300,
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 60,
              color: AppColors.neutralGray.withOpacity(0.5),
            ),
            AppSpacing.verticalSpaceLG,
            Text(
              '수익 데이터가 없습니다',
              style: AppTextStyles.titleMedium,
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              '종목을 추가하고 내일부터 수익 추이가 표시됩니다',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
