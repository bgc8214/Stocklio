import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_service.dart';
import '../utils/currency_formatter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

class ProfitChart extends StatefulWidget {
  const ProfitChart({super.key});

  @override
  State<ProfitChart> createState() => _ProfitChartState();
}

enum ChartPeriod { week, month, threeMonths, year }

class _ProfitChartState extends State<ProfitChart> {
  final _db = DatabaseService();
  List<FlSpot> _dailyProfitSpots = [];
  List<FlSpot> _monthlyProfitSpots = [];
  List<FlSpot> _yearlyProfitSpots = [];
  List<DateTime> _dates = []; // 날짜 정보 저장
  bool _isLoading = true;
  double _minY = 0;
  double _maxY = 100;

  // 범례 토글 상태
  bool _showDaily = true;
  bool _showMonthly = true;
  bool _showYearly = true;

  // 기간 선택
  ChartPeriod _selectedPeriod = ChartPeriod.month;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    setState(() => _isLoading = true);

    try {
      final now = DateTime.now();
      DateTime startDate;

      // 선택된 기간에 따라 시작 날짜 설정
      switch (_selectedPeriod) {
        case ChartPeriod.week:
          startDate = now.subtract(const Duration(days: 7));
          break;
        case ChartPeriod.month:
          startDate = now.subtract(const Duration(days: 30));
          break;
        case ChartPeriod.threeMonths:
          startDate = now.subtract(const Duration(days: 90));
          break;
        case ChartPeriod.year:
          startDate = DateTime(now.year, 1, 1);
          break;
      }

      final snapshots = await _db.getDailySnapshots(
        startDate: startDate,
        endDate: now,
      );

      if (snapshots.isEmpty) {
        setState(() {
          _isLoading = false;
          _dailyProfitSpots = [];
          _monthlyProfitSpots = [];
          _yearlyProfitSpots = [];
        });
        return;
      }

      // 날짜 정보 저장
      _dates = snapshots.map((s) => s['date'] as DateTime).toList();

      // 일일 수익 데이터
      _dailyProfitSpots = snapshots.asMap().entries.map((entry) {
        return FlSpot(
          entry.key.toDouble(),
          (entry.value['dailyProfit'] ?? 0).toDouble(),
        );
      }).toList();

      // 월간 누적 수익 계산
      double monthlyAccumulated = 0;
      int currentMonth = snapshots.first['date'].month;
      _monthlyProfitSpots = snapshots.asMap().entries.map((entry) {
        final snapshot = entry.value;
        final date = snapshot['date'] as DateTime;

        // 월이 바뀌면 누적값 리셋
        if (date.month != currentMonth) {
          monthlyAccumulated = 0;
          currentMonth = date.month;
        }

        monthlyAccumulated += snapshot['dailyProfit'] ?? 0;
        return FlSpot(entry.key.toDouble(), monthlyAccumulated);
      }).toList();

      // 연간 누적 수익 계산
      double yearlyAccumulated = 0;
      _yearlyProfitSpots = snapshots.asMap().entries.map((entry) {
        yearlyAccumulated += entry.value['dailyProfit'] ?? 0;
        return FlSpot(entry.key.toDouble(), yearlyAccumulated);
      }).toList();

      // Y축 범위 계산
      final allValues = [
        ..._dailyProfitSpots.map((s) => s.y),
        ..._monthlyProfitSpots.map((s) => s.y),
        ..._yearlyProfitSpots.map((s) => s.y),
      ];

      if (allValues.isNotEmpty) {
        _minY = allValues.reduce((a, b) => a < b ? a : b);
        _maxY = allValues.reduce((a, b) => a > b ? a : b);

        // 여백 추가
        final range = _maxY - _minY;

        // range가 0이면 (모든 값이 같으면) 기본 범위 설정
        if (range == 0) {
          if (_minY == 0) {
            // 모든 값이 0이면
            _minY = -100;
            _maxY = 100;
          } else {
            // 모든 값이 동일한 값이면
            _minY = _minY - _minY.abs() * 0.1;
            _maxY = _maxY + _maxY.abs() * 0.1;
          }
        } else {
          _minY -= range * 0.1;
          _maxY += range * 0.1;
        }

        // 0을 포함하도록 조정
        if (_minY > 0) _minY = 0;
        if (_maxY < 0) _maxY = 0;
      }
    } catch (e) {
      debugPrint('차트 데이터 로드 실패: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_dailyProfitSpots.isEmpty) {
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
                '내일부터 수익 추이가 표시됩니다',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ),
      );
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
        children: [
          // 기간 선택 버튼
          Row(
            children: [
              _buildPeriodButton('1주', ChartPeriod.week),
              AppSpacing.horizontalSpaceXS,
              _buildPeriodButton('1개월', ChartPeriod.month),
              AppSpacing.horizontalSpaceXS,
              _buildPeriodButton('3개월', ChartPeriod.threeMonths),
              AppSpacing.horizontalSpaceXS,
              _buildPeriodButton('연간', ChartPeriod.year),
            ],
          ),
          AppSpacing.verticalSpaceLG,

          // 범례 (터치 가능)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildToggleableLegend('일일', AppColors.chartDaily, _showDaily, () {
                setState(() => _showDaily = !_showDaily);
              }),
              AppSpacing.horizontalSpaceLG,
              _buildToggleableLegend('월간', AppColors.chartMonthly, _showMonthly, () {
                setState(() => _showMonthly = !_showMonthly);
              }),
              AppSpacing.horizontalSpaceLG,
              _buildToggleableLegend('연간', AppColors.chartYearly, _showYearly, () {
                setState(() => _showYearly = !_showYearly);
              }),
            ],
          ),
          AppSpacing.verticalSpaceLG,

          // 차트
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                minY: _minY,
                maxY: _maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (_maxY - _minY) > 0 ? (_maxY - _minY) / 5 : 1,
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
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          formatCurrencyCompact(value),
                          style: AppTextStyles.labelSmall.copyWith(
                            fontSize: 9,
                          ),
                          textAlign: TextAlign.right,
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: _dates.isNotEmpty ? _dates.length / 5 : 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < _dates.length) {
                          final date = _dates[index];
                          // 기간에 따라 다른 포맷 사용
                          String label;
                          if (_selectedPeriod == ChartPeriod.week) {
                            label = '${date.month}/${date.day}';
                          } else if (_selectedPeriod == ChartPeriod.month || _selectedPeriod == ChartPeriod.threeMonths) {
                            label = '${date.month}/${date.day}';
                          } else {
                            label = '${date.month}월';
                          }
                          return Text(
                            label,
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 9,
                            ),
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
                  // 연간 누적 수익 (꺾은선) - 토글 가능
                  if (_showYearly)
                    LineChartBarData(
                      spots: _yearlyProfitSpots,
                      isCurved: false,
                      color: AppColors.chartYearly,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),

                  // 월간 누적 수익 (꺾은선) - 토글 가능
                  if (_showMonthly)
                    LineChartBarData(
                      spots: _monthlyProfitSpots,
                      isCurved: false,
                      color: AppColors.chartMonthly,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),

                  // 일일 수익 (꺾은선) - 토글 가능
                  if (_showDaily)
                    LineChartBarData(
                      spots: _dailyProfitSpots,
                      isCurved: false,
                      color: AppColors.chartDaily,
                      barWidth: 2.5,
                      dotData: const FlDotData(show: false),
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
                        // 날짜 정보 추가
                        final index = spot.x.toInt();
                        String dateStr = '';
                        if (index >= 0 && index < _dates.length) {
                          final date = _dates[index];
                          dateStr = '${date.month}/${date.day}\n';
                        }

                        // 범례 레이블
                        String label = '';
                        Color color = Colors.white;

                        // 현재 활성화된 시리즈에 따라 인덱스 매핑
                        int activeIndex = 0;
                        if (_showYearly) {
                          if (spot.barIndex == activeIndex) {
                            label = '연간 누적';
                            color = AppColors.chartYearly;
                          }
                          activeIndex++;
                        }
                        if (_showMonthly) {
                          if (spot.barIndex == activeIndex) {
                            label = '월간 누적';
                            color = AppColors.chartMonthly;
                          }
                          activeIndex++;
                        }
                        if (_showDaily) {
                          if (spot.barIndex == activeIndex) {
                            label = '일일';
                            color = AppColors.chartDaily;
                          }
                        }

                        return LineTooltipItem(
                          '$dateStr$label\n${formatCurrency(spot.y)}',
                          TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 기간 선택 버튼
  Widget _buildPeriodButton(String label, ChartPeriod period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
          });
          _loadChartData();
        },
        borderRadius: AppSpacing.borderRadiusXS,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryBlue
                : AppColors.secondaryBackground,
            borderRadius: AppSpacing.borderRadiusXS,
          ),
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? Colors.white : AppColors.secondaryText,
              fontWeight: isSelected
                  ? AppTextStyles.semiBold
                  : AppTextStyles.regular,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  // 토글 가능한 범례
  Widget _buildToggleableLegend(
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
          color: isActive
              ? color.withOpacity(0.1)
              : Colors.transparent,
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
}
