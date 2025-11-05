import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../providers/category_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/error_handler.dart';
import '../widgets/investment_chart/investment_profit_chart.dart';
import '../widgets/category_allocation_card.dart';
import '../widgets/common/metric_card.dart';
import '../models/daily_investment_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../services/database_service.dart';
import '../widgets/common/app_drawer.dart';
import 'category_portfolio_screen.dart';
import 'add_stock_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<DailyInvestmentData> _chartData = [];
  String _selectedMonth = '';
  double _monthlyTotalProfit = 0.0;
  bool _isLoadingChart = true;

  // 월 선택
  int _selectedYear = DateTime.now().year;
  int _selectedMonthInt = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    // 화면 로드 시 포트폴리오 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PortfolioProvider>().loadPortfolio();
      context.read<CategoryProvider>().loadCategories();
      _loadChartData();
    });
  }

  /// 차트 데이터 로드
  Future<void> _loadChartData() async {
    setState(() => _isLoadingChart = true);

    try {
      // 선택된 월 표시 (예: "10월")
      _selectedMonth = '$_selectedMonthInt월';

      // 데이터베이스에서 해당 월의 투자 수익 데이터 조회
      final rawData = await DatabaseService().getInvestmentDataForMonth(_selectedYear, _selectedMonthInt);

      // DailyInvestmentData 모델로 변환
      _chartData = rawData.map((map) => DailyInvestmentData.fromMap(map)).toList();

      // 해당 월의 총 수익 계산
      _monthlyTotalProfit = await DatabaseService().getMonthlyTotalProfit(_selectedYear, _selectedMonthInt);
    } catch (e) {
      ErrorHandler.logError('차트 데이터 로드', e);
      _chartData = [];
      _monthlyTotalProfit = 0.0;

      // 사용자에게 친화적인 에러 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserFriendlyMessage(e)),
            backgroundColor: AppColors.lossRed,
          ),
        );
      }
    } finally {
      setState(() => _isLoadingChart = false);
    }
  }

  /// 월 선택 변경
  void _onMonthChanged(int year, int month) {
    setState(() {
      _selectedYear = year;
      _selectedMonthInt = month;
    });
    _loadChartData();
  }

  // 테스트용 더미 데이터 생성
  Future<void> _generateDummyData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('테스트 데이터 생성'),
        content: const Text(
          '최근 90일간의 더미 수익 데이터를 생성합니다.\n'
          '기존 스냅샷 데이터는 삭제됩니다.\n\n'
          '계속하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('생성'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // 로딩 표시
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // 더미 데이터 생성
      await DatabaseService().generateDummySnapshots();

      // 로딩 닫기
      if (!mounted) return;
      Navigator.pop(context);

      // 성공 메시지
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('90일간의 테스트 데이터가 생성되었습니다'),
          backgroundColor: AppColors.profitGreen,
        ),
      );

      // 화면 새로고침하여 차트 업데이트
      await _loadChartData();
    } catch (e) {
      // 로딩 닫기
      if (!mounted) return;
      Navigator.pop(context);

      // 에러 메시지
      ErrorHandler.logError('테스트 데이터 생성', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHandler.getUserFriendlyMessage(e)),
          backgroundColor: AppColors.lossRed,
        ),
      );
    }
  }

  /// 포메뽀꼬 전략 설명 다이얼로그
  void _showPomebokkoInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Text('🎯 '),
            Text('포메뽀꼬 전략이란?'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '포메뽀꼬는 "포트폴리오 메이킹으로 뽀개고 꼬라박기"의 줄임말로, '
                '체계적인 ETF 투자 전략입니다.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                '📊 핵심 원칙',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildInfoItem('1. 카테고리별 자산 배분'),
              _buildInfoItem('2. 목표 금액 설정 및 추적'),
              _buildInfoItem('3. 정기적인 리밸런싱'),
              _buildInfoItem('4. 장기 투자 원칙 준수'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '💡 팁: 카테고리 화면에서 각 자산군별 목표 금액을 설정하고, '
                  '꾸준히 투자하여 100% 달성을 목표로 합니다!',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('  • ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MyFolio'),
        actions: [
          // 테스트용 더미 데이터 생성 버튼 (개발 모드에서만 표시)
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.data_usage),
              onPressed: _generateDummyData,
              tooltip: '[DEV] 테스트 데이터 생성',
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer<PortfolioProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.portfolioList.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadPortfolio(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 핵심 지표 4개 카드
                  _buildMetricCards(provider),
                  AppSpacing.verticalSpaceXXL,

                  // 포메뽀꼬 전략 전체 진행률
                  FutureBuilder<Map<String, dynamic>>(
                    future: _loadTotalProgress(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox.shrink();

                      final data = snapshot.data!;
                      final totalTarget = data['totalTarget'] as double;

                      // 목표가 하나도 설정되지 않은 경우 CTA 표시
                      if (totalTarget == 0) {
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryBlue.withValues(alpha: 0.1),
                                    AppColors.primaryBlue.withValues(alpha: 0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: AppSpacing.borderRadiusLG,
                                border: Border.all(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.emoji_events_outlined,
                                      size: 48,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                  AppSpacing.verticalSpaceMD,
                                  Text(
                                    '포메뽀꼬 전략으로',
                                    style: AppTextStyles.headlineMedium.copyWith(
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                  Text(
                                    '목표를 달성해보세요!',
                                    style: AppTextStyles.headlineMedium.copyWith(
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                  AppSpacing.verticalSpaceSM,
                                  Text(
                                    '카테고리별 목표 금액을 설정하고\n투자 진행률을 추적하세요',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                  AppSpacing.verticalSpaceLG,
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        // 카테고리 화면으로 이동
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const CategoryPortfolioScreen(),
                                          ),
                                        );
                                        // 돌아온 후 새로고침
                                        if (mounted) {
                                          await context.read<CategoryProvider>().loadCategories();
                                          setState(() {});
                                        }
                                      },
                                      icon: const Icon(Icons.flag, color: Colors.white),
                                      label: const Text(
                                        '목표 설정하러 가기',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryBlue,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: AppSpacing.borderRadiusMD,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AppSpacing.verticalSpaceXXL,
                          ],
                        );
                      }

                      final totalCurrent = data['totalCurrent'] as double;
                      final progress = (totalCurrent / totalTarget * 100).clamp(0, 100);
                      final remaining = totalTarget - totalCurrent;

                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryBlue,
                                  AppColors.primaryBlue.withValues(alpha: 0.8),
                                ],
                              ),
                              borderRadius: AppSpacing.borderRadiusLG,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '🎯 ',
                                      style: AppTextStyles.headlineMedium,
                                    ),
                                    Text(
                                      '포메뽀꼬 전략 진행률',
                                      style: AppTextStyles.headlineMedium.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.info_outline,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => _showPomebokkoInfo(context),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      tooltip: '포메뽀꼬 전략이란?',
                                    ),
                                  ],
                                ),
                                AppSpacing.verticalSpaceMD,
                                Text(
                                  '${progress.toStringAsFixed(1)}%',
                                  style: AppTextStyles.numberLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                AppSpacing.verticalSpaceSM,
                                Text(
                                  '${formatCurrency(totalCurrent)} / ${formatCurrency(totalTarget)}',
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                AppSpacing.verticalSpaceSM,
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress / 100,
                                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    minHeight: 8,
                                  ),
                                ),
                                AppSpacing.verticalSpaceSM,
                                Text(
                                  '부족 금액: ${formatCurrency(remaining)}',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AppSpacing.verticalSpaceXXL,
                        ],
                      );
                    },
                  ),

                  // 카테고리별 비중 카드
                  Consumer<CategoryProvider>(
                    builder: (context, categoryProvider, child) {
                      if (categoryProvider.categories.isNotEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CategoryAllocationCard(
                              categories: categoryProvider.categories,
                              currentPercentages: categoryProvider.categoryPercentages,
                              targetPercentages: categoryProvider.getTargetPercentages(),
                              onRebalanceTap: () {
                                // TODO: 리밸런싱 가이드 화면으로 이동
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('리밸런싱 가이드 준비 중입니다')),
                                );
                              },
                            ),
                            AppSpacing.verticalSpaceXXL,
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // 수익 추이 차트 - 월 선택
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '수익 추이',
                        style: AppTextStyles.headlineMedium,
                      ),
                      // 월 선택 드롭다운
                      _buildMonthSelector(),
                    ],
                  ),
                  AppSpacing.verticalSpaceLG,

                  // 차트
                  _isLoadingChart
                      ? const Center(child: CircularProgressIndicator())
                      : InvestmentProfitChart(
                          data: _chartData,
                          selectedMonth: _selectedMonth,
                          totalMonthlyProfit: _monthlyTotalProfit,
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 100,
              color: AppColors.neutralGray.withOpacity(0.5),
            ),
            AppSpacing.verticalSpaceXL,
            Text(
              '첫 종목을 추가해보세요',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.primaryText,
              ),
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              '포트폴리오 관리를 시작할 시간입니다',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSpaceXXL,
            ElevatedButton.icon(
              onPressed: () async {
                // 종목 추가 화면으로 직접 이동
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddStockScreen(),
                  ),
                );
                // 돌아온 후 데이터 새로고침
                if (mounted) {
                  await context.read<PortfolioProvider>().loadPortfolio();
                  await _loadChartData();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('종목 추가하기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCards(PortfolioProvider provider) {
    final totalValue = provider.totalMarketValue;
    final totalCost = provider.totalInvestment;
    final totalProfit = totalValue - totalCost;
    final totalProfitRate = totalCost > 0 ? (totalProfit / totalCost) * 100 : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: '총 평가금액',
                value: totalValue.toDouble(),
                icon: Icons.account_balance_wallet_outlined,
              ),
            ),
            AppSpacing.horizontalSpaceMD,
            Expanded(
              child: MetricCard(
                title: '투자원금',
                value: totalCost.toDouble(),
                icon: Icons.payments_outlined,
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpaceMD,
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: '총 수익',
                value: totalProfit.toDouble(),
                percentage: totalProfitRate.toDouble(),
                icon: Icons.trending_up,
              ),
            ),
            AppSpacing.horizontalSpaceMD,
            Expanded(
              child: MetricCard(
                title: '당일 수익',
                value: provider.todayProfit.toDouble(),
                percentage: provider.todayProfitRate.toDouble(),
                icon: Icons.today_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 월 선택 드롭다운 위젯
  Widget _buildMonthSelector() {
    // 최근 6개월 목록 생성
    final months = <Map<String, int>>[];
    final now = DateTime.now();

    for (int i = 0; i < 6; i++) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      months.add({
        'year': targetDate.year,
        'month': targetDate.month,
      });
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: AppSpacing.borderRadiusXS,
      ),
      child: DropdownButton<String>(
        value: '$_selectedYear-$_selectedMonthInt',
        underline: const SizedBox(),
        icon: Icon(
          Icons.arrow_drop_down,
          color: AppColors.primaryText,
        ),
        style: AppTextStyles.bodyMedium,
        items: months.map((month) {
          final year = month['year']!;
          final monthInt = month['month']!;
          return DropdownMenuItem<String>(
            value: '$year-$monthInt',
            child: Text('$year년 $monthInt월'),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            final parts = value.split('-');
            final year = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            _onMonthChanged(year, month);
          }
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _loadTotalProgress() async {
    final db = DatabaseService();
    final categories = await db.getCategories();

    double totalTarget = 0;
    double totalCurrent = 0;

    for (var cat in categories) {
      if (cat.targetAmount != null && cat.targetAmount! > 0) {
        totalTarget += cat.targetAmount!;
        totalCurrent += await db.getCategoryTotalValue(cat.id);
      }
    }

    return {
      'totalTarget': totalTarget,
      'totalCurrent': totalCurrent,
    };
  }
}
