class Category {
  final int id;
  final String name; // 'nasdaq', 'sp500', 'dividend'
  final String displayName; // '나스닥', 'S&P500', '배당'
  final String icon; // '🚀', '🏛️', '💰'
  final String color; // '#3B82F6', '#10B981', '#F59E0B'
  final String description;
  final double? targetAmount; // 목표 금액 (원) - 포메뽀꼬 "n억 모으기"
  final double? targetWeight; // 목표 비중 (%) - 리밸런싱 기준

  Category({
    required this.id,
    required this.name,
    required this.displayName,
    required this.icon,
    required this.color,
    required this.description,
    this.targetAmount,
    this.targetWeight,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      displayName: map['display_name'] as String,
      icon: map['icon'] as String,
      color: map['color'] as String,
      description: map['description'] as String,
      targetAmount: map['target_amount'] as double?,
      targetWeight: map['target_weight'] as double?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
      'icon': icon,
      'color': color,
      'description': description,
      'target_amount': targetAmount,
      'target_weight': targetWeight,
    };
  }

  // 3가지 기본 카테고리
  static Category get nasdaq => Category(
        id: 1,
        name: 'nasdaq',
        displayName: '나스닥',
        icon: '🚀',
        color: '#3B82F6',
        description: '고성장 기술주 중심',
      );

  static Category get sp500 => Category(
        id: 2,
        name: 'sp500',
        displayName: 'S&P500',
        icon: '🏛️',
        color: '#10B981',
        description: '안정적 시장 평균',
      );

  static Category get dividend => Category(
        id: 3,
        name: 'dividend',
        displayName: '배당',
        icon: '💰',
        color: '#F59E0B',
        description: '꾸준한 현금흐름',
      );

  static List<Category> get all => [nasdaq, sp500, dividend];

  @override
  String toString() {
    return 'Category(id: $id, name: $name, displayName: $displayName)';
  }
}
