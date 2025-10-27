import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/stock_info.dart';
import '../models/portfolio.dart';
import '../providers/portfolio_provider.dart';
import '../utils/currency_formatter.dart';

class AddPortfolioScreen extends StatefulWidget {
  final StockInfo? stockInfo;
  final Portfolio? portfolio;

  const AddPortfolioScreen({
    super.key,
    this.stockInfo,
    this.portfolio,
  });

  @override
  State<AddPortfolioScreen> createState() => _AddPortfolioScreenState();
}

class _AddPortfolioScreenState extends State<AddPortfolioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _averagePriceController = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.portfolio != null;

    if (_isEditing) {
      _quantityController.text = widget.portfolio!.quantity.toString();
      _averagePriceController.text = widget.portfolio!.averagePrice.toString();
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
        );

        if (mounted) {
          final messenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);
          messenger.showSnackBar(
            const SnackBar(content: Text('종목이 추가되었습니다')),
          );
          navigator.pop();
          if (!_isEditing) {
            // 추가 후에는 검색 화면도 닫기
            navigator.pop();
          }
        }
      }

      // 네비게이션 처리 통합
      if (mounted) {
        final navigator = Navigator.of(context);
        navigator.pop();
        if (!_isEditing) {
          // 추가 후에는 검색 화면도 닫기
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
        content: Text('$_stockName을(를) 삭제하시겠습니까?'),
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
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);
        messenger.showSnackBar(
          const SnackBar(content: Text('종목이 삭제되었습니다')),
        );
        navigator.pop();
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '종목 수정' : '종목 추가'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: _isEditing
            ? [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _isSaving ? null : _deletePortfolio,
                  tooltip: '삭제',
                ),
              ]
            : null,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 종목 정보 카드
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _stockName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _ticker,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

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
            const SizedBox(height: 16),

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
            const SizedBox(height: 24),

            // 총 투자금액 표시
            if (totalCost != null)
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '총 투자금액',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatCurrency(totalCost),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // 저장 버튼
            ElevatedButton(
              onPressed: _isSaving ? null : _savePortfolio,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _isEditing ? '수정하기' : '추가하기',
                      style: const TextStyle(fontSize: 16),
                    ),
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
}
