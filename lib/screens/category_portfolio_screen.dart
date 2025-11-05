import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/portfolio.dart';
import '../models/category.dart';
import '../utils/currency_formatter.dart';
import '../services/database_service.dart';
import 'add_portfolio_screen.dart';
import 'add_stock_screen.dart';
import 'category_goal_setting_screen.dart';

class CategoryPortfolioScreen extends StatefulWidget {
  const CategoryPortfolioScreen({super.key});

  @override
  State<CategoryPortfolioScreen> createState() => _CategoryPortfolioScreenState();
}

class _CategoryPortfolioScreenState extends State<CategoryPortfolioScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    // 카테고리 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CategoryProvider>();
      provider.loadCategories().then((_) {
        if (mounted && provider.categories.isNotEmpty) {
          _tabController = TabController(
            length: provider.categories.length,
            vsync: this,
          );
          setState(() {});
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('카테고리별 포트폴리오'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.categories.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('카테고리별 포트폴리오'),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            body: _buildEmptyState(context),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('카테고리별 포트폴리오'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            actions: [
              IconButton(
                icon: const Icon(Icons.flag),
                tooltip: '목표 설정',
                onPressed: _tabController == null ? null : () async {
                  // 현재 탭의 카테고리 가져오기
                  final currentIndex = _tabController!.index;
                  final currentCategory = provider.categories[currentIndex];

                  final needsRefresh = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryGoalSettingScreen(
                        category: currentCategory,
                      ),
                    ),
                  );

                  if (needsRefresh == true && mounted) {
                    // 목표 설정 후 카테고리 Provider 새로고침
                    await provider.loadCategories();
                  }
                },
              ),
            ],
            bottom: _tabController == null ? null : TabBar(
              controller: _tabController,
              tabs: provider.categories.map((category) {
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(category.icon),
                      const SizedBox(width: 8),
                      Text(category.displayName),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          body: _tabController == null
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: provider.categories.map((category) {
                    return _buildCategoryTab(context, provider, category);
            }).toList(),
          ),
          floatingActionButton: _tabController == null
              ? null
              : FloatingActionButton.extended(
                  onPressed: () async {
                    // 현재 탭의 카테고리 ID 가져오기
                    final currentIndex = _tabController!.index;
                    final currentCategory = provider.categories[currentIndex];

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddStockScreen(
                          categoryId: currentCategory.id,
                        ),
                      ),
                    );

                    // 돌아온 후 데이터 새로고침
                    if (mounted) {
                      await provider.loadCategories();
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('종목 추가'),
                ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            '카테고리가 없습니다',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '카테고리 데이터를 확인해주세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(
    BuildContext context,
    CategoryProvider provider,
    Category category,
  ) {
    final portfolios = provider.getCategoryPortfolios(category.id);
    final categoryTotal = provider.getCategoryTotal(category.id);
    final categoryPercentage = provider.getCategoryPercentage(category.id);
    final targetPercentage =
        provider.getTargetPercentages()[category.id] ?? 0.0;

    return RefreshIndicator(
      onRefresh: () => provider.loadCategories(),
      child: Column(
        children: [
          // 카테고리 요약 헤더
          Container(
            padding: const EdgeInsets.all(16),
            color: _parseColor(category.color).withValues(alpha: 0.1),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${category.icon} ${category.displayName}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatCurrency(categoryTotal),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${categoryPercentage.toStringAsFixed(1)}% / ${targetPercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 8,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          color: Colors.grey[300],
                        ),
                        FractionallySizedBox(
                          widthFactor:
                              (categoryPercentage / 100).clamp(0.0, 1.0),
                          child: Container(
                            color: _parseColor(category.color),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 목표 진행률 표시
          FutureBuilder<Map<String, dynamic>>(
            future: _loadCategoryProgress(category),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();

              final data = snapshot.data!;
              final currentValue = data['currentValue'] as double;
              final targetAmount = data['targetAmount'] as double?;

              // 목표가 설정되지 않은 경우 안내 카드 표시
              if (targetAmount == null || targetAmount == 0) {
                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _parseColor(category.color).withValues(alpha: 0.15),
                        _parseColor(category.color).withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _parseColor(category.color).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _parseColor(category.color).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.flag_outlined,
                              color: _parseColor(category.color),
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '목표를 설정해보세요!',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '"n억 모으기" 목표로 동기부여 받기',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final needsRefresh = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CategoryGoalSettingScreen(
                                  category: category,
                                ),
                              ),
                            );

                            if (needsRefresh == true && mounted) {
                              await context.read<CategoryProvider>().loadCategories();
                              setState(() {});
                            }
                          },
                          icon: const Icon(Icons.add_task, color: Colors.white),
                          label: const Text(
                            '목표 설정하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _parseColor(category.color),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final progress = (currentValue / targetAmount * 100).clamp(0, 100);
              final remaining = targetAmount - currentValue;

              return Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${formatCurrency(targetAmount)} 모으기',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${progress.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _parseColor(category.color),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _parseColor(category.color),
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '현재: ${formatCurrency(currentValue)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          '부족: ${formatCurrency(remaining)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // 종목 리스트
          Expanded(
            child: portfolios.isEmpty
                ? _buildEmptyCategoryState(context, category)
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: portfolios.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final portfolio = portfolios[index];
                      return _buildPortfolioCard(context, portfolio);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCategoryState(BuildContext context, Category category) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '${category.displayName} 카테고리에\n보유 종목이 없습니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '아래 버튼을 눌러 종목을 추가하세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioCard(BuildContext context, Portfolio portfolio) {
    final currentValue = portfolio.currentPrice * portfolio.quantity;
    final investmentCost = portfolio.averagePrice * portfolio.quantity;
    final profit = currentValue - investmentCost;
    final profitRate =
        investmentCost > 0 ? (profit / investmentCost) * 100 : 0;

    return Card(
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPortfolioScreen(portfolio: portfolio),
            ),
          );
          // 돌아온 후 데이터 새로고침
          if (mounted) {
            await context.read<CategoryProvider>().loadCategories();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          portfolio.stockName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          portfolio.ticker,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatCurrency(currentValue),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${profit >= 0 ? '+' : ''}${formatCurrency(profit)} (${profitRate >= 0 ? '+' : ''}${profitRate.toStringAsFixed(2)}%)',
                        style: TextStyle(
                          fontSize: 14,
                          color: profit >= 0 ? Colors.red : Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailItem('보유수량', '${portfolio.quantity}주'),
                  _buildDetailItem(
                      '평균단가', formatCurrency(portfolio.averagePrice)),
                  _buildDetailItem(
                      '현재가', formatCurrency(portfolio.currentPrice)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(
          int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.blue;
    }
  }

  Future<Map<String, dynamic>> _loadCategoryProgress(Category category) async {
    final db = DatabaseService();
    final currentValue = await db.getCategoryTotalValue(category.id);
    final categories = await db.getCategories();
    final cat = categories.firstWhere((c) => c.id == category.id);

    return {
      'currentValue': currentValue,
      'targetAmount': cat.targetAmount,
    };
  }
}
