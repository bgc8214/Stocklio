import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_service.dart';
import '../utils/currency_formatter.dart';

class ProfitChart extends StatefulWidget {
  const ProfitChart({super.key});

  @override
  State<ProfitChart> createState() => _ProfitChartState();
}

class _ProfitChartState extends State<ProfitChart> {
  final _db = DatabaseService();
  List<FlSpot> _dailyProfitSpots = [];
  List<FlSpot> _monthlyProfitSpots = [];
  List<FlSpot> _yearlyProfitSpots = [];
  bool _isLoading = true;
  double _minY = 0;
  double _maxY = 100;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    setState(() => _isLoading = true);

    try {
      // 현재 연도 데이터만 로드 (MVP)
      final now = DateTime.now();
      final startOfYear = DateTime(now.year, 1, 1);

      final snapshots = await _db.getDailySnapshots(
        startDate: startOfYear,
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

      // 일일 수익 데이터
      _dailyProfitSpots = snapshots.asMap().entries.map((entry) {
        return FlSpot(
          entry.key.toDouble(),
          entry.value['dailyProfit'] ?? 0,
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
        _minY -= range * 0.1;
        _maxY += range * 0.1;

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
      return SizedBox(
        height: 300,
        child: Card(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.show_chart,
                  size: 60,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '수익 데이터가 없습니다',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '내일부터 수익 추이가 표시됩니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 범례
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('일일', Colors.blue),
                const SizedBox(width: 16),
                _buildLegendItem('월간 누적', Colors.green),
                const SizedBox(width: 16),
                _buildLegendItem('연간 누적', Colors.orange),
              ],
            ),
            const SizedBox(height: 16),

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
                    horizontalInterval: (_maxY - _minY) / 5,
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            formatCurrency(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: _dailyProfitSpots.length / 6,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < _dailyProfitSpots.length) {
                            // 실제 날짜 표시 (간략화 필요)
                            return Text(
                              '${value.toInt() + 1}',
                              style: const TextStyle(fontSize: 10),
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
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    // 연간 누적 수익 (영역 차트)
                    LineChartBarData(
                      spots: _yearlyProfitSpots,
                      color: Colors.orange.withAlpha(127),
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.orange.withAlpha(25),
                      ),
                    ),

                    // 월간 누적 수익 (영역 차트)
                    LineChartBarData(
                      spots: _monthlyProfitSpots,
                      color: Colors.green.withAlpha(127),
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withAlpha(25),
                      ),
                    ),

                    // 일일 수익 (선 차트)
                    LineChartBarData(
                      spots: _dailyProfitSpots,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          String label = '';
                          if (spot.barIndex == 0) label = '연간';
                          if (spot.barIndex == 1) label = '월간';
                          if (spot.barIndex == 2) label = '일일';

                          return LineTooltipItem(
                            '$label\n${formatCurrency(spot.y)}',
                            const TextStyle(color: Colors.white),
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
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
