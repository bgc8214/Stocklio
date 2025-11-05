import 'dart:async';
import 'package:flutter/material.dart';
import '../models/recommended_etf.dart';
import '../data/recommended_etfs.dart';
import '../services/database_service.dart';
import '../models/stock_info.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../utils/error_handler.dart';
import 'add_portfolio_screen.dart';

/// 종목 추가 화면 (추천 ETF + 검색)
class AddStockScreen extends StatefulWidget {
  final int? categoryId; // null이면 "전체" 카테고리로 처리

  const AddStockScreen({
    super.key,
    this.categoryId,
  });

  @override
  State<AddStockScreen> createState() => _AddStockScreenState();
}

class _AddStockScreenState extends State<AddStockScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  final _db = DatabaseService();

  List<StockInfo> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Debouncing이 적용된 검색 실행
  void _performSearch(String query) {
    // 이전 타이머 취소
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    // 빈 쿼리는 즉시 처리
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchQuery = '';
        _isSearching = false;
      });
      return;
    }

    // 로딩 상태 표시
    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });

    // 300ms 대기 후 실제 검색 실행
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _executeSearch(query);
    });
  }

  /// 실제 검색 실행
  Future<void> _executeSearch(String query) async {
    try {
      final results = await _db.searchStocks(query);

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      ErrorHandler.logError('종목 검색', e);
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getUserFriendlyMessage(e)),
            backgroundColor: AppColors.lossRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('종목 추가'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.stars),
              text: '추천 ETF',
            ),
            Tab(
              icon: Icon(Icons.search),
              text: '직접 검색',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRecommendedTab(),
          _buildSearchTab(),
        ],
      ),
    );
  }

  // 추천 ETF 탭
  Widget _buildRecommendedTab() {
    final recommendations = RecommendedETFs.getRecommendations(widget.categoryId ?? 1);
    final usETFs = recommendations.where((e) => e.market == 'US').toList();
    final krETFs = recommendations.where((e) => e.market == 'KR').toList();

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 안내 메시지
          Container(
            padding: AppSpacing.cardPadding,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusLG,
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline, color: AppColors.primaryBlue),
                AppSpacing.horizontalSpaceMD,
                Expanded(
                  child: Text(
                    '이 카테고리에 적합한 ETF를 추천해드립니다.\n원하는 ETF를 선택하세요.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.verticalSpaceXXL,

          // 미국 ETF 섹션
          if (usETFs.isNotEmpty) ...[
            Text(
              '🇺🇸 미국 ETF',
              style: AppTextStyles.headlineMedium,
            ),
            AppSpacing.verticalSpaceMD,
            ...usETFs.map((etf) => _buildRecommendedETFCard(etf)),
            AppSpacing.verticalSpaceXXL,
          ],

          // 한국 ETF 섹션
          if (krETFs.isNotEmpty) ...[
            Text(
              '🇰🇷 한국 상장 ETF',
              style: AppTextStyles.headlineMedium,
            ),
            AppSpacing.verticalSpaceMD,
            ...krETFs.map((etf) => _buildRecommendedETFCard(etf)),
          ],
        ],
      ),
    );
  }

  // 추천 ETF 카드
  Widget _buildRecommendedETFCard(RecommendedETF etf) {
    final isKorean = etf.market == 'KR';
    final marketColor = isKorean ? AppColors.primaryPurple : AppColors.profitGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: AppSpacing.borderRadiusLG,
        border: Border.all(
          color: AppColors.neutralGray.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          // StockInfo로 변환해서 AddPortfolioScreen으로 이동
          final stockInfo = StockInfo(
            ticker: etf.yahooTicker,
            name: etf.name,
            market: etf.market == 'US' ? 'US' : 'KOSPI',
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPortfolioScreen(
                stockInfo: stockInfo,
                categoryId: widget.categoryId,
              ),
            ),
          );
        },
        borderRadius: AppSpacing.borderRadiusLG,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 한국: 종목명 강조, 해외: 티커 강조
                        Text(
                          isKorean ? etf.name : etf.ticker,
                          style: AppTextStyles.titleLarge.copyWith(
                            color: marketColor,
                          ),
                        ),
                        AppSpacing.verticalSpaceXS,
                        Text(
                          isKorean ? etf.ticker : etf.name,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: marketColor.withOpacity(0.1),
                      borderRadius: AppSpacing.borderRadiusXS,
                    ),
                    child: Text(
                      etf.marketLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: marketColor,
                        fontWeight: AppTextStyles.semiBold,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalSpaceMD,
              Text(
                etf.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  height: 1.4,
                ),
              ),
              AppSpacing.verticalSpaceMD,
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _buildInfoChip(
                    '총보수 ${etf.expenseRatioText}',
                    AppColors.warningYellow,
                  ),
                  if (etf.dividendYield != null)
                    _buildInfoChip(
                      '배당 ${etf.dividendYieldText}',
                      AppColors.profitGreen,
                    ),
                  if (etf.features != null)
                    _buildInfoChip(
                      etf.features!,
                      AppColors.primaryBlue,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusXS,
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: AppTextStyles.medium,
        ),
      ),
    );
  }

  // 검색 탭
  Widget _buildSearchTab() {
    return Column(
      children: [
        // 검색 바
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '종목명 또는 티커 검색 (예: 삼성전자, 005930)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              _performSearch(value);
            },
          ),
        ),

        // 검색 결과
        Expanded(
          child: _buildSearchResults(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '종목명 또는 티커를 검색하세요',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '예: 삼성전자, 005930, AAPL',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '검색 결과가 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '"$_searchQuery"에 대한 결과를 찾을 수 없습니다',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final stock = _searchResults[index];
        return ListTile(
          title: Text(
            stock.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(stock.ticker),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPortfolioScreen(
                  stockInfo: stock,
                  categoryId: widget.categoryId,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
