class SupportedTicker {
  final int id;
  final String ticker;
  final String name;
  final int categoryId;
  final String type; // 'etf', 'stock', 'leveraged'
  final bool isKoreanListed;
  final String? description;

  SupportedTicker({
    required this.id,
    required this.ticker,
    required this.name,
    required this.categoryId,
    required this.type,
    this.isKoreanListed = false,
    this.description,
  });

  factory SupportedTicker.fromMap(Map<String, dynamic> map) {
    return SupportedTicker(
      id: map['id'] as int,
      ticker: map['ticker'] as String,
      name: map['name'] as String,
      categoryId: map['category_id'] as int,
      type: map['type'] as String,
      isKoreanListed: (map['is_korean_listed'] as int) == 1,
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticker': ticker,
      'name': name,
      'category_id': categoryId,
      'type': type,
      'is_korean_listed': isKoreanListed ? 1 : 0,
      'description': description,
    };
  }

  bool get isLeveraged => type == 'leveraged';
  bool get isStock => type == 'stock';
  bool get isETF => type == 'etf';

  @override
  String toString() {
    return 'SupportedTicker(ticker: $ticker, name: $name, type: $type)';
  }
}

// 지원 종목 초기 데이터
class SupportedTickers {
  // 나스닥 카테고리 (categoryId: 1)
  static final List<Map<String, dynamic>> nasdaqTickers = [
    // 기본 ETF
    {'ticker': 'QQQ', 'name': 'Invesco QQQ Trust', 'type': 'etf', 'korean': false, 'desc': '나스닥100 추종'},
    {'ticker': 'QQQM', 'name': 'Invesco NASDAQ 100 ETF', 'type': 'etf', 'korean': false, 'desc': '나스닥100 저비용'},

    // 레버리지 ETF
    {'ticker': 'TQQQ', 'name': 'ProShares UltraPro QQQ', 'type': 'leveraged', 'korean': false, 'desc': '나스닥100 3배'},
    {'ticker': 'QLD', 'name': 'ProShares Ultra QQQ', 'type': 'leveraged', 'korean': false, 'desc': '나스닥100 2배'},

    // 한국 상장
    {'ticker': '133690', 'name': 'TIGER 미국나스닥100', 'type': 'etf', 'korean': true, 'desc': '한국 상장'},
    {'ticker': '360750', 'name': 'TIGER 미국나스닥100커버드콜(합성)', 'type': 'etf', 'korean': true, 'desc': '한국 상장'},
    {'ticker': '453810', 'name': 'ACE 미국나스닥100', 'type': 'etf', 'korean': true, 'desc': '한국 상장'},
    {'ticker': '379810', 'name': 'KODEX 미국나스닥100(H)', 'type': 'etf', 'korean': true, 'desc': '한국 상장 환헷지'},

    // 개별 기술주
    {'ticker': 'AAPL', 'name': 'Apple Inc.', 'type': 'stock', 'korean': false, 'desc': '애플'},
    {'ticker': 'MSFT', 'name': 'Microsoft Corporation', 'type': 'stock', 'korean': false, 'desc': '마이크로소프트'},
    {'ticker': 'NVDA', 'name': 'NVIDIA Corporation', 'type': 'stock', 'korean': false, 'desc': '엔비디아'},
    {'ticker': 'GOOGL', 'name': 'Alphabet Inc.', 'type': 'stock', 'korean': false, 'desc': '구글'},
    {'ticker': 'AMZN', 'name': 'Amazon.com Inc.', 'type': 'stock', 'korean': false, 'desc': '아마존'},
    {'ticker': 'META', 'name': 'Meta Platforms Inc.', 'type': 'stock', 'korean': false, 'desc': '메타'},
    {'ticker': 'TSLA', 'name': 'Tesla Inc.', 'type': 'stock', 'korean': false, 'desc': '테슬라'},
    {'ticker': 'NFLX', 'name': 'Netflix Inc.', 'type': 'stock', 'korean': false, 'desc': '넷플릭스'},
  ];

  // S&P500 카테고리 (categoryId: 2)
  static final List<Map<String, dynamic>> sp500Tickers = [
    // 기본 ETF
    {'ticker': 'SPY', 'name': 'SPDR S&P 500 ETF Trust', 'type': 'etf', 'korean': false, 'desc': 'S&P500'},
    {'ticker': 'VOO', 'name': 'Vanguard S&P 500 ETF', 'type': 'etf', 'korean': false, 'desc': 'S&P500 저비용'},
    {'ticker': 'IVV', 'name': 'iShares Core S&P 500 ETF', 'type': 'etf', 'korean': false, 'desc': 'S&P500'},
    {'ticker': 'SPLG', 'name': 'SPDR Portfolio S&P 500 ETF', 'type': 'etf', 'korean': false, 'desc': 'S&P500 초저비용'},

    // 레버리지 ETF
    {'ticker': 'SSO', 'name': 'ProShares Ultra S&P500', 'type': 'leveraged', 'korean': false, 'desc': 'S&P500 2배'},
    {'ticker': 'SPXL', 'name': 'Direxion Daily S&P 500 Bull 3X', 'type': 'leveraged', 'korean': false, 'desc': 'S&P500 3배'},

    // 성장형
    {'ticker': 'SPYG', 'name': 'SPDR Portfolio S&P 500 Growth ETF', 'type': 'etf', 'korean': false, 'desc': 'S&P500 성장주'},
    {'ticker': 'VUG', 'name': 'Vanguard Growth ETF', 'type': 'etf', 'korean': false, 'desc': '대형 성장주'},
    {'ticker': 'VTI', 'name': 'Vanguard Total Stock Market ETF', 'type': 'etf', 'korean': false, 'desc': '미국 전체 시장'},

    // 한국 상장
    {'ticker': '360750', 'name': 'TIGER S&P500', 'type': 'etf', 'korean': true, 'desc': '한국 상장'},
    {'ticker': '453810', 'name': 'ACE S&P500', 'type': 'etf', 'korean': true, 'desc': '한국 상장'},
    {'ticker': '379810', 'name': 'KODEX S&P500', 'type': 'etf', 'korean': true, 'desc': '한국 상장'},
    {'ticker': '379800', 'name': 'KODEX S&P500(H)', 'type': 'etf', 'korean': true, 'desc': '한국 상장 환헷지'},
    {'ticker': '453850', 'name': '1Q S&P500', 'type': 'etf', 'korean': true, 'desc': '한국 상장'},

    // 다우존스
    {'ticker': 'DIA', 'name': 'SPDR Dow Jones Industrial Average ETF', 'type': 'etf', 'korean': false, 'desc': '다우30'},
    {'ticker': 'DDM', 'name': 'ProShares Ultra Dow30', 'type': 'leveraged', 'korean': false, 'desc': '다우30 2배'},
  ];

  // 배당 카테고리 (categoryId: 3)
  static final List<Map<String, dynamic>> dividendTickers = [
    // 배당 성장
    {'ticker': 'SCHD', 'name': 'Schwab U.S. Dividend Equity ETF', 'type': 'etf', 'korean': false, 'desc': '배당 성장주'},
    {'ticker': 'DGRW', 'name': 'WisdomTree U.S. Quality Dividend Growth', 'type': 'etf', 'korean': false, 'desc': '배당 성장'},
    {'ticker': 'VIG', 'name': 'Vanguard Dividend Appreciation ETF', 'type': 'etf', 'korean': false, 'desc': '배당 귀족주'},
    {'ticker': 'DGRO', 'name': 'iShares Core Dividend Growth ETF', 'type': 'etf', 'korean': false, 'desc': '배당 성장'},

    // 배당 수익
    {'ticker': 'DIVO', 'name': 'Amplify CWP Enhanced Dividend Income ETF', 'type': 'etf', 'korean': false, 'desc': '배당+커버드콜'},
    {'ticker': 'QDVO', 'name': 'Amplify CWP Enhanced Dividend Income ETF', 'type': 'etf', 'korean': false, 'desc': '나스닥 배당'},
    {'ticker': 'JEPI', 'name': 'JPMorgan Equity Premium Income ETF', 'type': 'etf', 'korean': false, 'desc': '커버드콜'},
    {'ticker': 'JEPQ', 'name': 'JPMorgan Nasdaq Equity Premium Income ETF', 'type': 'etf', 'korean': false, 'desc': '나스닥 커버드콜'},

    // 한국 상장 배당
    {'ticker': '458730', 'name': 'TIGER 미국배당', 'type': 'etf', 'korean': true, 'desc': '한국 상장'},
    {'ticker': '453850', 'name': 'ACE 미국배당', 'type': 'etf', 'korean': true, 'desc': '한국 상장'},
    {'ticker': '379800', 'name': 'KODEX 배당커버드콜', 'type': 'etf', 'korean': true, 'desc': '한국 상장'},
  ];

  static List<SupportedTicker> getAllTickers() {
    final List<SupportedTicker> tickers = [];
    int id = 1;

    // 나스닥
    for (var data in nasdaqTickers) {
      tickers.add(SupportedTicker(
        id: id++,
        ticker: data['ticker'],
        name: data['name'],
        categoryId: 1,
        type: data['type'],
        isKoreanListed: data['korean'],
        description: data['desc'],
      ));
    }

    // S&P500
    for (var data in sp500Tickers) {
      tickers.add(SupportedTicker(
        id: id++,
        ticker: data['ticker'],
        name: data['name'],
        categoryId: 2,
        type: data['type'],
        isKoreanListed: data['korean'],
        description: data['desc'],
      ));
    }

    // 배당
    for (var data in dividendTickers) {
      tickers.add(SupportedTicker(
        id: id++,
        ticker: data['ticker'],
        name: data['name'],
        categoryId: 3,
        type: data['type'],
        isKoreanListed: data['korean'],
        description: data['desc'],
      ));
    }

    return tickers;
  }
}
