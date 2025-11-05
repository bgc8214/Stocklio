import '../models/recommended_etf.dart';

class RecommendedETFs {
  // 카테고리별 추천 ETF 데이터
  static const Map<int, List<RecommendedETF>> recommendations = {
    // 1. 나스닥 100 (성장주)
    1: [
      // 🇺🇸 미국 나스닥 100 ETF
      RecommendedETF(
        ticker: 'QQQ',
        name: 'Invesco QQQ Trust',
        description: '나스닥 100 지수 추종 (애플, MS, 구글 등 빅테크)',
        market: 'US',
        expenseRatio: 0.20,
        features: '최대 규모, 최고 유동성',
      ),
      RecommendedETF(
        ticker: 'QQQM',
        name: 'Invesco NASDAQ 100 ETF',
        description: 'QQQ와 동일한 구성, 더 저렴한 수수료',
        market: 'US',
        expenseRatio: 0.15,
        features: '저비용 대안',
      ),
      RecommendedETF(
        ticker: 'ONEQ',
        name: 'Fidelity Nasdaq Composite Index',
        description: '나스닥 전체 지수 추종 (나스닥100 + 중소형주)',
        market: 'US',
        expenseRatio: 0.21,
        features: '더 넓은 분산투자',
      ),

      // 🇰🇷 한국 상장 나스닥 100 ETF
      RecommendedETF(
        ticker: '133690',
        name: 'TIGER 미국나스닥100',
        description: '국내 최대 규모, 최저 수수료',
        market: 'KR',
        expenseRatio: 0.0068,
        features: '초저비용, 연금계좌 가능',
      ),
      RecommendedETF(
        ticker: '379800',
        name: 'KODEX 미국나스닥100',
        description: '삼성운용, 안정적 운용',
        market: 'KR',
        expenseRatio: 0.0062,
        features: '최저 운용보수',
      ),
      RecommendedETF(
        ticker: '453810',
        name: 'ACE 미국나스닥100',
        description: '한국투자운용, 장기투자 적합',
        market: 'KR',
        expenseRatio: 0.09,
        features: '안정적 추적',
      ),
    ],

    // 2. S&P 500 (대형주)
    2: [
      // 🇺🇸 미국 S&P 500 ETF
      RecommendedETF(
        ticker: 'VOO',
        name: 'Vanguard S&P 500 ETF',
        description: 'S&P 500 추종, 초저비용의 대표 ETF',
        market: 'US',
        expenseRatio: 0.03,
        features: '뱅가드, 초저비용',
      ),
      RecommendedETF(
        ticker: 'SPY',
        name: 'SPDR S&P 500 ETF Trust',
        description: '세계 최대 규모, 최고 유동성',
        market: 'US',
        expenseRatio: 0.09,
        features: '최고 거래량',
      ),
      RecommendedETF(
        ticker: 'IVV',
        name: 'iShares Core S&P 500 ETF',
        description: '블랙록 운용, 초저비용',
        market: 'US',
        expenseRatio: 0.03,
        features: '저비용',
      ),

      // 🇰🇷 한국 상장 S&P 500 ETF
      RecommendedETF(
        ticker: '360750',
        name: 'TIGER 미국S&P500',
        description: '국내 S&P500 ETF 1위, 최저 실질비용',
        market: 'KR',
        expenseRatio: 0.0068,
        features: '초저비용, 최대 규모',
      ),
      RecommendedETF(
        ticker: '379810',
        name: 'KODEX 미국S&P500',
        description: '삼성운용, 배당 전략 추가',
        market: 'KR',
        expenseRatio: 0.0062,
        features: '분기배당 전략',
      ),
      RecommendedETF(
        ticker: '478160',
        name: 'ACE 미국S&P500',
        description: '한국투자운용, 안정적 운용',
        market: 'KR',
        expenseRatio: 0.07,
        features: '연금계좌 가능',
      ),
      RecommendedETF(
        ticker: '453850',
        name: 'RISE 미국S&P500',
        description: 'KB운용, 최저 운용보수',
        market: 'KR',
        expenseRatio: 0.0047,
        features: '최저 운용보수',
      ),
    ],

    // 3. 고배당 (배당 성장)
    3: [
      // 🇺🇸 미국 배당 ETF
      RecommendedETF(
        ticker: 'SCHD',
        name: 'Schwab U.S. Dividend Equity ETF',
        description: '배당 성장주 중심, 미국 배당 ETF의 대표',
        market: 'US',
        expenseRatio: 0.06,
        dividendYield: 3.74,
        features: '배당성장 11%/년',
      ),
      RecommendedETF(
        ticker: 'VYM',
        name: 'Vanguard High Dividend Yield ETF',
        description: '고배당 대형주 중심, 최대 규모',
        market: 'US',
        expenseRatio: 0.06,
        dividendYield: 3.0,
        features: '분기배당, 최대 규모',
      ),
      RecommendedETF(
        ticker: 'DGRO',
        name: 'iShares Core Dividend Growth ETF',
        description: '배당 성장 중시, 빅테크 포함',
        market: 'US',
        expenseRatio: 0.08,
        dividendYield: 2.5,
        features: '배당성장, 기술주 포함',
      ),
      RecommendedETF(
        ticker: 'JEPI',
        name: 'JPMorgan Equity Premium Income ETF',
        description: '월배당 + 커버드콜 전략, 초고배당',
        market: 'US',
        expenseRatio: 0.35,
        dividendYield: 10.0,
        features: '월배당, 커버드콜',
      ),
      RecommendedETF(
        ticker: 'HDV',
        name: 'iShares Core High Dividend ETF',
        description: '배당 안정성 중시, 에너지·헬스케어 비중',
        market: 'US',
        expenseRatio: 0.08,
        dividendYield: 3.8,
        features: '배당 안정성',
      ),

      // 🇰🇷 한국 상장 미국배당 ETF (SCHD 추종)
      RecommendedETF(
        ticker: '458730',
        name: 'TIGER 미국배당다우존스',
        description: 'SCHD와 동일 지수 추종, 최저 비용',
        market: 'KR',
        expenseRatio: 0.1109,
        dividendYield: 3.5,
        features: '월배당, 연금계좌',
      ),
      RecommendedETF(
        ticker: '453530',
        name: 'KODEX 미국배당다우존스',
        description: 'SCHD 추종, 월배당',
        market: 'KR',
        expenseRatio: 0.15,
        dividendYield: 3.5,
        features: '월배당',
      ),
      RecommendedETF(
        ticker: '441680',
        name: 'ACE 미국배당다우존스',
        description: 'SCHD 추종, 월배당',
        market: 'KR',
        expenseRatio: 0.15,
        dividendYield: 3.5,
        features: '월배당',
      ),
      RecommendedETF(
        ticker: '441640',
        name: 'SOL 미국배당다우존스',
        description: 'SCHD 추종, 월배당',
        market: 'KR',
        expenseRatio: 0.15,
        dividendYield: 3.5,
        features: '월배당',
      ),
    ],
  };

  // 특정 카테고리의 추천 ETF 목록 가져오기
  static List<RecommendedETF> getRecommendations(int categoryId) {
    return recommendations[categoryId] ?? [];
  }

  // 카테고리별 미국 ETF만 가져오기
  static List<RecommendedETF> getUSRecommendations(int categoryId) {
    return getRecommendations(categoryId)
        .where((etf) => etf.market == 'US')
        .toList();
  }

  // 카테고리별 한국 ETF만 가져오기
  static List<RecommendedETF> getKRRecommendations(int categoryId) {
    return getRecommendations(categoryId)
        .where((etf) => etf.market == 'KR')
        .toList();
  }
}
