import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/database_service.dart';
import '../utils/currency_formatter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

class RebalancingScreen extends StatefulWidget {
  const RebalancingScreen({super.key});

  @override
  State<RebalancingScreen> createState() => _RebalancingScreenState();
}

class _RebalancingScreenState extends State<RebalancingScreen> {
  final _db = DatabaseService();
  bool _isLoading = true;
  Map<String, dynamic>? _analysis;

  @override
  void initState() {
    super.initState();
    _loadRebalancingAnalysis();
  }

  Future<void> _loadRebalancingAnalysis() async {
    setState(() => _isLoading = true);
    final analysis = await _db.analyzeRebalancing();
    setState(() {
      _analysis = analysis;
      _isLoading = false;
    });
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(
          int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return AppColors.primaryBlue;
    }
  }

  void _copyTradingMemo(List<Map<String, dynamic>> overweight, List<Map<String, dynamic>> underweight) {
    final buffer = StringBuffer();
    buffer.writeln('📊 리밸런싱 매매 메모');
    buffer.writeln('');
    buffer.writeln('📅 ${DateTime.now().toString().substring(0, 10)}');
    buffer.writeln('');

    if (overweight.isNotEmpty) {
      buffer.writeln('🔴 매도:');
      for (var item in overweight) {
        final deviation = item['deviation'] as double;
        buffer.writeln('  ${item['categoryIcon']} ${item['categoryName']}: ${deviation.toStringAsFixed(1)}% 초과');
      }
      buffer.writeln('');
    }

    if (underweight.isNotEmpty) {
      buffer.writeln('🟢 매수:');
      for (var item in underweight) {
        final deviation = item['deviation'] as double;
        buffer.writeln('  ${item['categoryIcon']} ${item['categoryName']}: ${deviation.abs().toStringAsFixed(1)}% 부족');
      }
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('매매 메모가 클립보드에 복사되었습니다'),
        backgroundColor: AppColors.profitGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚖️ 리밸런싱'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRebalancingAnalysis,
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
    if (_analysis == null) {
      return _buildEmptyState();
    }

    final needsRebalancing = _analysis!['needsRebalancing'] as bool;
    final suggestions = _analysis!['suggestions'] as List<Map<String, dynamic>>;
    final totalValue = _analysis!['totalValue'] as double;

    if (suggestions.isEmpty) {
      return _buildNoGoalsState();
    }

    if (!needsRebalancing) {
      return _buildBalancedState(suggestions, totalValue);
    }

    // 리밸런싱 필요
    final overweight = suggestions.where((s) =>
        s['needsRebalancing'] == true && s['deviation'] > 0).toList();
    final underweight = suggestions.where((s) =>
        s['needsRebalancing'] == true && s['deviation'] < 0).toList();

    return RefreshIndicator(
      onRefresh: _loadRebalancingAnalysis,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 경고 메시지
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusLG,
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '리밸런싱 필요!',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.orange.shade900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '목표 비중에서 ±5% 이상 벗어난 카테고리가 있습니다',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalSpaceXL,

            // 현재 비중 vs 목표 비중
            Text(
              '현재 비중',
              style: AppTextStyles.headlineMedium,
            ),
            AppSpacing.verticalSpaceMD,

            ...suggestions.map((s) => _buildWeightCard(s)),

            AppSpacing.verticalSpaceXL,

            // 추천 액션
            if (overweight.isNotEmpty || underweight.isNotEmpty) ...[
              Text(
                '📋 추천 액션',
                style: AppTextStyles.headlineMedium,
              ),
              AppSpacing.verticalSpaceMD,

              if (overweight.isNotEmpty) ...[
                _buildActionSection(
                  '🔴 비중 초과 - 매도 고려',
                  overweight,
                  Colors.red,
                ),
                AppSpacing.verticalSpaceMD,
              ],

              if (underweight.isNotEmpty) ...[
                _buildActionSection(
                  '🟢 비중 부족 - 매수 고려',
                  underweight,
                  AppColors.profitGreen,
                ),
                AppSpacing.verticalSpaceMD,
              ],

              AppSpacing.verticalSpaceLG,

              // 매매 메모 복사 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _copyTradingMemo(overweight, underweight),
                  icon: const Icon(Icons.content_copy, color: Colors.white),
                  label: const Text(
                    '매매 메모 복사하기',
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

            AppSpacing.verticalSpaceXXL,

            // 안내 문구
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: AppSpacing.borderRadiusMD,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      Text(
                        '리밸런싱 팁',
                        style: AppTextStyles.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 리밸런싱은 분기별(3개월)로 하는 것을 추천합니다\n'
                    '• 세금과 수수료를 고려하여 신중하게 결정하세요\n'
                    '• 비중 조정은 매도보다 매수로 하는 것이 유리합니다',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightCard(Map<String, dynamic> suggestion) {
    final categoryName = suggestion['categoryName'] as String;
    final categoryIcon = suggestion['categoryIcon'] as String;
    final categoryColor = suggestion['categoryColor'] as String;
    final currentWeight = suggestion['currentWeight'] as double;
    final targetWeight = suggestion['targetWeight'] as double;
    final deviation = suggestion['deviation'] as double;
    final needsRebalancing = suggestion['needsRebalancing'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusMD,
        border: Border.all(
          color: needsRebalancing
              ? Colors.orange.withValues(alpha: 0.5)
              : Colors.grey.withValues(alpha: 0.2),
          width: needsRebalancing ? 2 : 1,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    categoryIcon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    categoryName,
                    style: AppTextStyles.titleMedium,
                  ),
                ],
              ),
              if (needsRebalancing)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    deviation > 0 ? '초과' : '부족',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '현재 비중',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${currentWeight.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Icon(
                needsRebalancing
                    ? Icons.arrow_forward
                    : Icons.check_circle_outline,
                color: needsRebalancing ? Colors.orange : AppColors.profitGreen,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '목표 비중',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${targetWeight.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _parseColor(categoryColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (needsRebalancing) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    deviation > 0
                        ? '▲ ${deviation.toStringAsFixed(1)}% 초과'
                        : '▼ ${deviation.abs().toStringAsFixed(1)}% 부족',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionSection(
    String title,
    List<Map<String, dynamic>> items,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: AppSpacing.borderRadiusMD,
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(color: color),
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            final adjustmentAmount = (item['targetValue'] - item['currentValue']).abs();
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    item['categoryIcon'] as String,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['categoryName'] as String,
                          style: AppTextStyles.titleMedium,
                        ),
                        Text(
                          '약 ${formatCurrency(adjustmentAmount)} 조정 필요',
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
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBalancedState(List<Map<String, dynamic>> suggestions, double totalValue) {
    return Center(
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.profitGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 80,
                color: AppColors.profitGreen,
              ),
            ),
            AppSpacing.verticalSpaceXL,
            Text(
              '완벽한 균형!',
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.profitGreen,
              ),
            ),
            AppSpacing.verticalSpaceMD,
            Text(
              '모든 카테고리가 목표 비중 범위 내에 있습니다',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge,
            ),
            AppSpacing.verticalSpaceXXL,
            ...suggestions.map((s) => _buildWeightCard(s)),
          ],
        ),
      ),
    );
  }

  Widget _buildNoGoalsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            '목표 비중을 설정해주세요',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '카테고리별 목표 비중을 설정하면\n리밸런싱 분석을 제공합니다',
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            '데이터를 불러올 수 없습니다',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
