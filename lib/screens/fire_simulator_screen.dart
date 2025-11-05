import 'package:flutter/material.dart';
import '../models/fire_calculator.dart';
import '../services/database_service.dart';
import '../utils/currency_formatter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

class FireSimulatorScreen extends StatefulWidget {
  const FireSimulatorScreen({super.key});

  @override
  State<FireSimulatorScreen> createState() => _FireSimulatorScreenState();
}

class _FireSimulatorScreenState extends State<FireSimulatorScreen> {
  final _db = DatabaseService();
  final _monthlyExpenseController = TextEditingController(text: '4000000');
  final _monthlyInvestmentController = TextEditingController(text: '1000000');

  double _currentAsset = 0;
  double _annualDividend = 0;
  FireSimulation? _simulation;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _monthlyExpenseController.dispose();
    _monthlyInvestmentController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final totalValue = await _db.getTotalPortfolioValue();
    final currentYear = DateTime.now().year;
    final annualDividend = await _db.getAnnualDividendTotal(currentYear);

    setState(() {
      _currentAsset = totalValue;
      _annualDividend = annualDividend;
    });

    _calculateSimulation();
  }

  void _calculateSimulation() {
    final monthlyExpense = double.tryParse(_monthlyExpenseController.text) ?? 0;
    final monthlyInvestment =
        double.tryParse(_monthlyInvestmentController.text) ?? 0;

    if (monthlyExpense <= 0) {
      setState(() => _simulation = null);
      return;
    }

    final simulation = FireSimulation.calculate(
      currentAsset: _currentAsset,
      monthlyExpense: monthlyExpense,
      monthlyInvestment: monthlyInvestment,
    );

    setState(() => _simulation = simulation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔥 Fire 전략'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 설명 카드
            _buildInfoCard(),
            AppSpacing.verticalSpaceXL,

            // 입력 섹션
            _buildInputSection(),
            AppSpacing.verticalSpaceXL,

            // 시뮬레이션 결과
            if (_simulation != null) ...[
              _buildSimulationResult(),
              AppSpacing.verticalSpaceXL,
              _buildCashFlowSection(),
              AppSpacing.verticalSpaceXL,
              _buildTimelineSection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.1),
            Colors.orange.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: AppSpacing.borderRadiusLG,
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                'Fire 전략이란?',
                style: AppTextStyles.titleLarge,
              ),
            ],
          ),
          AppSpacing.verticalSpaceSM,
          Text(
            'Financial Independence, Retire Early\n'
            '경제적 자유를 달성하여 조기 은퇴하는 전략입니다.',
            style: AppTextStyles.bodyMedium,
          ),
          AppSpacing.verticalSpaceSM,
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: AppSpacing.borderRadiusMD,
            ),
            child: Text(
              '4% 인출 룰: 연간 생활비 = 총 자산 × 4%\n'
              '즉, 총 자산 = 연간 생활비 × 25',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '목표 설정',
          style: AppTextStyles.headlineMedium,
        ),
        AppSpacing.verticalSpaceMD,

        // 현재 자산 표시
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: AppSpacing.borderRadiusMD,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '현재 총 자산',
                style: AppTextStyles.titleMedium,
              ),
              Text(
                formatCurrency(_currentAsset),
                style: AppTextStyles.numberMedium.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),
        AppSpacing.verticalSpaceMD,

        // 월 생활비 입력
        Text('월 목표 생활비', style: AppTextStyles.titleMedium),
        AppSpacing.verticalSpaceSM,
        TextField(
          controller: _monthlyExpenseController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '예: 4000000 (400만원)',
            suffixText: '원',
            border: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusMD,
            ),
          ),
          onChanged: (_) => _calculateSimulation(),
        ),
        AppSpacing.verticalSpaceMD,

        // 월 투자 금액 입력
        Text('월 투자 금액', style: AppTextStyles.titleMedium),
        AppSpacing.verticalSpaceSM,
        TextField(
          controller: _monthlyInvestmentController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '예: 1000000 (100만원)',
            suffixText: '원',
            border: OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusMD,
            ),
          ),
          onChanged: (_) => _calculateSimulation(),
        ),
      ],
    );
  }

  Widget _buildSimulationResult() {
    final sim = _simulation!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: sim.isAchieved
              ? [
                  AppColors.profitGreen,
                  AppColors.profitGreen.withValues(alpha: 0.8),
                ]
              : [
                  AppColors.primaryBlue,
                  AppColors.primaryBlue.withValues(alpha: 0.8),
                ],
        ),
        borderRadius: AppSpacing.borderRadiusLG,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sim.isAchieved ? '🎉 Fire 달성!' : '🎯 Fire 진행률',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
            ),
          ),
          AppSpacing.verticalSpaceMD,

          // 진행률
          Text(
            '${sim.progress.toStringAsFixed(1)}%',
            style: AppTextStyles.numberLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 48,
            ),
          ),
          AppSpacing.verticalSpaceSM,

          // 진행 바
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: sim.progress / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          AppSpacing.verticalSpaceMD,

          // 현재 vs 목표
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '현재 자산',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  Text(
                    formatCurrency(sim.currentAsset),
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '목표 자산',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  Text(
                    formatCurrency(sim.targetAsset),
                    style: AppTextStyles.titleLarge.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          AppSpacing.verticalSpaceSM,

          if (!sim.isAchieved)
            Text(
              '부족: ${formatCurrency(sim.remainingAsset)}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCashFlowSection() {
    final sim = _simulation!;
    final monthlyDividend = _annualDividend / 12;
    final dividendCoverage = FireCalculator.calculateDividendCoverageRatio(
      _annualDividend,
      sim.monthlyExpense,
    );
    final withdrawalNeeded = FireCalculator.calculateMonthlyWithdrawalNeeded(
      sim.monthlyExpense,
      monthlyDividend,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💰 월 현금흐름 시뮬레이션',
          style: AppTextStyles.headlineMedium,
        ),
        AppSpacing.verticalSpaceMD,

        // 현재 상태
        _buildCashFlowCard(
          '현재',
          sim.currentMonthlyIncome,
          monthlyDividend,
          withdrawalNeeded,
          dividendCoverage,
          false,
        ),
        AppSpacing.verticalSpaceMD,

        // 목표 달성 시
        _buildCashFlowCard(
          'Fire 달성 시',
          sim.targetMonthlyIncome,
          monthlyDividend,
          0,
          dividendCoverage,
          true,
        ),
      ],
    );
  }

  Widget _buildCashFlowCard(
    String title,
    double monthlyIncome,
    double monthlyDividend,
    double withdrawalNeeded,
    double dividendCoverage,
    bool isTarget,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isTarget ? Colors.green[50] : Colors.grey[100],
        borderRadius: AppSpacing.borderRadiusMD,
        border: Border.all(
          color: isTarget
              ? AppColors.profitGreen.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleLarge,
          ),
          AppSpacing.verticalSpaceSM,

          _buildCashFlowRow('배당 수익', monthlyDividend, AppColors.profitGreen),
          _buildCashFlowRow('필요 인출', withdrawalNeeded, Colors.orange),
          const Divider(),
          _buildCashFlowRow('총 생활비', monthlyIncome, AppColors.primaryBlue,
              isBold: true),

          if (_annualDividend > 0) ...[
            AppSpacing.verticalSpaceSM,
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.profitGreen.withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusMD,
              ),
              child: Text(
                '배당금으로 ${dividendCoverage.toStringAsFixed(1)}% 커버',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.profitGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCashFlowRow(String label, double amount, Color color,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: isBold ? FontWeight.bold : null,
            ),
          ),
          Text(
            formatCurrency(amount),
            style: AppTextStyles.numberMedium.copyWith(
              color: color,
              fontWeight: isBold ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    final sim = _simulation!;

    if (sim.isAchieved) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.profitGreen.withValues(alpha: 0.1),
          borderRadius: AppSpacing.borderRadiusLG,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.emoji_events,
              size: 64,
              color: AppColors.profitGreen,
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              '축하합니다!',
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.profitGreen,
              ),
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              '이미 Fire를 달성하셨습니다.\n조기 은퇴의 꿈을 이루셨네요! 🎉',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
          ],
        ),
      );
    }

    if (!sim.isAchievable) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: AppSpacing.borderRadiusLG,
        ),
        child: Column(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: Colors.orange,
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              '월 투자 금액을 입력해주세요',
              style: AppTextStyles.titleLarge,
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              '목표 달성 시기를 계산하려면\n월 투자 금액이 필요합니다.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📅 달성 예상 시기',
          style: AppTextStyles.headlineMedium,
        ),
        AppSpacing.verticalSpaceMD,

        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.withValues(alpha: 0.1),
                Colors.purple.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: AppSpacing.borderRadiusLG,
          ),
          child: Column(
            children: [
              Text(
                '${sim.fireYear}년',
                style: AppTextStyles.numberLarge.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              Text(
                '약 ${sim.yearsToFire!.toStringAsFixed(1)}년 후',
                style: AppTextStyles.titleLarge.copyWith(
                  color: Colors.purple,
                ),
              ),
              AppSpacing.verticalSpaceLG,

              _buildTimelineItem(
                '월 ${formatCurrency(sim.monthlyInvestment)} 투자',
                '연 7% 수익률 가정',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.purple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
