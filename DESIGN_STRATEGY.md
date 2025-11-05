# MyFolio 디자인 전략 2025

**작성일:** 2025년 10월 31일
**버전:** 1.0

---

## 📋 목차

1. [디자인 철학](#1-디자인-철학)
2. [경쟁사 분석 요약](#2-경쟁사-분석-요약)
3. [2025 핀테크 디자인 트렌드](#3-2025-핀테크-디자인-트렌드)
4. [MyFolio 디자인 시스템](#4-myfolio-디자인-시스템)
5. [화면별 UI/UX 전략](#5-화면별-uiux-전략)
6. [구현 로드맵](#6-구현-로드맵)

---

## 1. 디자인 철학

### 핵심 가치
```
단순함 (Simplicity) > 기능 (Features)
명료함 (Clarity) > 장식 (Decoration)
직관성 (Intuitive) > 학습 (Learning Curve)
```

### 디자인 원칙

#### 1.1 Zero Learning Curve
사용자가 앱을 처음 켤 때 튜토리얼 없이도 즉시 사용할 수 있어야 합니다.

#### 1.2 Data First
화려한 디자인보다 데이터가 중심이 되어야 합니다. 모든 시각 요소는 데이터를 명확히 전달하는 것에 집중합니다.

#### 1.3 Mobile-First
모든 디자인은 모바일 화면에서 시작합니다. 한 손으로 편하게 사용할 수 있어야 합니다.

#### 1.4 Performance Over Beauty
아름다운 애니메이션보다 빠른 로딩이 우선입니다.

---

## 2. 경쟁사 분석 요약

### 2.1 글로벌 앱 분석

#### Robinhood
**강점:**
- 극도로 단순화된 인터페이스
- 초보자에게 친화적
- 미니멀한 정보 표시

**약점:**
- 고급 사용자에게 부족한 정보
- 제한된 차트 기능

**차용할 점:**
- ✅ 깔끔한 카드 레이아웃
- ✅ 단순한 색상 사용 (손익 표시)
- ✅ 여백을 활용한 가독성

#### Webull
**강점:**
- 전문가급 차트 도구
- 캔들스틱 차트
- 다양한 기술적 지표

**약점:**
- 초보자에게 복잡함
- 정보 과부하

**차용할 점:**
- ✅ 데이터 시각화 품질
- ✅ 인터랙티브 차트
- ❌ 복잡한 지표는 피하기

### 2.2 한국 앱 분석

#### 토스증권 (UX 1위, 73.2%)
**성공 요인:**
- 단순하고 직관적인 UI
- MZ세대 타겟 디자인
- 무료 수수료 + 깔끔한 화면
- 복잡한 금융 용어 배제

**차용할 점:**
- ✅ 단순한 언어 사용
- ✅ 밝고 친근한 색상
- ✅ 카드 기반 레이아웃
- ✅ 터치 친화적 버튼 크기

#### 나무증권 (UX 2위, 68.4%)
**강점:**
- 디자인과 사용성 우수
- 초보자 친화적

**약점:**
- 서비스 기능에서 낮은 점수

**차용할 점:**
- ✅ 사용성 우선 설계

#### 도미노 (직접 경쟁사)
**강점:**
- 다양한 자산 지원
- AI 기능, 알림 기능

**약점:**
- 복잡한 인터페이스
- 정보 과부하 가능성

**우리의 차별화:**
- ✅ 더 단순하게
- ✅ 주식만 집중
- ✅ 수익 그래프에 집중

---

## 3. 2025 핀테크 디자인 트렌드

### 3.1 적용할 트렌드 ✅

#### 1) 데이터 시각화 강화
- **트렌드:** 인터랙티브 차트, 실시간 데이터 시각화
- **MyFolio 적용:**
  - 일일/월간/연간 수익 3개 시리즈 겹쳐보기
  - 터치 인터랙션 (차트 확대, 특정 날짜 선택)
  - 색상으로 손익 구분 (빨강/파랑)

#### 2) 모바일 최적화
- **트렌드:** 모바일 우선 설계
- **MyFolio 적용:**
  - 세로 모드 최적화
  - 한 손 조작 가능한 UI
  - 스크롤 최소화 (핵심 정보는 첫 화면에)

#### 3) 밝은 색상 팔레트
- **트렌드:** 중립 톤에서 밝고 눈에 띄는 색상으로 전환
- **MyFolio 적용:**
  - 그라데이션 배경 (부드러운 그라데이션)
  - 포인트 컬러 사용
  - MZ세대 타겟 색상

#### 4) 단순성과 정보 밀도의 균형
- **트렌드:** 복잡한 데이터를 단순하게 표현
- **MyFolio 적용:**
  - 카드 기반 레이아웃
  - 핵심 지표만 표시 (4개 카드)
  - 상세 정보는 탭으로 숨기기

#### 5) 데이터 스토리텔링
- **트렌드:** 숫자보다 스토리로 전달
- **MyFolio 적용:**
  - "오늘은 어제보다 +50,000원 벌었어요"
  - "이번 달 누적 수익이 200,000원이에요"
  - 감정적 연결 (이모지, 친근한 문구)

#### 6) AI 기반 인사이트 (Phase 2+)
- **트렌드:** AI로 맞춤형 조언 제공
- **MyFolio 적용:**
  - Phase 2 이후 검토
  - "지난달보다 수익률이 10% 증가했어요"
  - "삼성전자의 비중이 너무 높아요"

### 3.2 제외할 트렌드 ❌

#### 1) 게임화 (Gamification)
- **이유:** 투자를 게임처럼 만들면 안 됨
- **대신:** 단순한 진행 상황 표시

#### 2) 소셜 뱅킹
- **이유:** 프라이버시 중시 사용자 타겟
- **대신:** 개인 포트폴리오에 집중

#### 3) 슈퍼 앱
- **이유:** 주식 트래킹에만 집중
- **대신:** 단일 목적 앱

#### 4) 음성 인터페이스
- **이유:** MVP 범위 초과
- **대신:** Phase 3 이후 검토

---

## 4. MyFolio 디자인 시스템

### 4.1 컬러 팔레트

#### Primary Colors (메인 브랜드 컬러)
```
Primary Blue:   #4C6FFF  (CTA 버튼, 링크)
Primary Purple: #7C3AED  (포인트, 강조)
```

#### Semantic Colors (의미론적 컬러)
```
Profit Green:   #10B981  (수익, 상승)
Loss Red:       #EF4444  (손실, 하락)
Neutral Gray:   #6B7280  (보조 텍스트)
Warning Yellow: #F59E0B  (알림, 주의)
```

#### Background Colors
```
Primary BG:     #FFFFFF  (라이트 모드)
Secondary BG:   #F9FAFB  (카드, 섹션)
Dark BG:        #111827  (다크 모드, Phase 2)
```

#### Text Colors
```
Primary Text:   #111827  (제목, 중요 텍스트)
Secondary Text: #6B7280  (설명, 보조 텍스트)
Disabled Text:  #9CA3AF  (비활성)
```

#### 그라데이션 (선택적 사용)
```
Hero Gradient:  linear-gradient(135deg, #667eea 0%, #764ba2 100%)
Card Gradient:  linear-gradient(120deg, #fdfbfb 0%, #ebedee 100%)
```

### 4.2 타이포그래피

#### Font Family
```
Primary Font: 'SF Pro' (iOS), 'Roboto' (Android)
Number Font:  'SF Pro Rounded' (숫자 전용, 가독성)
```

#### Font Sizes (Flutter 기준)
```
Headline Large:  32.0sp  (대시보드 총 평가금액)
Headline Medium: 24.0sp  (섹션 제목)
Title Large:     20.0sp  (카드 제목)
Body Large:      16.0sp  (본문)
Body Medium:     14.0sp  (설명)
Label Small:     12.0sp  (라벨, 힌트)
```

#### Font Weights
```
Bold:     700  (제목, 강조)
SemiBold: 600  (서브 타이틀)
Medium:   500  (본문)
Regular:  400  (보조 텍스트)
```

### 4.3 스페이싱 시스템

#### Spacing Scale (8pt Grid System)
```
4px  (0.5x)  - 아주 좁은 여백
8px  (1x)    - 기본 단위
12px (1.5x)  - 작은 여백
16px (2x)    - 일반 여백
24px (3x)    - 중간 여백
32px (4x)    - 큰 여백
48px (6x)    - 섹션 간 여백
```

#### Padding (Flutter 기준)
```
Card Padding:    EdgeInsets.all(16)
Screen Padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 24)
List Item:       EdgeInsets.symmetric(horizontal: 16, vertical: 12)
```

### 4.4 컴포넌트 스타일

#### Buttons
```dart
// Primary Button
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF4C6FFF),
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  ),
  child: Text('추가하기'),
)

// Secondary Button
OutlinedButton(
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: Color(0xFF4C6FFF)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: Text('취소'),
)
```

#### Cards
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: Offset(0, 2),
      ),
    ],
  ),
  padding: EdgeInsets.all(16),
  child: // content
)
```

#### Input Fields
```dart
TextField(
  decoration: InputDecoration(
    filled: true,
    fillColor: Color(0xFFF9FAFB),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Color(0xFF4C6FFF), width: 2),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  ),
)
```

### 4.5 아이콘 스타일

#### Icon Set
- **Material Icons** (Flutter 기본)
- **Lucide Icons** (선택적, 일관성 있는 라인 아이콘)

#### Icon Sizes
```
Small:  16.0
Medium: 24.0
Large:  32.0
XLarge: 48.0
```

#### Icon Colors
- Primary actions: `#4C6FFF`
- Neutral actions: `#6B7280`
- Profit: `#10B981`
- Loss: `#EF4444`

---

## 5. 화면별 UI/UX 전략

### 5.1 대시보드 (Dashboard)

#### 레이아웃 구조
```
┌─────────────────────────────────┐
│  [상단 헤더]                     │
│  MyFolio 로고 + 설정 버튼         │
├─────────────────────────────────┤
│  [핵심 지표 카드 4개]             │
│  ┌─────────┐ ┌─────────┐        │
│  │총평가금액│ │투자원금 │        │
│  │30,500,000│ │28,000,000│       │
│  └─────────┘ └─────────┘        │
│  ┌─────────┐ ┌─────────┐        │
│  │총 수익  │ │당일 수익│        │
│  │+2,500,000│ │+150,000│        │
│  │ (+8.9%) │ │(+0.5%) │        │
│  └─────────┘ └─────────┘        │
├─────────────────────────────────┤
│  [수익 추이 그래프]               │
│  일일/월간/연간 시리즈            │
│  (fl_chart 사용)                │
│                                 │
│  [범례]                          │
│  ━━ 일일  ▢▢ 월간  ▢▢ 연간      │
├─────────────────────────────────┤
│  [보유 종목 리스트]               │
│  삼성전자   10주  +5.2%          │
│  애플       5주   -2.1%          │
│  테슬라     3주   +12.3%         │
├─────────────────────────────────┤
│  [하단 네비게이션]                │
│  홈 | 포트폴리오 | 추가 | 설정   │
└─────────────────────────────────┘
```

#### UX 포인트
1. **스크롤 최소화:** 핵심 정보는 첫 화면에 모두 표시
2. **터치 영역:** 카드 전체를 터치 가능하게 (최소 48x48dp)
3. **로딩 상태:** Skeleton Screen 사용 (Shimmer 효과)
4. **새로고침:** Pull-to-refresh 제스처

#### 인터랙션
- 카드 터치 → 상세 정보 모달
- 그래프 터치 → 특정 날짜 데이터 툴팁
- 종목 터치 → 종목 상세 화면

### 5.2 종목 추가 화면 (Add Stock)

#### 레이아웃
```
┌─────────────────────────────────┐
│  [헤더]                          │
│  ← 종목 추가                     │
├─────────────────────────────────┤
│  [검색 바]                       │
│  🔍 종목명 또는 티커 검색         │
├─────────────────────────────────┤
│  [검색 결과]                     │
│  삼성전자 (005930.KS)            │
│  KOSPI | ₩70,000                │
│                                 │
│  애플 (AAPL)                     │
│  NASDAQ | $185.00               │
├─────────────────────────────────┤
│  [선택 후 입력 폼]                │
│  보유 수량: [10] 주              │
│  평균 단가: [68,500] 원          │
│                                 │
│  [추가하기 버튼]                  │
└─────────────────────────────────┘
```

#### UX 포인트
1. **실시간 검색:** 타이핑 중 자동완성 (Debounce 300ms)
2. **키보드 타입:** 숫자 입력은 숫자 키패드
3. **유효성 검사:** 빈 값, 0 이하 값 방지
4. **피드백:** 성공/실패 토스트 메시지

#### 검색 UX 개선
- 최근 검색어 표시
- 인기 종목 추천 (KOSPI 200, S&P 500)
- 국내/해외 주식 탭 구분

### 5.3 포트폴리오 화면 (Portfolio)

#### 레이아웃
```
┌─────────────────────────────────┐
│  [필터 칩]                       │
│  ○ 전체  ● 국내  ○ 해외         │
├─────────────────────────────────┤
│  [정렬]                          │
│  ▼ 수익률 높은순                 │
├─────────────────────────────────┤
│  [종목 카드]                     │
│  삼성전자                        │
│  10주 × ₩70,000                 │
│  평단: ₩68,500                  │
│  수익: +15,000원 (+2.2%)        │
│  ━━━━━━━━━━━━ 15%              │
│                                 │
│  [종목 카드]                     │
│  애플                            │
│  5주 × $185.00                  │
│  평단: $180.00                  │
│  수익: +$25.00 (+2.8%)          │
│  ━━━━━━━━━━━━ 10%              │
└─────────────────────────────────┘
```

#### UX 포인트
1. **시각적 구분:** 수익/손실 색상으로 즉시 구분
2. **스와이프 액션:** 좌로 밀어 수정/삭제
3. **진행 바:** 포트폴리오 비중 시각화
4. **빈 상태:** "첫 종목을 추가해보세요" + CTA 버튼

### 5.4 수익 차트 (Profit Chart)

#### 차트 스타일
```dart
LineChart(
  LineChartData(
    lineBarsData: [
      // 일일 수익 (선 그래프)
      LineChartBarData(
        spots: dailyData,
        isCurved: true,
        color: Color(0xFF4C6FFF),
        barWidth: 2,
        dotData: FlDotData(show: false),
      ),
      // 월간 누적 (영역 그래프)
      LineChartBarData(
        spots: monthlyData,
        isCurved: true,
        color: Color(0xFF10B981).withOpacity(0.5),
        barWidth: 0,
        belowBarData: BarAreaData(show: true),
      ),
      // 연간 누적 (영역 그래프)
      LineChartBarData(
        spots: yearlyData,
        isCurved: true,
        color: Color(0xFF7C3AED).withOpacity(0.3),
        barWidth: 0,
        belowBarData: BarAreaData(show: true),
      ),
    ],
    gridData: FlGridData(show: true, drawVerticalLine: false),
    borderData: FlBorderData(show: false),
    titlesData: FlTitlesData(
      leftTitles: AxisTitles(/* 금액 */),
      bottomTitles: AxisTitles(/* 날짜 */),
    ),
  ),
)
```

#### 인터랙션
1. **핀치 줌:** 차트 확대/축소
2. **스크롤:** 좌우로 스크롤하여 과거 데이터 탐색
3. **툴팁:** 터치 시 해당 날짜의 정확한 값 표시
4. **��례 토글:** 범례 탭하여 시리즈 숨기기/보이기

---

## 6. 구현 로드맵

### Phase 1: MVP 디자인 (2주)

#### Week 1: 핵심 화면 디자인
- [ ] 대시보드 UI 구현
- [ ] 핵심 지표 카드 4개
- [ ] 수익 차트 (3개 시리즈)
- [ ] 기본 색상 시스템 적용

#### Week 2: 부가 화면 디자인
- [ ] 종목 추가 화면
- [ ] 종목 검색 UI
- [ ] 포트폴리오 리스트
- [ ] 설정 화면

### Phase 2: 디자인 개선 (1주)

#### 애니메이션 추가
```dart
// 카드 진입 애니메이션
AnimatedOpacity(
  opacity: _visible ? 1.0 : 0.0,
  duration: Duration(milliseconds: 300),
  child: Card(...),
)

// 숫자 카운트업 애니메이션
TweenAnimationBuilder<double>(
  tween: Tween(begin: 0, end: totalValue),
  duration: Duration(milliseconds: 800),
  builder: (context, value, child) {
    return Text(NumberFormat.currency(locale: 'ko_KR').format(value));
  },
)
```

#### 터치 피드백 개선
```dart
// Ripple 효과
InkWell(
  onTap: () {},
  borderRadius: BorderRadius.circular(16),
  child: Card(...),
)

// Haptic Feedback
HapticFeedback.lightImpact(); // 버튼 탭
HapticFeedback.mediumImpact(); // 중요 액션
```

### Phase 3: 고급 기능 (2주)

#### 다크 모드
```dart
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Color(0xFF4C6FFF),
  scaffoldBackgroundColor: Color(0xFF111827),
  cardColor: Color(0xFF1F2937),
  // ... 나머지 색상
);
```

#### 접근성 개선
- [ ] 색맹 모드 (Colorblind-friendly palette)
- [ ] 폰트 크기 조절
- [ ] 스크린 리더 지원 (Semantics)
- [ ] 고대비 모드

---

## 7. 디자인 QA 체크리스트

### 모바일 최적화
- [ ] 최소 터치 영역 48x48dp 준수
- [ ] 한 손 조작 가능 (중요 버튼은 하단 1/3)
- [ ] 가로 모드 지원 (선택적)
- [ ] 다양한 화면 크기 테스트 (소형/중형/대형)

### 성능
- [ ] 초기 로딩 3초 이내
- [ ] 차트 렌더링 1초 이내
- [ ] 60fps 유지 (애니메이션)
- [ ] 메모리 사용량 최적화

### 일관성
- [ ] 색상 팔레트 준수
- [ ] 타이포그래피 일관성
- [ ] 스페이싱 규칙 준수
- [ ] 컴포넌트 재사용

### 접근성
- [ ] 명도 대비 4.5:1 이상 (WCAG AA)
- [ ] 텍스트 크기 조절 지원
- [ ] 스크린 리더 테스트
- [ ] 키보드 네비게이션 (웹 버전)

---

## 8. 디자인 레퍼런스

### 참고 앱
1. **토스증권** - 단순함, MZ세대 타겟
2. **Robinhood** - 미니멀 디자인
3. **Apple Stocks** - 네이티브 느낌
4. **Mint** - 데이터 시각화

### 디자인 리소스
- [Material Design 3](https://m3.material.io/) - Flutter 공식 가이드
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/) - iOS 디자인
- [Dribbble Finance UI](https://dribbble.com/tags/finance_app) - 영감
- [Mobbin](https://mobbin.com/) - 실제 앱 UI 패턴

### 색상 도구
- [Coolors](https://coolors.co/) - 팔레트 생성
- [Contrast Checker](https://webaim.org/resources/contrastchecker/) - 접근성 검증

---

## 9. 결론 및 다음 단계

### 핵심 요약
MyFolio의 디자인은 **"단순함"**을 최우선으로 합니다.
- 토스증권처럼 직관적인 UI
- Robinhood처럼 미니멀한 디자인
- 데이터 시각화에 집중

### 차별화 포인트
1. **3개 시리즈 수익 그래프** - 경쟁사 없음
2. **완전 무료 + 광고 없음** - 깔끔한 디자인 유지
3. **단일 목적** - 주식 트래킹에만 집중

### 다음 단계
1. ✅ 이 문서 검토 및 피드백
2. 🔲 Flutter 프로젝트에 디자인 시스템 적용
3. 🔲 대시보드 화면 구현
4. 🔲 사용자 테스트 (5-10명)
5. 🔲 피드백 반영 및 개선

---

**작성자:** Claude (based on research)
**마지막 업데이트:** 2025년 10월 31일
