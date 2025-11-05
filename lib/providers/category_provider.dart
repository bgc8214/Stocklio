import 'package:flutter/foundation.dart';
import '../models/category.dart' as app_category;
import '../models/portfolio.dart';
import '../services/database_service.dart';

class CategoryProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  List<app_category.Category> _categories = [];
  final Map<int, List<Portfolio>> _portfoliosByCategory = {};
  Map<int, double> _categoryTotals = {};
  Map<int, double> _categoryPercentages = {};
  bool _isLoading = false;

  List<app_category.Category> get categories => _categories;
  Map<int, List<Portfolio>> get portfoliosByCategory => _portfoliosByCategory;
  Map<int, double> get categoryTotals => _categoryTotals;
  Map<int, double> get categoryPercentages => _categoryPercentages;
  bool get isLoading => _isLoading;

  // 전체 평가금액
  double get totalMarketValue {
    return _categoryTotals.values.fold(0.0, (sum, value) => sum + value);
  }

  // 카테고리별 데이터 로드
  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 카테고리 목록 로드
      _categories = await _db.getCategories();

      // 카테고리별 포트폴리오 로드
      _portfoliosByCategory.clear();
      for (var category in _categories) {
        final portfolios = await _db.getPortfoliosByCategory(category.id);
        _portfoliosByCategory[category.id] = portfolios;
      }

      // 카테고리별 총액 및 비중 계산
      _categoryTotals = await _db.getCategoryTotalValues();
      _categoryPercentages = await _db.getCategoryPercentages();
    } catch (e) {
      debugPrint('카테고리 데이터 로드 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 특정 카테고리의 포트폴리오 개수
  int getPortfolioCount(int categoryId) {
    return _portfoliosByCategory[categoryId]?.length ?? 0;
  }

  // 특정 카테고리의 총 평가금액
  double getCategoryTotal(int categoryId) {
    return _categoryTotals[categoryId] ?? 0.0;
  }

  // 특정 카테고리의 비중
  double getCategoryPercentage(int categoryId) {
    return _categoryPercentages[categoryId] ?? 0.0;
  }

  // 특정 카테고리의 포트폴리오 목록
  List<Portfolio> getCategoryPortfolios(int categoryId) {
    return _portfoliosByCategory[categoryId] ?? [];
  }

  // 카테고리별 목표 비중 (나이/성향에 따라 다름 - 추후 구현)
  Map<int, double> getTargetPercentages({int age = 30, String style = 'balanced'}) {
    // 기본값: 균형형 30대
    if (age < 30) {
      // 20대: 공격적
      return {1: 60.0, 2: 30.0, 3: 10.0}; // 나스닥 60%, S&P500 30%, 배당 10%
    } else if (age < 40) {
      // 30대: 균형
      return {1: 50.0, 2: 30.0, 3: 20.0}; // 나스닥 50%, S&P500 30%, 배당 20%
    } else if (age < 50) {
      // 40대: 안정
      return {1: 30.0, 2: 40.0, 3: 30.0}; // 나스닥 30%, S&P500 40%, 배당 30%
    } else {
      // 50대+: 보수적
      return {1: 20.0, 2: 30.0, 3: 50.0}; // 나스닥 20%, S&P500 30%, 배당 50%
    }
  }

  // 리밸런싱 필요 여부 체크
  bool needsRebalancing({double threshold = 5.0}) {
    final targets = getTargetPercentages();

    for (var categoryId in targets.keys) {
      final current = getCategoryPercentage(categoryId);
      final target = targets[categoryId] ?? 0.0;
      final diff = (current - target).abs();

      if (diff >= threshold) {
        return true;
      }
    }

    return false;
  }

  // 리밸런싱 추천 액션 계산
  Map<int, double> getRebalancingActions() {
    final targets = getTargetPercentages();
    final total = totalMarketValue;

    if (total == 0) return {};

    final Map<int, double> actions = {};

    for (var categoryId in targets.keys) {
      final current = getCategoryTotal(categoryId);
      final target = (targets[categoryId] ?? 0.0) / 100 * total;
      final diff = target - current;

      if (diff.abs() > 1000) {
        // 1000원 이상 차이날 때만
        actions[categoryId] = diff; // 양수면 매수, 음수면 매도
      }
    }

    return actions;
  }
}
