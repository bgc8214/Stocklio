# 주식 검색 솔루션

## 문제점

야후 파이낸스는 **종목명으로 직접 검색이 어렵습니다**:
- "카카오" 검색 → 결과 없음
- "035720.KS" 검색 → 정상 작동

사용자는 티커를 모르기 때문에 종목명으로 검색할 수 있어야 합니다.

---

## ✅ 해결 방법: 로컬 종목 DB 구축

### 전략
1. **앱 초기 실행 시** KRX 전체 종목 리스트를 다운로드
2. **SQLite에 저장** (종목명 → 티커 매핑)
3. **로컬에서 검색** (빠르고 오프라인 가능)
4. **주기적 업데이트** (월 1회 또는 수동)

---

## 구현 방법

### 1. KRX 종목 리스트 다운로드

**API 옵션 A: 공공데이터포털 (무료)** ⭐ 추천
```
API: 금융위원회_KRX상장종목정보
URL: https://www.data.go.kr/tcs/dss/selectApiDataDetailView.do?publicDataPk=15094775

제공 데이터:
- 종목코드 (6자리)
- 종목명 (한글)
- 시장구분 (KOSPI/KOSDAQ)
- 업종
```

**사용 방법:**
```dart
// services/krx_service.dart
class KRXService {
  static const String API_KEY = 'YOUR_API_KEY'; // 공공데이터포털에서 발급
  static const String BASE_URL = 'http://apis.data.go.kr/1160100/service/GetKrxListedInfoService';

  Future<List<StockInfo>> fetchKRXStockList() async {
    final dio = Dio();

    try {
      final response = await dio.get(
        '$BASE_URL/getItemInfo',
        queryParameters: {
          'serviceKey': API_KEY,
          'numOfRows': 3000,
          'resultType': 'json',
        },
      );

      final items = response.data['response']['body']['items']['item'];
      return items.map<StockInfo>((item) => StockInfo(
        ticker: '${item['srtnCd']}.KS', // 6자리 코드 + .KS
        name: item['itmsNm'],
        market: item['mrktCtg'], // KOSPI/KOSDAQ
      )).toList();
    } catch (e) {
      print('Error fetching KRX list: $e');
      return [];
    }
  }
}
```

**API 옵션 B: KRX 웹사이트 크롤링 (백업)**
```dart
Future<List<StockInfo>> fetchKRXFromWeb() async {
  final dio = Dio();

  // KRX KIND 사이트
  final url = 'http://kind.krx.co.kr/corpgeneral/corpList.do';
  final response = await dio.get(
    url,
    queryParameters: {
      'method': 'download',
      'marketType': 'stockMkt', // stockMkt=전체, kosdaqMkt=코스닥
    },
  );

  // HTML 파싱 후 종목 정보 추출
  // (html 패키지 사용)
}
```

**API 옵션 C: 사전 준비된 JSON 파일 (가장 간단)** ⭐⭐ MVP 추천
```json
// assets/krx_stocks.json
[
  {
    "ticker": "005930.KS",
    "name": "삼성전자",
    "market": "KOSPI"
  },
  {
    "ticker": "035720.KS",
    "name": "카카오",
    "market": "KOSPI"
  },
  {
    "ticker": "035420.KQ",
    "name": "NAVER",
    "market": "KOSDAQ"
  }
  // ... 약 2,500개 종목
]
```

**장점:**
- API 호출 불필요
- 즉시 사용 가능
- 오프라인 작동
- 무료

**단점:**
- 신규 상장 종목은 수동 업데이트 필요
- 앱 용량 약간 증가 (~200KB)

---

### 2. SQLite에 저장

```dart
// services/database_service.dart
class DatabaseService {
  Future<void> createStockMasterTable(Database db) async {
    await db.execute('''
      CREATE TABLE stock_master (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ticker TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        name_eng TEXT,
        market TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 검색 성능을 위한 인덱스
    await db.execute('CREATE INDEX idx_stock_name ON stock_master(name)');
    await db.execute('CREATE INDEX idx_stock_ticker ON stock_master(ticker)');
  }

  Future<void> insertStockMaster(List<StockInfo> stocks) async {
    final db = await database;
    final batch = db.batch();

    for (var stock in stocks) {
      batch.insert(
        'stock_master',
        stock.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  // 종목명으로 검색
  Future<List<StockInfo>> searchStockByName(String query) async {
    final db = await database;

    final results = await db.query(
      'stock_master',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      limit: 20,
    );

    return results.map((map) => StockInfo.fromMap(map)).toList();
  }

  // 티커로 조회
  Future<StockInfo?> getStockByTicker(String ticker) async {
    final db = await database;

    final results = await db.query(
      'stock_master',
      where: 'ticker = ?',
      whereArgs: [ticker],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return StockInfo.fromMap(results.first);
  }
}
```

---

### 3. 앱 초기화 시 종목 DB 로드

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 종목 마스터 데이터 초기화
  await initializeStockMaster();

  runApp(MyApp());
}

Future<void> initializeStockMaster() async {
  final db = DatabaseService();
  final prefs = await SharedPreferences.getInstance();

  // 마지막 업데이트 확인
  final lastUpdate = prefs.getString('stock_master_last_update');
  final now = DateTime.now();

  if (lastUpdate == null || _shouldUpdate(lastUpdate, now)) {
    print('Updating stock master data...');

    // 옵션 1: 로컬 JSON 파일에서 로드
    final jsonString = await rootBundle.loadString('assets/krx_stocks.json');
    final jsonList = json.decode(jsonString) as List;
    final stocks = jsonList.map((e) => StockInfo.fromJson(e)).toList();

    // 옵션 2: API에서 로드 (선택)
    // final stocks = await KRXService().fetchKRXStockList();

    await db.insertStockMaster(stocks);
    await prefs.setString('stock_master_last_update', now.toIso8601String());

    print('Stock master data updated!');
  }
}

bool _shouldUpdate(String lastUpdateStr, DateTime now) {
  final lastUpdate = DateTime.parse(lastUpdateStr);
  final diff = now.difference(lastUpdate);
  return diff.inDays > 30; // 30일마다 업데이트
}
```

---

### 4. 검색 UI 구현

```dart
// screens/add_stock_screen.dart
class AddStockScreen extends StatefulWidget {
  @override
  _AddStockScreenState createState() => _AddStockScreenState();
}

class _AddStockScreenState extends State<AddStockScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<StockInfo> _searchResults = [];
  bool _isSearching = false;

  Future<void> _searchStocks(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    final db = DatabaseService();
    final results = await db.searchStockByName(query);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('종목 검색')),
      body: Column(
        children: [
          // 검색창
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '종목명 또는 티커 입력 (예: 삼성전자, 005930)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _searchStocks,
            ),
          ),

          // 검색 결과
          Expanded(
            child: _isSearching
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final stock = _searchResults[index];
                      return ListTile(
                        title: Text(stock.name),
                        subtitle: Text('${stock.ticker} · ${stock.market}'),
                        trailing: Icon(Icons.add_circle_outline),
                        onTap: () => _selectStock(stock),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _selectStock(StockInfo stock) {
    // 종목 선택 후 수량/평단가 입력 화면으로 이동
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPortfolioScreen(stock: stock),
      ),
    );
  }
}
```

---

### 5. 미국 주식 검색 (Yahoo Finance API)

```dart
// services/yahoo_finance_service.dart
class YahooFinanceService {
  // 야후 파이낸스 검색 API (미국 주식용)
  Future<List<StockInfo>> searchUSStocks(String query) async {
    final dio = Dio();

    try {
      final response = await dio.get(
        'https://query2.finance.yahoo.com/v1/finance/search',
        queryParameters: {
          'q': query,
          'quotesCount': 10,
          'newsCount': 0,
          'enableFuzzyQuery': false,
        },
        options: Options(
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
          },
        ),
      );

      final quotes = response.data['quotes'] as List;
      return quotes.map((quote) => StockInfo(
        ticker: quote['symbol'],
        name: quote['shortname'] ?? quote['longname'],
        market: 'US',
      )).toList();
    } catch (e) {
      print('Error searching US stocks: $e');
      return [];
    }
  }
}
```

---

### 6. 통합 검색 (한국 + 미국)

```dart
// services/unified_search_service.dart
class UnifiedSearchService {
  final DatabaseService _db = DatabaseService();
  final YahooFinanceService _yahoo = YahooFinanceService();

  Future<List<StockInfo>> search(String query) async {
    final results = <StockInfo>[];

    // 1. 한국 주식 검색 (로컬 DB)
    final krxResults = await _db.searchStockByName(query);
    results.addAll(krxResults);

    // 2. 미국 주식 검색 (Yahoo Finance API)
    // 한글 입력이면 스킵, 영문이면 검색
    if (_isEnglish(query)) {
      final usResults = await _yahoo.searchUSStocks(query);
      results.addAll(usResults);
    }

    return results;
  }

  bool _isEnglish(String text) {
    return RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(text);
  }
}
```

---

## 📊 최종 검색 플로우

```
사용자 입력: "카카오"
      ↓
로컬 DB 검색 (SQLite)
      ↓
결과:
  - 카카오 (035720.KS)
  - 카카오페이 (377300.KS)
  - 카카오뱅크 (323410.KS)
      ↓
사용자 선택: 카카오 (035720.KS)
      ↓
Yahoo Finance API로 현재가 조회
      ↓
포트폴리오에 추가
```

```
사용자 입력: "Apple"
      ↓
영문 감지 → Yahoo Finance 검색 API 호출
      ↓
결과:
  - Apple Inc. (AAPL)
  - Apple Hospitality REIT (APLE)
      ↓
사용자 선택: Apple Inc. (AAPL)
      ↓
Yahoo Finance API로 현재가 조회
      ↓
포트폴리오에 추가
```

---

## 🎯 MVP 권장 방식

### Phase 1: 사전 준비된 JSON 파일 사용

**이유:**
- ✅ 가장 빠르게 구현 가능
- ✅ API 키 불필요
- ✅ 오프라인 작동
- ✅ 무료

**구현 시간:** 1-2일

**JSON 파일 생성 방법:**
1. KRX 웹사이트에서 전체 종목 리스트 다운로드
2. CSV → JSON 변환
3. `assets/krx_stocks.json`에 저장
4. 앱에 포함

### Phase 2: API 기반 업데이트 (추후)

**Phase 2에서 추가:**
- 설정 화면에 "종목 정보 업데이트" 버튼
- 공공데이터포털 API 또는 KRX 크롤링
- 신규 상장 종목 자동 추가

---

## 📦 필요한 패키지

```yaml
# pubspec.yaml
dependencies:
  dio: ^5.4.0           # HTTP 클라이언트
  sqflite: ^2.3.0       # SQLite
  shared_preferences: ^2.2.0  # 마지막 업데이트 시간 저장
```

---

## 📝 다음 단계

이제 이 방식으로 구현하시겠습니까?

1. ✅ Flutter 프로젝트 생성
2. ✅ KRX 종목 JSON 파일 준비
3. ✅ SQLite 검색 기능 구현
4. ✅ 검색 UI 개발

시작하시겠습니까?
