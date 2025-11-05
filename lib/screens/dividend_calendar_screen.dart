import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/dividend.dart';
import '../models/portfolio.dart';
import '../utils/currency_formatter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

class DividendCalendarScreen extends StatefulWidget {
  const DividendCalendarScreen({super.key});

  @override
  State<DividendCalendarScreen> createState() => _DividendCalendarScreenState();
}

class _DividendCalendarScreenState extends State<DividendCalendarScreen> {
  final _db = DatabaseService();
  int _selectedYear = DateTime.now().year;
  bool _isLoading = true;
  List<Dividend> _dividends = [];
  List<Portfolio> _portfolios = [];
  double _annualTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final dividendMaps = await _db.getDividendsByYear(_selectedYear);
      final dividends = dividendMaps.map((map) => Dividend.fromMap(map)).toList();
      final portfolios = await _db.getPortfolios();
      final total = await _db.getAnnualDividendTotal(_selectedYear);

      setState(() {
        _dividends = dividends;
        _portfolios = portfolios;
        _annualTotal = total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  /// 티커별로 그룹화된 배당 데이터
  Map<String, List<Dividend>> _groupByTicker() {
    final grouped = <String, List<Dividend>>{};
    for (var dividend in _dividends) {
      if (!grouped.containsKey(dividend.ticker)) {
        grouped[dividend.ticker] = [];
      }
      grouped[dividend.ticker]!.add(dividend);
    }
    return grouped;
  }

  /// 예상 배당 계산 (실제 기록이 없는 경우)
  List<_ExpectedDividend> _calculateExpectedDividends() {
    final expected = <_ExpectedDividend>[];

    for (var portfolio in _portfolios) {
      final schedule = DividendSchedules.getSchedule(portfolio.ticker);
      if (schedule == null) continue;

      for (var paymentDate in schedule.paymentDates) {
        // 이미 기록된 배당은 제외
        final hasRecord = _dividends.any((d) =>
            d.ticker == portfolio.ticker &&
            d.paymentDate.year == paymentDate.year &&
            d.paymentDate.month == paymentDate.month &&
            d.paymentDate.day == paymentDate.day);

        if (!hasRecord) {
          final estimatedAmount = DividendSchedules.estimateDividend(
            ticker: portfolio.ticker,
            quantity: portfolio.quantity.toDouble(),
            currentPrice: portfolio.currentPrice,
          );

          expected.add(_ExpectedDividend(
            ticker: portfolio.ticker,
            paymentDate: paymentDate,
            estimatedAmount: estimatedAmount,
          ));
        }
      }
    }

    return expected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💰 배당 캘린더'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_portfolios.isEmpty) {
      return _buildEmptyState();
    }

    final groupedDividends = _groupByTicker();
    final expectedDividends = _calculateExpectedDividends();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 연도 선택 및 연간 총액
            _buildYearSelector(),
            AppSpacing.verticalSpaceLG,

            // 연간 총액 카드
            _buildAnnualTotalCard(),
            AppSpacing.verticalSpaceXL,

            // 배당 일정
            Text(
              '배당 일정',
              style: AppTextStyles.headlineMedium,
            ),
            AppSpacing.verticalSpaceMD,

            if (_dividends.isEmpty && expectedDividends.isEmpty)
              _buildNoDataCard()
            else
              ..._buildDividendTimeline(groupedDividends, expectedDividends),

            AppSpacing.verticalSpaceXXL,

            // 안내 문구
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildYearSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '배당 내역',
          style: AppTextStyles.headlineMedium,
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: AppSpacing.borderRadiusMD,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  setState(() => _selectedYear--);
                  _loadData();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Text(
                '$_selectedYear년',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  setState(() => _selectedYear++);
                  _loadData();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnnualTotalCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.profitGreen,
            AppColors.profitGreen.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: AppSpacing.borderRadiusLG,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_selectedYear년 배당 총액',
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          AppSpacing.verticalSpaceSM,
          Text(
            '\$${_annualTotal.toStringAsFixed(2)}',
            style: AppTextStyles.numberLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_dividends.isNotEmpty) ...[
            AppSpacing.verticalSpaceSM,
            Text(
              '총 ${_dividends.length}회 지급',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildDividendTimeline(
    Map<String, List<Dividend>> groupedDividends,
    List<_ExpectedDividend> expectedDividends,
  ) {
    final widgets = <Widget>[];

    // 티커별로 표시
    final allTickers = {...groupedDividends.keys, ...expectedDividends.map((e) => e.ticker)}.toList();
    allTickers.sort();

    for (var ticker in allTickers) {
      final actualDividends = groupedDividends[ticker] ?? [];
      final expected = expectedDividends.where((e) => e.ticker == ticker).toList();

      widgets.add(_buildTickerSection(ticker, actualDividends, expected));
      widgets.add(AppSpacing.verticalSpaceLG);
    }

    return widgets;
  }

  Widget _buildTickerSection(
    String ticker,
    List<Dividend> actualDividends,
    List<_ExpectedDividend> expectedDividends,
  ) {
    // 보유 수량 찾기
    final portfolio = _portfolios.firstWhere(
      (p) => p.ticker == ticker,
      orElse: () => Portfolio(
        id: 0,
        ticker: ticker,
        name: ticker,
        quantity: 0,
        averageCost: 0,
        market: 'US',
        currentPrice: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    final schedule = DividendSchedules.getSchedule(ticker);
    final tickerTotal = actualDividends.fold<double>(
      0,
      (sum, d) => sum + d.totalAmount,
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusLG,
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 티커 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticker,
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '보유: ${portfolio.quantity.toStringAsFixed(2)}주',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (schedule != null)
                    Text(
                      '연 배당률: ${schedule.annualYield.toStringAsFixed(2)}%',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
              if (tickerTotal > 0)
                Text(
                  '\$${tickerTotal.toStringAsFixed(2)}',
                  style: AppTextStyles.numberMedium.copyWith(
                    color: AppColors.profitGreen,
                  ),
                ),
            ],
          ),
          AppSpacing.verticalSpaceMD,

          // 배당 내역
          ...actualDividends.map((dividend) => _buildDividendItem(dividend, true)),
          ...expectedDividends.map((expected) => _buildExpectedDividendItem(expected)),
        ],
      ),
    );
  }

  Widget _buildDividendItem(Dividend dividend, bool isActual) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.profitGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.check_circle,
              color: AppColors.profitGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDate(dividend.paymentDate),
                  style: AppTextStyles.titleMedium,
                ),
                Text(
                  '주당 \$${dividend.amountPerShare.toStringAsFixed(4)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${dividend.totalAmount.toStringAsFixed(2)}',
            style: AppTextStyles.numberMedium.copyWith(
              color: AppColors.profitGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpectedDividendItem(_ExpectedDividend expected) {
    final isPast = expected.paymentDate.isBefore(DateTime.now());
    final isUpcoming = !isPast &&
        expected.paymentDate.difference(DateTime.now()).inDays <= 30;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isUpcoming ? Icons.schedule : Icons.calendar_today,
              color: isUpcoming ? Colors.orange : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDate(expected.paymentDate),
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isPast ? Colors.grey : null,
                  ),
                ),
                Text(
                  '예상',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '~\$${expected.estimatedAmount.toStringAsFixed(2)}',
            style: AppTextStyles.numberMedium.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: AppSpacing.borderRadiusMD,
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          AppSpacing.verticalSpaceMD,
          Text(
            '배당 일정이 없습니다',
            style: AppTextStyles.titleMedium,
          ),
          AppSpacing.verticalSpaceSM,
          Text(
            '보유 중인 ETF의 배당 일정을 자동으로 표시합니다',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: AppSpacing.borderRadiusMD,
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text(
                '배당 정보',
                style: AppTextStyles.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• ✅ 아이콘: 실제 배당 수령 내역\n'
            '• 📅 아이콘: 예상 배당 일정\n'
            '• 배당금은 USD 기준으로 표시됩니다\n'
            '• 예상 배당금은 현재 주가와 배당률 기준입니다',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            '보유 종목이 없습니다',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '종목을 추가하면 배당 일정을 확인할 수 있습니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

/// 예상 배당 데이터 클래스
class _ExpectedDividend {
  final String ticker;
  final DateTime paymentDate;
  final double estimatedAmount;

  _ExpectedDividend({
    required this.ticker,
    required this.paymentDate,
    required this.estimatedAmount,
  });
}
