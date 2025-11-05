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

  /// 특정 날짜의 과거 종가 조회
  Future<double?> getHistoricalPrice(String ticker, DateTime date) async {
    try {
      final reader = YahooFinanceDailyReader();
      final response = await reader.getDailyDTOs(ticker);

      if (response.candlesData.isEmpty) {
        return null;
      }

      // 해당 날짜의 데이터 찾기
      for (var candle in response.candlesData.reversed) {
        final candleDate = candle.date;

        // 날짜 비교 (시간 제외)
        if (candleDate.year == date.year &&
            candleDate.month == date.month &&
            candleDate.day == date.day) {
          return candle.close;
        }

        // 요청한 날짜보다 이전 데이터면 중단
        if (candleDate.isBefore(date)) {
          break;
        }
      }

      // 정확한 날짜가 없으면 가장 가까운 이전 날짜의 종가 반환
      for (var candle in response.candlesData.reversed) {
        if (candle.date.isBefore(date) ||
            (candle.date.year == date.year &&
             candle.date.month == date.month &&
             candle.date.day == date.day)) {
          return candle.close;
        }
      }

      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error getting historical price for $ticker on $date: $e');
      return null;
    }
  }
}
