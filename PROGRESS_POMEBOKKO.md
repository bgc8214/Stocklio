# 🎯 포메뽀꼬 전략 구현 진행 상황

**작성일**: 2025년 11월 3일
**목표**: 목표 설정 & 리밸런싱 기능 구현

---

## ✅ 완료된 작업

### 1. Category 모델 확장
- ✅ `targetAmount` 필드 추가 (목표 금액)
- ✅ `targetWeight` 필드 추가 (목표 비중 %)
- ✅ `fromMap` 메서드 업데이트
- ✅ `toMap` 메서드 업데이트

### 2. 데이터베이스 마이그레이션
- ✅ DB 버전 3 → 4로 업그레이드
- ✅ `ALTER TABLE categories ADD COLUMN target_amount REAL`
- ✅ `ALTER TABLE categories ADD COLUMN target_weight REAL`

---

## 📋 다음 작업 (순서대로)

### 3. DatabaseService에 목표 업데이트 메서드 추가
```dart
// lib/services/database_service.dart에 추가

/// 카테고리 목표 설정 업데이트
Future<void> updateCategoryGoals(int categoryId, double? targetAmount, double? targetWeight) async {
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

/// 카테고리별 현재 금액 조회
Future<double> getCategoryTotalValue(int categoryId) async {
  final db = await database;

  final result = await db.rawQuery('''
    SELECT SUM(p.quantity * p.current_price) as total
    FROM portfolios p
    WHERE p.category_id = ?
  ''', [categoryId]);

  return (result.first['total'] as num?)?.toDouble() ?? 0.0;
}

/// 전체 포트폴리오 총액 조회
Future<double> getTotalPortfolioValue() async {
  final db = await database;

  final result = await db.rawQuery('''
    SELECT SUM(quantity * current_price) as total
    FROM portfolios
  ''');

  return (result.first['total'] as num?)?.toDouble() ?? 0.0;
}
```

### 4. 목표 설정 화면 생성
파일: `lib/screens/category_goal_setting_screen.dart`

```dart
import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/database_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../utils/currency_formatter.dart';

class CategoryGoalSettingScreen extends StatefulWidget {
  final Category category;

  const CategoryGoalSettingScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryGoalSettingScreen> createState() => _CategoryGoalSettingScreenState();
}

class _CategoryGoalSettingScreenState extends State<CategoryGoalSettingScreen> {
  final _targetAmountController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    // 기존 목표값 로드
    if (widget.category.targetAmount != null) {
      _targetAmountController.text = widget.category.targetAmount!.toStringAsFixed(0);
    }
    if (widget.category.targetWeight != null) {
      _targetWeightController.text = widget.category.targetWeight!.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _targetAmountController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  Future<void> _saveGoals() async {
    final targetAmount = double.tryParse(_targetAmountController.text);
    final targetWeight = double.tryParse(_targetWeightController.text);

    await _db.updateCategoryGoals(
      widget.category.id,
      targetAmount,
      targetWeight,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.category.displayName} 목표가 설정되었습니다'),
        backgroundColor: AppColors.profitGreen,
      ),
    );

    Navigator.pop(context, true); // true를 반환하여 새로고침 필요 알림
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category.icon} ${widget.category.displayName} 목표 설정'),
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '포메뽀꼬 전략 목표 설정',
              style: AppTextStyles.headlineMedium,
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              '"n억 모으기" 목표와 리밸런싱 비중을 설정하세요',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            AppSpacing.verticalSpaceXL,

            // 목표 금액 입력
            Text(
              '목표 금액',
              style: AppTextStyles.titleMedium,
            ),
            AppSpacing.verticalSpaceSM,
            TextField(
              controller: _targetAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '예: 300000000 (3억원)',
                suffixText: '원',
                border: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMD,
                ),
              ),
              style: AppTextStyles.bodyLarge,
            ),
            AppSpacing.verticalSpaceLG,

            // 목표 비중 입력
            Text(
              '목표 비중 (%)',
              style: AppTextStyles.titleMedium,
            ),
            AppSpacing.verticalSpaceSM,
            TextField(
              controller: _targetWeightController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: '예: 40 (40%)',
                suffixText: '%',
                border: OutlineInputBorder(
                  borderRadius: AppSpacing.borderRadiusMD,
                ),
              ),
              style: AppTextStyles.bodyLarge,
            ),
            AppSpacing.verticalSpaceSM,
            Text(
              '💡 리밸런싱: 목표 비중 ± 5% 벗어나면 알림',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            AppSpacing.verticalSpaceXL,

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveGoals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusMD,
                  ),
                ),
                child: Text(
                  '목표 저장',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 5. 카테고리 포트폴리오 화면에 목표 설정 버튼 추가
`lib/screens/category_portfolio_screen.dart`에 FloatingActionButton 추가:

```dart
floatingActionButton: FloatingActionButton.extended(
  onPressed: () async {
    final needsRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryGoalSettingScreen(
          category: category,
        ),
      ),
    );

    if (needsRefresh == true) {
      // 화면 새로고침
      setState(() {});
    }
  },
  icon: Icon(Icons.flag),
  label: Text('목표 설정'),
),
```

### 6. 대시보드에 목표 진행률 표시
`lib/screens/dashboard_screen.dart`에 목표 진행률 위젯 추가

---

## 🎯 예상 화면 흐름

```
대시보드
  ↓
카테고리 탭 클릭
  ↓
카테고리 포트폴리오 화면
  ↓
"목표 설정" 버튼 클릭
  ↓
목표 설정 화면
  - 목표 금액: 3억원
  - 목표 비중: 40%
  ↓
저장
  ↓
카테고리 화면에 진행률 표시
  - "3억 모으기 17.3% 달성!"
```

---

## 📝 테스트 시나리오

1. ✅ 앱 실행 → DB 마이그레이션 확인
2. ✅ 카테고리 화면 → 목표 설정 버튼 확인
3. ✅ 목표 설정 → 저장 확인
4. ✅ 진행률 계산 확인
5. ✅ 리밸런싱 알림 확인

---

**다음 세션에서 계속...**
