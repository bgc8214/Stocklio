import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../utils/currency_formatter.dart';
import '../widgets/portfolio_summary_card.dart';
import '../widgets/profit_chart.dart';
import 'portfolio_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 로드 시 포트폴리오 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PortfolioProvider>().loadPortfolio();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stocklio'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PortfolioListScreen(),
                ),
              );
            },
            tooltip: '포트폴리오 목록',
          ),
        ],
      ),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 요약 카드들
                  _buildSummaryCards(provider),
                  const SizedBox(height: 24),

                  // 수익 차트
                  Text(
                    '수익 추이',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const ProfitChart(),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 100,
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
            '종목을 추가하여 포트폴리오를 시작하세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PortfolioListScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('종목 추가하기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(PortfolioProvider provider) {
    final totalValue = provider.totalMarketValue;
    final totalCost = provider.totalInvestment;
    final totalProfit = totalValue - totalCost;
    final totalProfitRate = totalCost > 0 ? (totalProfit / totalCost) * 100 : 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: PortfolioSummaryCard(
                title: '총 평가금액',
                value: formatCurrency(totalValue),
                valueColor: Colors.black,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PortfolioSummaryCard(
                title: '총 투자금액',
                value: formatCurrency(totalCost),
                valueColor: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PortfolioSummaryCard(
                title: '총 수익',
                value: formatCurrency(totalProfit),
                subtitle: '${totalProfitRate >= 0 ? '+' : ''}${totalProfitRate.toStringAsFixed(2)}%',
                valueColor: totalProfit >= 0 ? Colors.red : Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PortfolioSummaryCard(
                title: '당일 수익',
                value: formatCurrency(provider.todayProfit),
                subtitle: '${provider.todayProfitRate >= 0 ? '+' : ''}${provider.todayProfitRate.toStringAsFixed(2)}%',
                valueColor: provider.todayProfit >= 0 ? Colors.red : Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
