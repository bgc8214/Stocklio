# 🚀 다음 작업 단계 - 포메뽀꼬 전략 목표 설정 기능

**마지막 업데이트**: 2025년 11월 3일
**현재 상태**: DB 마이그레이션 완료, 다음은 DatabaseService 메서드 추가

---

## ✅ 현재까지 완료된 작업

1. ✅ **Category 모델 확장** ([lib/models/category.dart](lib/models/category.dart))
   - `targetAmount` (목표 금액) 필드 추가
   - `targetWeight` (목표 비중 %) 필드 추가
   - `fromMap`, `toMap` 업데이트

2. ✅ **DB 마이그레이션** ([lib/services/database_service.dart](lib/services/database_service.dart))
   - DB 버전 3 → 4로 업그레이드
   - `categories` 테이블에 컬럼 추가:
     - `target_amount REAL`
     - `target_weight REAL`

---

## 🎯 다음 작업 (순서대로)

### Step 1: DatabaseService에 메서드 추가 (5분)

**파일**: `lib/services/database_service.dart`
**위치**: 파일 끝 (724라인 이전, `}` 바로 위)

```dart
  // ==================== 목표 설정 (포메뽀꼬 전략) ====================

  /// 카테고리 목표 업데이트
  Future<void> updateCategoryGoals({
    required int categoryId,
    double? targetAmount,
    double? targetWeight,
  }) async {
    final db = await database;
    await db.update(
      'categories',
      {
        'target_amount': targetAmount,
        'target_weight': targetWeight,
      },
      where: 'id = ?',
      whereArgs: [categoryId],
    );
  }

  /// 카테고리별 현재 총 금액 조회
  Future<double> getCategoryTotalValue(int categoryId) async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT SUM(p.quantity * COALESCE(p.current_price, p.average_cost)) as total
      FROM portfolios p
      WHERE p.category_id = ?
    ''', [categoryId]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// 전체 포트폴리오 총액 조회
  Future<double> getTotalPortfolioValue() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT SUM(quantity * COALESCE(current_price, average_cost)) as total
      FROM portfolios
      WHERE category_id IS NOT NULL
    ''');

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// 카테고리별 현재 비중 계산
  Future<Map<int, double>> getCategoryWeights() async {
    final totalValue = await getTotalPortfolioValue();

    if (totalValue == 0) return {};

    final categories = await getCategories();
    final Map<int, double> weights = {};

    for (var category in categories) {
      final categoryValue = await getCategoryTotalValue(category.id);
      weights[category.id] = (categoryValue / totalValue) * 100;
    }

    return weights;
  }
}
```

### Step 2: 목표 설정 화면 생성 (30분)

**파일**: `lib/screens/category_goal_setting_screen.dart` (새 파일 생성)

[PROGRESS_POMEBOKKO.md](PROGRESS_POMEBOKKO.md) 파일의 "4. 목표 설정 화면 생성" 섹션에 전체 코드 있음

### Step 3: 카테고리 화면에 목표 설정 버튼 추가 (10분)

**파일**: `lib/screens/category_portfolio_screen.dart`

`Scaffold`의 `floatingActionButton`에 추가:

```dart
floatingActionButton: FloatingActionButton.extended(
  onPressed: () async {
    final needsRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryGoalSettingScreen(
          category: category, // 현재 카테고리 전달
        ),
      ),
    );

    if (needsRefresh == true && mounted) {
      // 목표 설정 후 카테고리 Provider 새로고침
      context.read<CategoryProvider>().loadCategories();
      setState(() {});
    }
  },
  icon: const Icon(Icons.flag),
  label: const Text('목표 설정'),
  backgroundColor: AppColors.primaryBlue,
),
```

### Step 4: 카테고리 화면에 진행률 표시 (20분)

**파일**: `lib/screens/category_portfolio_screen.dart`

카테고리 정보 표시 부분에 진행률 추가:

```dart
// 카테고리 헤더 아래에 추가
FutureBuilder<Map<String, dynamic>>(
  future: _loadCategoryProgress(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return const SizedBox.shrink();

    final data = snapshot.data!;
    final currentValue = data['currentValue'] as double;
    final targetAmount = data['targetAmount'] as double?;

    if (targetAmount == null || targetAmount == 0) {
      return const SizedBox.shrink();
    }

    final progress = (currentValue / targetAmount * 100).clamp(0, 100);
    final remaining = targetAmount - currentValue;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: AppSpacing.borderRadiusLG,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${formatCurrency(targetAmount)} 모으기',
                style: AppTextStyles.titleMedium,
              ),
              Text(
                '${progress.toStringAsFixed(1)}%',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSpaceSM,
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: AppColors.neutralGray.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primaryBlue,
            ),
            minHeight: 8,
          ),
          AppSpacing.verticalSpaceSM,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '현재: ${formatCurrency(currentValue)}',
                style: AppTextStyles.bodyMedium,
              ),
              Text(
                '부족: ${formatCurrency(remaining)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  },
),

// 그리고 State 클래스에 메서드 추가:
Future<Map<String, dynamic>> _loadCategoryProgress() async {
  final db = DatabaseService();
  final currentValue = await db.getCategoryTotalValue(category.id);
  final categories = await db.getCategories();
  final cat = categories.firstWhere((c) => c.id == category.id);

  return {
    'currentValue': currentValue,
    'targetAmount': cat.targetAmount,
  };
}
```

### Step 5: 대시보드에 전체 진행률 표시 (20분)

**파일**: `lib/screens/dashboard_screen.dart`

카테고리 섹션 위에 전체 목표 진행률 추가:

```dart
// "카테고리별 포트폴리오" 섹션 위에 추가
FutureBuilder<Map<String, dynamic>>(
  future: _loadTotalProgress(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return const SizedBox.shrink();

    final data = snapshot.data!;
    final totalTarget = data['totalTarget'] as double;

    if (totalTarget == 0) return const SizedBox.shrink();

    final totalCurrent = data['totalCurrent'] as double;
    final progress = (totalCurrent / totalTarget * 100).clamp(0, 100);

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withOpacity(0.8),
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
            ],
          ),
          AppSpacing.verticalSpaceMD,
          Text(
            '${progress.toStringAsFixed(1)}%',
            style: AppTextStyles.displayLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          AppSpacing.verticalSpaceSM,
          Text(
            '${formatCurrency(totalCurrent)} / ${formatCurrency(totalTarget)}',
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  },
),

// State 클래스에 메서드 추가:
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
```

---

## 🧪 테스트 시나리오

1. **앱 재시작** → DB 마이그레이션 자동 실행 확인
2. **카테고리 탭 이동** → "목표 설정" 버튼 확인
3. **목표 설정**:
   - 배당 (SCHD): 3억원, 40%
   - 나스닥 (QQQ): 2억원, 30%
   - S&P500: 2억원, 30%
4. **진행률 확인**:
   - 카테고리별 진행률 표시
   - 대시보드 전체 진행률 표시

---

## 📂 생성/수정할 파일 목록

### 수정할 파일
- ✅ `lib/models/category.dart`
- ✅ `lib/services/database_service.dart` (일부 완료, 메서드 추가 필요)
- ⏳ `lib/screens/category_portfolio_screen.dart`
- ⏳ `lib/screens/dashboard_screen.dart`

### 새로 생성할 파일
- ⏳ `lib/screens/category_goal_setting_screen.dart`

---

## 💡 빠른 시작 가이드

```bash
# 1. 앱 실행 (자동 마이그레이션)
flutter run

# 2. 목표 설정 화면 생성
# lib/screens/category_goal_setting_screen.dart 파일 생성

# 3. 나머지 단계 진행...
```

---

**다음 세션에서**: Step 1부터 순서대로 진행하면 됩니다!
**예상 소요 시간**: 약 1.5시간

**참고 문서**:
- [PROGRESS_POMEBOKKO.md](PROGRESS_POMEBOKKO.md) - 상세 코드 예시
- [GAP_ANALYSIS.md](GAP_ANALYSIS.md) - 전체 기능 갭 분석
- [FINAL_ROADMAP.md](FINAL_ROADMAP.md) - 8주 전체 로드맵
