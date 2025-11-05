import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/stock_info.dart';
import '../models/portfolio.dart';
import '../providers/portfolio_provider.dart';
import '../services/yahoo_finance_service.dart';
import '../utils/currency_formatter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

class AddPortfolioScreen extends StatefulWidget {
  final StockInfo? stockInfo;
  final Portfolio? portfolio;
  final int? categoryId;

  const AddPortfolioScreen({
    super.key,
    this.stockInfo,
    this.portfolio,
    this.categoryId,
  });

  @override
  State<AddPortfolioScreen> createState() => _AddPortfolioScreenState();
}

class _AddPortfolioScreenState extends State<AddPortfolioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _averagePriceController = TextEditingController();
  final _yahooFinance = YahooFinanceService();

  bool _isEditing = false;
  bool _isSaving = false;
  bool _isLoadingPrice = false;
  double? _currentPrice;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.portfolio != null;

    if (_isEditing) {
      _quantityController.text = widget.portfolio!.quantity.toString();
      _averagePriceController.text = widget.portfolio!.averagePrice.toString();
      _currentPrice = widget.portfolio!.currentPrice;
    } else {
      _loadCurrentPrice();
    }
  }

  Future<void> _loadCurrentPrice() async {
    if (widget.stockInfo == null) return;

    setState(() => _isLoadingPrice = true);

    try {
      final price = await _yahooFinance.getCurrentPrice(_ticker);
      if (price != null && mounted) {
        setState(() {
          _currentPrice = price;
          // 평균 단가 기본값으로 현재가 설정
          if (_averagePriceController.text.isEmpty) {
            _averagePriceController.text = price.toStringAsFixed(0);
          }
        });
      }
    } catch (e) {
      debugPrint('현재가 로드 실패: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingPrice = false);
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _averagePriceController.dispose();
    super.dispose();
  }

  String get _ticker {
    if (widget.portfolio != null) return widget.portfolio!.ticker;
    if (widget.stockInfo != null) return widget.stockInfo!.ticker;
    return '';
  }

  String get _stockName {
    if (widget.portfolio != null) return widget.portfolio!.stockName;
    if (widget.stockInfo != null) return widget.stockInfo!.name;
    return '';
  }

  Future<void> _savePortfolio() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final quantity = int.parse(_quantityController.text);
      final averagePrice = double.parse(_averagePriceController.text);

      final provider = context.read<PortfolioProvider>();

      if (_isEditing) {
        // 수정
        await provider.updatePortfolio(
          widget.portfolio!.id!,
          quantity,
          averagePrice,
        );

        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          messenger.showSnackBar(
            const SnackBar(content: Text('종목이 수정되었습니다')),
          );
        }
      } else {
        // 추가
        await provider.addPortfolio(
          ticker: _ticker,
          stockName: _stockName,
          quantity: quantity,
          averagePrice: averagePrice,
          categoryId: widget.categoryId,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('종목이 추가되었습니다')),
          );
        }
      }

      // 네비게이션 처리
      if (mounted) {
        final navigator = Navigator.of(context);
        navigator.pop(); // 현재 화면(추가/수정 화면) 닫기
        if (!_isEditing) {
          // 추가 시에는 검색 화면도 닫기
          navigator.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deletePortfolio() async {
    if (!_isEditing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('종목 삭제'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('다음 종목을 삭제하시겠습니까?'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _stockName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('티커: $_ticker'),
                  Text('보유 수량: ${_quantityController.text}주'),
                  Text('평균 단가: ${formatCurrency(double.tryParse(_averagePriceController.text) ?? 0)}'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '⚠️ 이 작업은 되돌릴 수 없습니다.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSaving = true);

    try {
      await context.read<PortfolioProvider>().deletePortfolio(widget.portfolio!.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('종목이 삭제되었습니다')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          SnackBar(content: Text('삭제 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCost = _calculateTotalCost();
    final isKorean = _ticker.endsWith('.KS') || _ticker.endsWith('.KQ');

    // 시장 구분
    String marketLabel = '';
    Color marketColor = AppColors.neutralGray;

    if (_ticker.endsWith('.KS')) {
      marketLabel = 'KOSPI';
      marketColor = AppColors.primaryBlue;
    } else if (_ticker.endsWith('.KQ')) {
      marketLabel = 'KOSDAQ';
      marketColor = AppColors.primaryPurple;
    } else {
      marketLabel = 'US';
      marketColor = AppColors.profitGreen;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '종목 수정' : '종목 추가'),
        actions: _isEditing
            ? [
                IconButton(
                  icon: Icon(Icons.delete, color: AppColors.lossRed),
                  onPressed: _isSaving ? null : _deletePortfolio,
                  tooltip: '삭제',
                ),
              ]
            : null,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            // 종목 정보 카드 (현재가 포함)
            Container(
              padding: AppSpacing.cardPadding,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 시장 배지
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
                      marketLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: marketColor,
                        fontWeight: AppTextStyles.semiBold,
                      ),
                    ),
                  ),
                  AppSpacing.verticalSpaceMD,
                  // 종목명
                  Text(
                    isKorean ? _stockName : _ticker.replaceAll(RegExp(r'\.(KS|KQ)$'), ''),
                    style: AppTextStyles.headlineMedium,
                  ),
                  AppSpacing.verticalSpaceXS,
                  Text(
                    isKorean ? _ticker.replaceAll(RegExp(r'\.(KS|KQ)$'), '') : _stockName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),

                  // 현재가 정보
                  if (_currentPrice != null) ...[
                    AppSpacing.verticalSpaceLG,
                    Container(
                      padding: AppSpacing.cardPadding,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBackground,
                        borderRadius: AppSpacing.borderRadiusMD,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '💰 현재가',
                                style: AppTextStyles.labelSmall,
                              ),
                              AppSpacing.verticalSpaceXS,
                              Text(
                                formatCurrency(_currentPrice!),
                                style: AppTextStyles.numberMedium.copyWith(
                                  fontSize: 22,
                                ),
                              ),
                            ],
                          ),
                          // TODO: 전일대비 정보 (나중에 추가)
                        ],
                      ),
                    ),
                  ] else if (_isLoadingPrice) ...[
                    AppSpacing.verticalSpaceLG,
                    const Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                          SizedBox(height: 12),
                          Text(
                            '현재가를 불러오는 중...',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AppSpacing.verticalSpaceXXL,

            // 보유 수량 입력
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: '보유 수량',
                hintText: '예: 10',
                suffixText: '주',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '보유 수량을 입력하세요';
                }
                final quantity = int.tryParse(value);
                if (quantity == null || quantity <= 0) {
                  return '올바른 수량을 입력하세요';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            AppSpacing.verticalSpaceLG,

            // 평균 단가 입력
            TextFormField(
              controller: _averagePriceController,
              decoration: const InputDecoration(
                labelText: '평균 단가',
                hintText: '예: 50000',
                suffixText: '원',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '평균 단가를 입력하세요';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return '올바른 금액을 입력하세요';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            AppSpacing.verticalSpaceXXL,

            // 실시간 계산 결과 (추가 후 포트폴리오)
            if (totalCost != null && _currentPrice != null)
              _buildPortfolioPreview(totalCost),

            if (totalCost != null && _currentPrice != null)
              AppSpacing.verticalSpaceXXL,

            // 저장 버튼
            ElevatedButton(
              onPressed: _isSaving ? null : _savePortfolio,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_isEditing ? '수정하기' : '추가하기'),
            ),
          ],
        ),
      ),
    );
  }

  double? _calculateTotalCost() {
    final quantityText = _quantityController.text;
    final priceText = _averagePriceController.text;

    if (quantityText.isEmpty || priceText.isEmpty) return null;

    final quantity = int.tryParse(quantityText);
    final price = double.tryParse(priceText);

    if (quantity == null || price == null) return null;

    return quantity * price;
  }

  // 포트폴리오 미리보기 위젯
  Widget _buildPortfolioPreview(double totalCost) {
    final quantityText = _quantityController.text;
    final priceText = _averagePriceController.text;

    if (quantityText.isEmpty || priceText.isEmpty || _currentPrice == null) {
      return const SizedBox.shrink();
    }

    final quantity = int.tryParse(quantityText);
    final avgPrice = double.tryParse(priceText);

    if (quantity == null || avgPrice == null) {
      return const SizedBox.shrink();
    }

    // 계산
    final currentValue = quantity * _currentPrice!;
    final profit = currentValue - totalCost;
    final profitPercent = (profit / totalCost) * 100;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.primaryBackground,
        borderRadius: AppSpacing.borderRadiusLG,
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              AppSpacing.horizontalSpaceSM,
              Text(
                '📊 추가 후 포트폴리오',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceLG,

          // 투자금액
          _buildPreviewRow(
            '투자금액',
            formatCurrency(totalCost),
            AppColors.secondaryText,
          ),
          AppSpacing.verticalSpaceMD,

          // 현재가치
          _buildPreviewRow(
            '현재가치',
            formatCurrency(currentValue),
            AppColors.primaryText,
          ),
          AppSpacing.verticalSpaceMD,

          // 구분선
          Divider(color: AppColors.neutralGray.withOpacity(0.2)),
          AppSpacing.verticalSpaceMD,

          // 예상 수익
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '예상 수익',
                style: AppTextStyles.titleMedium,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatCurrency(profit),
                    style: AppTextStyles.numberMedium.copyWith(
                      color: AppColors.getProfitLossColor(profit),
                      fontSize: 20,
                    ),
                  ),
                  AppSpacing.verticalSpaceXS,
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.getProfitLossColorWithOpacity(profit, 0.1),
                      borderRadius: AppSpacing.borderRadiusXS,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          profit >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 14,
                          color: AppColors.getProfitLossColor(profit),
                        ),
                        AppSpacing.horizontalSpaceXS,
                        Text(
                          '${profitPercent.abs().toStringAsFixed(2)}%',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.getProfitLossColor(profit),
                            fontWeight: AppTextStyles.semiBold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium,
        ),
        Text(
          value,
          style: AppTextStyles.numberSmall.copyWith(
            color: valueColor,
            fontWeight: AppTextStyles.semiBold,
          ),
        ),
      ],
    );
  }
}
