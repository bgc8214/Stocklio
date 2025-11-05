class RecommendedETF {
  final String ticker;
  final String name;
  final String description;
  final String market; // 'KR' or 'US'
  final double expenseRatio; // 총보수 (%)
  final double? dividendYield; // 배당률 (%, optional)
  final String? features; // 특징 (예: 월배당, 저비용 등)

  const RecommendedETF({
    required this.ticker,
    required this.name,
    required this.description,
    required this.market,
    required this.expenseRatio,
    this.dividendYield,
    this.features,
  });

  // Yahoo Finance용 티커 변환
  String get yahooTicker {
    if (market == 'KR') {
      // 한국 ETF는 .KS 또는 .KQ 추가 필요
      return '$ticker.KS'; // 대부분 KOSPI 상장
    }
    return ticker; // 미국 ETF는 그대로
  }

  // 국가별 라벨
  String get marketLabel {
    return market == 'KR' ? '🇰🇷 한국' : '🇺🇸 미국';
  }

  // 비용 표시 문자열
  String get expenseRatioText {
    return '${expenseRatio.toStringAsFixed(4)}%';
  }

  // 배당률 표시 문자열
  String get dividendYieldText {
    if (dividendYield == null) return '-';
    return '${dividendYield!.toStringAsFixed(2)}%';
  }
}
