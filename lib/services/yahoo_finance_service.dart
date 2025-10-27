import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

class YahooFinanceService {
  /// 현재가 조회
  Future<double?> getCurrentPrice(String ticker) async {
    try {
      final reader = YahooFinanceDailyReader();
      final response = await reader.getDailyDTOs(ticker);

      if (response.candlesData.isNotEmpty) {
        return response.candlesData.last.close;
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting price for $ticker: $e');
      return null;
    }
  }

  /// 여러 종목의 현재가 일괄 조회
  Future<Map<String, double>> getBatchPrices(List<String> tickers) async {
    final prices = <String, double>{};

    for (var ticker in tickers) {
      final price = await getCurrentPrice(ticker);
      if (price != null) {
        prices[ticker] = price;
      }

      // API 부담 줄이기 위한 딜레이
      await Future.delayed(const Duration(milliseconds: 300));
    }

    return prices;
  }

  /// 종목 검색 (티커로)
  Future<Map<String, dynamic>?> searchStock(String ticker) async {
    try {
      final reader = YahooFinanceDailyReader();
      final response = await reader.getDailyDTOs(ticker);

      if (response.candlesData.isNotEmpty) {
        final latest = response.candlesData.last;
        return {
          'ticker': ticker,
          'currentPrice': latest.close,
          'lastUpdate': latest.date,
          'open': latest.open,
          'high': latest.high,
          'low': latest.low,
          'volume': latest.volume,
        };
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error searching stock $ticker: $e');
      return null;
    }
  }

  /// 과거 데이터 조회
  Future<List<Map<String, dynamic>>> getHistoricalData({
    required String ticker,
    int days = 30,
  }) async {
    try {
      final reader = YahooFinanceDailyReader();
      final response = await reader.getDailyDTOs(ticker);

      // 최근 N일 데이터만 반환
      final recentData = response.candlesData.length > days
          ? response.candlesData.sublist(response.candlesData.length - days)
          : response.candlesData;

      return recentData
          .map((candle) => {
                'date': candle.date,
                'open': candle.open,
                'high': candle.high,
                'low': candle.low,
                'close': candle.close,
                'volume': candle.volume,
              })
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error getting historical data for $ticker: $e');
      return [];
    }
  }

  /// 종목이 유효한지 확인
  Future<bool> isValidTicker(String ticker) async {
    try {
      final price = await getCurrentPrice(ticker);
      return price != null;
    } catch (e) {
      return false;
    }
  }
}
