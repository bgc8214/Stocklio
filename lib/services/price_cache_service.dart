import 'dart:async';
import 'package:flutter/foundation.dart';
import 'database_service.dart';
import 'yahoo_finance_service.dart';

/// 주식 가격 캐시 서비스
/// 앱 시작 시 모든 보유 종목의 현재가를 미리 불러와서 캐싱
class PriceCacheService {
  static final PriceCacheService _instance = PriceCacheService._internal();
  factory PriceCacheService() => _instance;
  PriceCacheService._internal();

  final DatabaseService _db = DatabaseService();
  final YahooFinanceService _yahooFinance = YahooFinanceService();

  // 가격 캐시 (ticker -> 가격 정보)
  final Map<String, PriceCacheData> _priceCache = {};

  // 마지막 업데이트 시간
  DateTime? _lastUpdateTime;

  // 자동 업데이트 타이머
  Timer? _autoUpdateTimer;

  // 캐시 유효 시간 (5분)
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  /// 초기 로드 (앱 시작 시 호출)
  Future<void> initialize() async {
    debugPrint('💰 가격 캐시 초기화 시작...');
    await _loadAllPrices();
    _startAutoUpdate();
    debugPrint('✅ 가격 캐시 초기화 완료');
  }

  /// 모든 보유 종목의 가격 로드
  Future<void> _loadAllPrices() async {
    try {
      final portfolios = await _db.getPortfolio();

      if (portfolios.isEmpty) {
        debugPrint('⚠️  보유 종목이 없습니다');
        return;
      }

      debugPrint('📊 ${portfolios.length}개 종목 가격 로딩 중...');

      // 병렬로 모든 종목 가격 조회
      final futures = portfolios.map((portfolio) async {
        try {
          final priceData = await _yahooFinance.getCurrentPrice(portfolio.ticker);

          if (priceData != null) {
            final currentPrice = priceData['currentPrice'] as double;
            final priceChange = priceData['priceChange'] as double?;
            final priceChangePercent = priceData['priceChangePercent'] as double?;

            _priceCache[portfolio.ticker] = PriceCacheData(
              ticker: portfolio.ticker,
              currentPrice: currentPrice,
              priceChange: priceChange,
              priceChangePercent: priceChangePercent,
              timestamp: DateTime.now(),
            );
            debugPrint('  ✓ ${portfolio.ticker}: $currentPrice');
          }
        } catch (e) {
          debugPrint('  ✗ ${portfolio.ticker} 가격 조회 실패: $e');
        }
      });

      await Future.wait(futures);
      _lastUpdateTime = DateTime.now();

      debugPrint('✅ 가격 캐시 업데이트 완료: ${_priceCache.length}/${portfolios.length}');
    } catch (e) {
      debugPrint('❌ 가격 로딩 실패: $e');
    }
  }

  /// 자동 업데이트 시작 (5분마다)
  void _startAutoUpdate() {
    _autoUpdateTimer?.cancel();
    _autoUpdateTimer = Timer.periodic(_cacheValidDuration, (_) {
      debugPrint('🔄 자동 가격 업데이트...');
      _loadAllPrices();
    });
  }

  /// 자동 업데이트 중지
  void stopAutoUpdate() {
    _autoUpdateTimer?.cancel();
    _autoUpdateTimer = null;
    debugPrint('⏸️  자동 가격 업데이트 중지');
  }

  /// 특정 종목의 캐시된 가격 조회
  PriceCacheData? getCachedPrice(String ticker) {
    return _priceCache[ticker];
  }

  /// 특정 종목의 현재가 조회 (캐시 우선, 없으면 API 호출)
  Future<Map<String, dynamic>?> getPrice(String ticker) async {
    // 1. 캐시 확인
    final cached = _priceCache[ticker];
    if (cached != null && cached.isValid) {
      return {
        'currentPrice': cached.currentPrice,
        'priceChange': cached.priceChange,
        'priceChangePercent': cached.priceChangePercent,
        'fromCache': true,
      };
    }

    // 2. 캐시 없거나 만료됨 -> API 호출
    try {
      final priceData = await _yahooFinance.getCurrentPrice(ticker);

      if (priceData != null) {
        final currentPrice = priceData['currentPrice'] as double;
        final priceChange = priceData['priceChange'] as double?;
        final priceChangePercent = priceData['priceChangePercent'] as double?;

        // 캐시 업데이트
        _priceCache[ticker] = PriceCacheData(
          ticker: ticker,
          currentPrice: currentPrice,
          priceChange: priceChange,
          priceChangePercent: priceChangePercent,
          timestamp: DateTime.now(),
        );

        return {
          'currentPrice': currentPrice,
          'priceChange': priceChange,
          'priceChangePercent': priceChangePercent,
          'fromCache': false,
        };
      }
    } catch (e) {
      debugPrint('❌ ${ticker} 가격 조회 실패: $e');
    }

    return null;
  }

  /// 수동 새로고침
  Future<void> refresh() async {
    debugPrint('🔄 수동 가격 새로고침...');
    await _loadAllPrices();
  }

  /// 캐시 클리어
  void clearCache() {
    _priceCache.clear();
    _lastUpdateTime = null;
    debugPrint('🗑️  가격 캐시 클리어');
  }

  /// 마지막 업데이트 시간
  DateTime? get lastUpdateTime => _lastUpdateTime;

  /// 캐시된 종목 수
  int get cachedCount => _priceCache.length;

  /// 특정 종목이 캐시되어 있는지
  bool isCached(String ticker) => _priceCache.containsKey(ticker);

  /// Dispose
  void dispose() {
    stopAutoUpdate();
    clearCache();
  }
}

/// 가격 캐시 데이터
class PriceCacheData {
  final String ticker;
  final double currentPrice;
  final double? priceChange;
  final double? priceChangePercent;
  final DateTime timestamp;

  PriceCacheData({
    required this.ticker,
    required this.currentPrice,
    this.priceChange,
    this.priceChangePercent,
    required this.timestamp,
  });

  /// 캐시가 유효한지 (5분 이내)
  bool get isValid {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    return diff < const Duration(minutes: 5);
  }

  /// 캐시 나이 (분)
  int get ageInMinutes {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    return diff.inMinutes;
  }
}
