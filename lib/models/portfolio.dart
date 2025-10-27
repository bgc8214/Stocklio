class Portfolio {
  final int? id;
  final String ticker;
  final String name;
  final int quantity;
  final double averageCost;
  final String market;
  double currentPrice; // 현재가 (변동 가능)
  final DateTime createdAt;
  final DateTime updatedAt;

  Portfolio({
    this.id,
    required this.ticker,
    required this.name,
    required this.quantity,
    required this.averageCost,
    required this.market,
    double? currentPrice,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : currentPrice = currentPrice ?? averageCost,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // stockName getter (name과 동일)
  String get stockName => name;

  // averagePrice getter (averageCost와 동일)
  double get averagePrice => averageCost;

  factory Portfolio.fromMap(Map<String, dynamic> map) {
    return Portfolio(
      id: map['id'] as int?,
      ticker: map['ticker'] as String,
      name: map['name'] as String,
      quantity: (map['quantity'] as num).toInt(),
      averageCost: (map['average_cost'] as num).toDouble(),
      market: map['market'] as String,
      currentPrice: map['current_price'] != null
          ? (map['current_price'] as num).toDouble()
          : (map['average_cost'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'ticker': ticker,
      'name': name,
      'quantity': quantity,
      'average_cost': averageCost,
      'current_price': currentPrice,
      'market': market,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Portfolio copyWith({
    int? id,
    String? ticker,
    String? name,
    int? quantity,
    double? averageCost,
    double? currentPrice,
    String? market,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Portfolio(
      id: id ?? this.id,
      ticker: ticker ?? this.ticker,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      averageCost: averageCost ?? this.averageCost,
      currentPrice: currentPrice ?? this.currentPrice,
      market: market ?? this.market,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
