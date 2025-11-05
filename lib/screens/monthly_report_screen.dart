import 'package:flutter/material.dart';
import '../models/monthly_report.dart';
import '../services/database_service.dart';
import '../utils/currency_formatter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

/// 월별 성과 리포트 화면
class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  final DatabaseService _db = DatabaseService();
  bool _isLoading = true;
  MonthlyReport? _currentReport;
  MonthlyReport? _previousReport;

  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);

    try {
      // 현재 선택된 월의 리포트 생성
      final report = await _generateMonthlyReport(_selectedYear, _selectedMonth);

      // 이전 달 리포트 생성
      final prevMonth = _selectedMonth == 1 ? 12 : _selectedMonth - 1;
      final prevYear = _selectedMonth == 1 ? _selectedYear - 1 : _selectedYear;
      final prevReport = await _generateMonthlyReport(prevYear, prevMonth);

      setState(() {
        _currentReport = report;
        _previousReport = prevReport;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('리포트 로드 실패: $e');
      setState(() => _isLoading = false);
    }
  }

  /// 월별 리포트 생성
  Future<MonthlyReport> _generateMonthlyReport(int year, int month) async {
    // 해당 월의 첫날과 마지막 날
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    // 월초 평가금액
    final startValue = await _db.getTotalValueByDate(startDate) ?? 0;

    // 월말 평가금액
    final endValue = await _db.getTotalValueByDate(endDate) ?? 0;

    // 월간 배당금
    final dividends = await _db.getDividendsByMonth(year, month);
    final totalDividend = dividends.fold<double>(
      0,
      (sum, div) => sum + (div['total_amount'] as num).toDouble(),
    );

    // 카테고리별 성과 (현재는 빈 맵, 추후 구현)
    final categoryPerformance = <String, CategoryPerformance>{};

    return MonthlyReportService.generateReport(
      year: year,
      month: month,
      startValue: startValue,
      endValue: endValue,
      totalInvested: 0, // TODO: 실제 투자 원금 계산
      totalDividend: totalDividend,
      categoryPerformance: categoryPerformance,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('월별 성과 리포트'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showMonthPicker,
            tooltip: '월 선택',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentReport == null
              ? _buildEmptyState()
              : _buildReportContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assessment_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            '리포트 데이터가 없습니다',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: 12),
          Text(
            '종목을 추가하고 데이터가 쌓이면\n월별 성과를 확인할 수 있습니다',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    final report = _currentReport!;
    final comparison = MonthlyReportService.compareMonths(report, _previousReport);

    return RefreshIndicator(
      onRefresh: _loadReport,
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 월 선택 헤더
            _buildMonthSelector(),
            AppSpacing.verticalSpaceLG,

            // 핵심 지표 카드
            _buildSummaryCard(report, comparison),
            AppSpacing.verticalSpaceLG,

            // 수익률 차트 (TODO: 추후 구현)
            // _buildProfitChart(report),
            // AppSpacing.verticalSpaceLG,

            // 배당금 섹션
            if (report.totalDividend > 0) ...[
              _buildDividendSection(report),
              AppSpacing.verticalSpaceLG,
            ],

            // 카테고리별 성과 (TODO: 추후 구현)
            // if (report.categoryPerformance.isNotEmpty) ...[
            //   _buildCategoryPerformance(report),
            //   AppSpacing.verticalSpaceLG,
            // ],

            // 인사이트 & 메모
            _buildInsights(report),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return InkWell(
      onTap: _showMonthPicker,
      borderRadius: AppSpacing.borderRadiusLG,
      child: Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.1),
          borderRadius: AppSpacing.borderRadiusLG,
          border: Border.all(
            color: AppColors.primaryBlue.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _currentReport?.monthLabel ?? '',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.primaryBlue,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: AppColors.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    MonthlyReport report,
    Map<String, dynamic> comparison,
  ) {
    final hasIncrease = comparison['hasIncrease'] as bool;
    final valueDiff = comparison['valueDiff'] as double;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppSpacing.borderRadiusLG,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '월말 평가금액',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
          ),
          AppSpacing.verticalSpaceSM,
          Text(
            formatCurrency(report.endValue),
            style: AppTextStyles.numberLarge.copyWith(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.verticalSpaceSM,
          Row(
            children: [
              Icon(
                hasIncrease ? Icons.trending_up : Icons.trending_down,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${hasIncrease ? '+' : ''}${formatCurrency(valueDiff)}',
                style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                '(${report.profitRate >= 0 ? '+' : ''}${report.profitRate.toStringAsFixed(2)}%)',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              ),
            ],
          ),
          AppSpacing.verticalSpaceLG,
          const Divider(color: Colors.white30),
          AppSpacing.verticalSpaceSM,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('월초', formatCurrency(report.startValue)),
              _buildStatItem('수익', formatCurrency(report.totalProfit)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDividendSection(MonthlyReport report) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.profitGreen.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusLG,
        border: Border.all(color: AppColors.profitGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_money,
                color: AppColors.profitGreen,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '이번 달 배당금',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.profitGreen,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceMD,
          Text(
            formatCurrency(report.totalDividend),
            style: AppTextStyles.numberLarge.copyWith(
              color: AppColors.profitGreen,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.verticalSpaceSM,
          Text(
            '💰 월급 외 수입이 생겼어요!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.profitGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(MonthlyReport report) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: AppSpacing.borderRadiusLG,
        border: Border.all(color: AppColors.neutralGray.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡 이번 달 인사이트',
            style: AppTextStyles.titleMedium,
          ),
          AppSpacing.verticalSpaceMD,
          _buildInsightItem(
            _getPerformanceInsight(report),
            Icons.assessment,
          ),
          if (report.totalDividend > 0)
            _buildInsightItem(
              '배당금 ${formatCurrency(report.totalDividend)}을 받았습니다',
              Icons.monetization_on,
            ),
          _buildInsightItem(
            '다음 달에도 꾸준히 투자해보세요! 🚀',
            Icons.trending_up,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _getPerformanceInsight(MonthlyReport report) {
    if (report.totalProfit >= 0) {
      return '이번 달 수익률 ${report.profitRate.toStringAsFixed(2)}%를 기록했습니다. 잘하고 계세요! 👍';
    } else {
      return '이번 달은 ${report.profitRate.abs().toStringAsFixed(2)}% 하락했습니다. 시장은 항상 변동하니 장기적인 관점을 유지하세요.';
    }
  }

  Future<void> _showMonthPicker() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300,
        padding: AppSpacing.cardPadding,
        child: Column(
          children: [
            Text(
              '월 선택',
              style: AppTextStyles.titleLarge,
            ),
            AppSpacing.verticalSpaceLG,
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final isSelected = month == _selectedMonth;

                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedMonth = month;
                      });
                      Navigator.pop(context);
                      _loadReport();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryBlue
                            : AppColors.secondaryBackground,
                        borderRadius: AppSpacing.borderRadiusSM,
                      ),
                      child: Center(
                        child: Text(
                          '$month월',
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.primaryText,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
