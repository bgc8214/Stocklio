# 최종 확정 아키텍처

**프로젝트:** 마이 포트폴리오 (MyFolio)
**최종 결정일:** 2025년 10월 27일

---

## 🎯 최종 결정 사항

### Phase 1 (MVP): Flutter 단독 + 로컬 DB
**개발 기간:** 1-2개월
**비용:** $0
**목표:** 핵심 기능 검증 및 사용자 피드백 수집

### Phase 2 (정식 출시): Firebase 추가
**개발 기간:** +2-4주
**비용:** $0-10/월
**목표:** 멀티 디바이스 지원 및 데이터 백업

---

## 📱 Phase 1: MVP 아키텍처 (Flutter 단독)

### 기술 스택

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter

  # 상태 관리
  provider: ^6.1.0

  # 로컬 데이터베이스
  sqflite: ^2.3.0
  path_provider: ^2.1.0

  # 야후 파이낸스 (주식 데이터) ⭐
  yahoo_finance_data_reader: ^2.0.0

  # HTTP 클라이언트
  dio: ^5.4.0

  # 백그라운드 작업
  workmanager: ^0.5.1

  # 차트
  fl_chart: ^0.65.0

  # 날짜 처리
  intl: ^0.19.0

  # UI
  cupertino_icons: ^1.0.6
```

### 주식 데이터 API: Yahoo Finance ✅

**선택 이유:**
- ✅ **완전 무료** - API 키 불필요
- ✅ **한국 주식 지원** - KOSPI, KOSDAQ 전체 지원
- ✅ **미국 주식 지원** - NYSE, NASDAQ 전체 지원
- ✅ **과거 데이터** - 수십 년 치 데이터 제공
- ✅ **검색 기능** - 종목 심볼 검색 가능
- ✅ **Flutter 패키지 존재** - `yahoo_finance_data_reader`

**티커 형식:**
```dart
// 한국 주식
"005930.KS"  // 삼성전자 (KOSPI)
"035720.KS"  // 카카오 (KOSPI)
"035420.KQ"  // NAVER (KOSDAQ)

// 미국 주식
"AAPL"       // Apple
"TSLA"       // Tesla
"GOOGL"      // Google
```

**주요 기능:**
```dart
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

// 1. 현재가 조회
final ticker = YahooFinanceDailyReader(symbol: '005930.KS');
final response = await ticker.getDailyData();
final latestPrice = response?.candlesData?.last.close;

// 2. 과거 데이터 조회
final historicalData = await ticker.getDailyData(
  startDate: DateTime(2024, 1, 1),
  endDate: DateTime.now(),
);

// 3. 여러 종목 동시 조회
final tickers = ['005930.KS', 'AAPL', '035720.KS'];
for (var symbol in tickers) {
  final data = await YahooFinanceDailyReader(symbol: symbol).getDailyData();
  // 처리...
}
```

**주의사항:**
- Yahoo Finance는 비공식 API이지만 수년간 안정적으로 작동
- 호출 제한 없음 (과도한 요청은 피할 것)
- 15-20분 지연 데이터 (실시간 아님)

### 아키텍처 다이어그램

```
┌─────────────────────────────────────────┐
│         Flutter App (MVP)               │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │       UI Layer (Widgets)          │ │
│  └───────────────────────────────────┘ │
│              ↕                          │
│  ┌───────────────────────────────────┐ │
│  │   Business Logic (Provider)       │ │
│  └───────────────────────────────────┘ │
│              ↕                          │
│  ┌───────────────────────────────────┐ │
│  │      Data Layer                   │ │
│  │                                   │ │
│  │  ┌─────────────┐  ┌────────────┐ │ │
│  │  │   SQLite    │  │  Yahoo     │ │ │
│  │  │  (sqflite)  │  │  Finance   │ │ │
│  │  │             │  │   API      │ │ │
│  │  └─────────────┘  └────────────┘ │ │
│  └───────────────────────────────────┘ │
│              ↕                          │
│  ┌───────────────────────────────────┐ │
│  │  WorkManager (백그라운드 작업)     │ │
│  │  - 매일 자동 시세 업데이트         │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### 폴더 구조

```
lib/
├── main.dart
├── models/
│   ├── portfolio.dart
│   ├── daily_snapshot.dart
│   └── profit_series.dart
├── providers/
│   ├── portfolio_provider.dart
│   └── dashboard_provider.dart
├── services/
│   ├── database_service.dart
│   ├── yahoo_finance_service.dart
│   └── background_service.dart
├── screens/
│   ├── portfolio_screen.dart
│   ├── dashboard_screen.dart
│   └── add_stock_screen.dart
├── widgets/
│   ├── stock_card.dart
│   ├── profit_chart.dart
│   └── summary_card.dart
└── utils/
    ├── constants.dart
    └── helpers.dart
```

### SQLite 스키마

```sql
-- 포트폴리오
CREATE TABLE portfolios (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ticker TEXT NOT NULL,
  name TEXT NOT NULL,
  quantity REAL NOT NULL,
  average_cost REAL NOT NULL,
  market TEXT NOT NULL, -- 'KS', 'KQ', 'US'
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
);

-- 일별 스냅샷
CREATE TABLE daily_snapshots (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  snapshot_date TEXT NOT NULL UNIQUE,
  total_value REAL NOT NULL,
  total_investment REAL NOT NULL,
  total_profit REAL NOT NULL,
  daily_profit REAL,
  created_at TEXT NOT NULL
);

-- 수익 시계열 (그래프용)
CREATE TABLE profit_series (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL UNIQUE,
  daily_profit REAL,
  monthly_cumulative REAL,
  annual_cumulative REAL,
  created_at TEXT NOT NULL
);

-- 종목별 일별 가격 (캐싱용)
CREATE TABLE stock_prices (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ticker TEXT NOT NULL,
  date TEXT NOT NULL,
  close_price REAL NOT NULL,
  created_at TEXT NOT NULL,
  UNIQUE(ticker, date)
);
```

### 주요 기능 구현

#### 1. 종목 검색 및 추가

```dart
// services/yahoo_finance_service.dart
class YahooFinanceService {
  // 종목 검색 (사용자가 티커 입력)
  Future<Map<String, dynamic>?> searchStock(String ticker) async {
    try {
      final reader = YahooFinanceDailyReader(symbol: ticker);
      final data = await reader.getDailyData();

      if (data?.candlesData != null && data!.candlesData!.isNotEmpty) {
        return {
          'ticker': ticker,
          'currentPrice': data.candlesData!.last.close,
          'lastUpdate': data.candlesData!.last.date,
        };
      }
      return null;
    } catch (e) {
      print('Error searching stock: $e');
      return null;
    }
  }

  // 현재가 조회
  Future<double?> getCurrentPrice(String ticker) async {
    try {
      final reader = YahooFinanceDailyReader(symbol: ticker);
      final data = await reader.getDailyData();
      return data?.candlesData?.last.close;
    } catch (e) {
      print('Error getting price: $e');
      return null;
    }
  }

  // 여러 종목 가격 일괄 조회
  Future<Map<String, double>> getBatchPrices(List<String> tickers) async {
    final prices = <String, double>{};

    for (var ticker in tickers) {
      final price = await getCurrentPrice(ticker);
      if (price != null) {
        prices[ticker] = price;
        // API 부담 줄이기 위한 딜레이
        await Future.delayed(Duration(milliseconds: 200));
      }
    }

    return prices;
  }
}
```

#### 2. 백그라운드 스케줄러

```dart
// services/background_service.dart
import 'package:workmanager/workmanager.dart';

const dailyUpdateTask = "dailyStockUpdate";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == dailyUpdateTask) {
      // DB 초기화
      final db = await DatabaseService().database;

      // 모든 포트폴리오 종목 가져오기
      final portfolios = await db.query('portfolios');

      if (portfolios.isEmpty) return true;

      // 주식 가격 업데이트
      final yahooService = YahooFinanceService();
      final tickers = portfolios.map((p) => p['ticker'] as String).toList();
      final prices = await yahooService.getBatchPrices(tickers);

      // 총 평가금액 계산
      double totalValue = 0;
      double totalInvestment = 0;

      for (var portfolio in portfolios) {
        final ticker = portfolio['ticker'] as String;
        final quantity = portfolio['quantity'] as double;
        final avgCost = portfolio['average_cost'] as double;

        if (prices.containsKey(ticker)) {
          totalValue += prices[ticker]! * quantity;
          totalInvestment += avgCost * quantity;
        }
      }

      // 일별 스냅샷 저장
      await db.insert('daily_snapshots', {
        'snapshot_date': DateTime.now().toIso8601String().split('T')[0],
        'total_value': totalValue,
        'total_investment': totalInvestment,
        'total_profit': totalValue - totalInvestment,
        'created_at': DateTime.now().toIso8601String(),
      });

      print('Daily update completed!');
    }
    return true;
  });
}

class BackgroundService {
  static void initialize() {
    Workmanager().initialize(callbackDispatcher);
  }

  static void scheduleDailyUpdate() {
    // 매일 오후 4시 실행 (장 마감 후)
    Workmanager().registerPeriodicTask(
      "1",
      dailyUpdateTask,
      frequency: Duration(days: 1),
      initialDelay: Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}
```

#### 3. 대시보드 Provider

```dart
// providers/dashboard_provider.dart
class DashboardProvider with ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final YahooFinanceService _yahoo = YahooFinanceService();

  double totalValue = 0;
  double totalInvestment = 0;
  double totalProfit = 0;
  double totalProfitPercent = 0;
  double todayProfit = 0;

  List<Map<String, dynamic>> profitSeries = [];

  Future<void> loadDashboard() async {
    // 포트폴리오 데이터 로드
    final portfolios = await _db.getPortfolios();

    if (portfolios.isEmpty) {
      notifyListeners();
      return;
    }

    // 현재 가격 조회
    final tickers = portfolios.map((p) => p['ticker'] as String).toList();
    final prices = await _yahoo.getBatchPrices(tickers);

    // 총 평가금액 계산
    totalValue = 0;
    totalInvestment = 0;

    for (var portfolio in portfolios) {
      final ticker = portfolio['ticker'] as String;
      final quantity = portfolio['quantity'] as double;
      final avgCost = portfolio['average_cost'] as double;

      if (prices.containsKey(ticker)) {
        totalValue += prices[ticker]! * quantity;
        totalInvestment += avgCost * quantity;
      }
    }

    totalProfit = totalValue - totalInvestment;
    totalProfitPercent = totalInvestment > 0
        ? (totalProfit / totalInvestment) * 100
        : 0;

    // 어제 스냅샷과 비교
    final yesterday = DateTime.now().subtract(Duration(days: 1));
    final yesterdaySnapshot = await _db.getSnapshotByDate(
      yesterday.toIso8601String().split('T')[0]
    );

    if (yesterdaySnapshot != null) {
      todayProfit = totalValue - (yesterdaySnapshot['total_value'] as double);
    }

    // 수익 시계열 데이터 로드
    profitSeries = await _db.getProfitSeries();

    notifyListeners();
  }
}
```

### MVP 기능 목록

#### ✅ Phase 1.1: 기본 인프라 (1주)
- [ ] Flutter 프로젝트 생성
- [ ] SQLite 데이터베이스 설정
- [ ] Provider 상태 관리 설정
- [ ] 기본 UI 레이아웃 (네비게이션)

#### ✅ Phase 1.2: 포트폴리오 관리 (2주)
- [ ] 종목 검색 화면 (티커 입력)
- [ ] Yahoo Finance API 연동
- [ ] 종목 추가 (수량, 평단가 입력)
- [ ] 포트폴리오 목록 조회
- [ ] 종목 수정/삭제

#### ✅ Phase 1.3: 대시보드 (2주)
- [ ] 요약 카드 (총 평가금액, 수익률 등)
- [ ] 보유 종목 현황 리스트
- [ ] 백그라운드 스케줄러 구현
- [ ] 일별 스냅샷 계산 및 저장

#### ✅ Phase 1.4: 그래프 (2주)
- [ ] fl_chart 라이브러리 통합
- [ ] 일일 수익 선형 차트
- [ ] 월간 누적 영역 차트
- [ ] 연간 누적 영역 차트
- [ ] 그래프 데이터 계산 로직

#### ✅ Phase 1.5: 테스트 및 배포 (1주)
- [ ] 버그 수정
- [ ] UI/UX 개선
- [ ] 앱 아이콘 및 스플래시 스크린
- [ ] Google Play 배포 (Android)

**예상 총 기간:** 8주 (2개월)

---

## 🔥 Phase 2: Firebase 추가 (정식 출시)

### 추가 기술 스택

```yaml
dependencies:
  # Firebase 핵심
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0

  # Firebase 확장
  firebase_storage: ^11.5.0  # 프로필 이미지 등
```

### Firebase 아키텍처

```
┌─────────────────────────────────────────┐
│         Flutter App (정식)              │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │       UI Layer                    │ │
│  └───────────────────────────────────┘ │
│              ↕                          │
│  ┌───────────────────────────────────┐ │
│  │   Business Logic (Provider)       │ │
│  └───────────────────────────────────┘ │
│              ↕                          │
│  ┌───────────────────────────────────┐ │
│  │      Data Layer                   │ │
│  │                                   │ │
│  │  ┌─────────┐  ┌──────────────┐   │ │
│  │  │ SQLite  │  │  Firestore   │   │ │
│  │  │(캐시용) │  │(클라우드 DB) │   │ │
│  │  └─────────┘  └──────────────┘   │ │
│  │                                   │ │
│  │  ┌─────────────┐  ┌────────────┐ │ │
│  │  │   Firebase  │  │   Yahoo    │ │ │
│  │  │    Auth     │  │  Finance   │ │ │
│  │  └─────────────┘  └────────────┘ │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### Firestore 데이터 구조

```javascript
users/
  {userId}/
    email: "user@example.com"
    createdAt: timestamp

    portfolios/
      {portfolioId}/
        ticker: "005930.KS"
        name: "삼성전자"
        quantity: 10
        averageCost: 70000
        market: "KS"
        createdAt: timestamp
        updatedAt: timestamp

    daily_snapshots/
      {date: "2025-01-15"}/
        totalValue: 1500000
        totalInvestment: 1200000
        totalProfit: 300000
        dailyProfit: 50000
        createdAt: timestamp

    profit_series/
      {date: "2025-01-15"}/
        dailyProfit: 50000
        monthlyCumulative: 200000
        annualCumulative: 300000
        createdAt: timestamp
```

### 마이그레이션 전략

**로컬 → Firebase 데이터 마이그레이션**

```dart
class MigrationService {
  Future<void> migrateToFirebase(String userId) async {
    final db = await DatabaseService().database;
    final firestore = FirebaseFirestore.instance;

    // 1. 포트폴리오 마이그레이션
    final portfolios = await db.query('portfolios');
    for (var portfolio in portfolios) {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('portfolios')
          .add({
        'ticker': portfolio['ticker'],
        'name': portfolio['name'],
        'quantity': portfolio['quantity'],
        'averageCost': portfolio['average_cost'],
        'market': portfolio['market'],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // 2. 스냅샷 마이그레이션
    final snapshots = await db.query('daily_snapshots');
    for (var snapshot in snapshots) {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('daily_snapshots')
          .doc(snapshot['snapshot_date'])
          .set({
        'totalValue': snapshot['total_value'],
        'totalInvestment': snapshot['total_investment'],
        'totalProfit': snapshot['total_profit'],
        'dailyProfit': snapshot['daily_profit'],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    print('Migration completed!');
  }
}
```

### Phase 2 기능 추가

- [ ] Firebase 인증 (이메일/구글)
- [ ] Firestore 데이터 동기화
- [ ] 로컬 → 클라우드 마이그레이션 기능
- [ ] 멀티 디바이스 지원
- [ ] 데이터 백업 및 복원
- [ ] iOS 앱 출시

**예상 개발 기간:** +3-4주

---

## 📊 전체 로드맵

| Phase | 기능 | 기간 | 누적 기간 |
|-------|------|------|----------|
| **1.1** | 기본 인프라 | 1주 | 1주 |
| **1.2** | 포트폴리오 관리 | 2주 | 3주 |
| **1.3** | 대시보드 | 2주 | 5주 |
| **1.4** | 그래프 | 2주 | 7주 |
| **1.5** | 배포 (Android) | 1주 | **8주 (MVP 완료)** |
| **2.0** | Firebase 추가 | 3-4주 | **11-12주 (정식 출시)** |

**총 개발 기간:** 약 3개월

---

## 💰 비용 예상

### Phase 1 (MVP)
- 호스팅: $0 (로컬 앱)
- API: $0 (Yahoo Finance 무료)
- Google Play 등록: $25 (1회)
- **총: $25**

### Phase 2 (정식 출시)
- Firebase 무료 플랜:
  - Firestore: 50,000 읽기/일, 20,000 쓰기/일
  - Auth: 무제한
  - Storage: 5GB
- Google Play: $0 (이미 등록됨)
- App Store 등록: $99/년
- **월 비용: $0 (무료 플랜 내)**
- **연 비용: $99 (iOS만 해당)**

---

## 🎯 다음 단계

**바로 시작하시겠습니까?**

1. Flutter 프로젝트 생성
2. 필요한 패키지 설치
3. SQLite 데이터베이스 설정
4. Yahoo Finance API 테스트

명령어를 실행할까요?
