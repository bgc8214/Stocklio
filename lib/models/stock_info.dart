class StockInfo {
  final String ticker;
  final String name;
  final String market; // 'KOSPI', 'KOSDAQ', 'US'

  StockInfo({
    required this.ticker,
    required this.name,
    required this.market,
  });

  factory StockInfo.fromJson(Map<String, dynamic> json) {
    return StockInfo(
      ticker: json['ticker'] as String,
      name: json['name'] as String,
      market: json['market'] as String,
    );
  }

  factory StockInfo.fromMap(Map<String, dynamic> map) {
    return StockInfo(
      ticker: map['ticker'] as String,
      name: map['name'] as String,
      market: map['market'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ticker': ticker,
      'name': name,
      'market': market,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'ticker': ticker,
      'name': name,
      'market': market,
    };
  }
}
