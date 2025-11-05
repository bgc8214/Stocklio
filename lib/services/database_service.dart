import 'dart:math';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/stock_info.dart';
import '../models/portfolio.dart';
import '../models/category.dart';
import '../models/supported_ticker.dart';
import '../models/investment_journal.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'my_portfolio.db');
    return await openDatabase(
      path,
      version: 6, // 투자 일지 기능 추가로 버전 6으로 업그레이드
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // current_price 컬럼 추가
      await db.execute('ALTER TABLE portfolios ADD COLUMN current_price REAL');
    }

    if (oldVersion < 3) {
      // 카테고리 테이블 생성
      await db.execute('''
        CREATE TABLE IF NOT EXISTS categories (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          display_name TEXT NOT NULL,
          icon TEXT NOT NULL,
          color TEXT NOT NULL,
          description TEXT NOT NULL
        )
      ''');

      // 지원 종목 테이블 생성
      await db.execute('''
        CREATE TABLE IF NOT EXISTS supported_tickers (
          id INTEGER PRIMARY KEY,
          ticker TEXT NOT NULL UNIQUE,
          name TEXT NOT NULL,
          category_id INTEGER NOT NULL,
          type TEXT NOT NULL,
          is_korean_listed INTEGER DEFAULT 0,
          description TEXT,
          FOREIGN KEY (category_id) REFERENCES categories(id)
        )
      ''');

      // portfolios 테이블에 category_id 컬럼 추가
      await db.execute('ALTER TABLE portfolios ADD COLUMN category_id INTEGER');

      // 기본 카테고리 데이터 삽입
      await _insertDefaultCategories(db);

      // 지원 종목 데이터 삽입
      await _insertSupportedTickers(db);
    }

    if (oldVersion < 4) {
      // 카테고리 테이블에 목표 설정 컬럼 추가 (포메뽀꼬 전략)
      await db.execute('ALTER TABLE categories ADD COLUMN target_amount REAL');
      await db.execute('ALTER TABLE categories ADD COLUMN target_weight REAL');
    }

    if (oldVersion < 5) {
      // 배당 테이블 생성
      await db.execute('''
        CREATE TABLE IF NOT EXISTS dividends (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          ticker TEXT NOT NULL,
          payment_date TEXT NOT NULL,
          amount_per_share REAL NOT NULL,
          quantity REAL NOT NULL,
          total_amount REAL NOT NULL,
          record_date TEXT,
          ex_dividend_date TEXT,
          notes TEXT,
          created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      ''');

      // 배당 조회 성능을 위한 인덱스
      await db.execute('CREATE INDEX idx_dividend_ticker ON dividends(ticker)');
      await db.execute('CREATE INDEX idx_dividend_payment_date ON dividends(payment_date)');
    }

    if (oldVersion < 6) {
      // 투자 일지 테이블 생성
      await db.execute('''
        CREATE TABLE IF NOT EXISTS investment_journals (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT NOT NULL,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          mood TEXT,
          tags TEXT,
          created_at TEXT NOT NULL
        )
      ''');

      // 날짜 기반 조회 성능을 위한 인덱스
      await db.execute('CREATE INDEX idx_journal_date ON investment_journals(date)');
    }
  }

  Future<void> _insertDefaultCategories(Database db) async {
    final categories = Category.all;
    for (var category in categories) {
      await db.insert('categories', category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> _insertSupportedTickers(Database db) async {
    final tickers = SupportedTickers.getAllTickers();
    for (var ticker in tickers) {
      await db.insert('supported_tickers', ticker.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // 종목 마스터 테이블
    await db.execute('''
      CREATE TABLE stock_master (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ticker TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        market TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 검색 성능을 위한 인덱스
    await db.execute('CREATE INDEX idx_stock_name ON stock_master(name)');
    await db.execute('CREATE INDEX idx_stock_ticker ON stock_master(ticker)');

    // 카테고리 테이블 (v3)
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        display_name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    // 지원 종목 테이블 (v3)
    await db.execute('''
      CREATE TABLE supported_tickers (
        id INTEGER PRIMARY KEY,
        ticker TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        is_korean_listed INTEGER DEFAULT 0,
        description TEXT,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    // 포트폴리오 테이블
    await db.execute('''
      CREATE TABLE portfolios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ticker TEXT NOT NULL,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        average_cost REAL NOT NULL,
        current_price REAL,
        market TEXT NOT NULL,
        category_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    // 일별 스냅샷 테이블
    await db.execute('''
      CREATE TABLE daily_snapshots (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        snapshot_date TEXT NOT NULL UNIQUE,
        total_value REAL NOT NULL,
        total_investment REAL NOT NULL,
        total_profit REAL NOT NULL,
        daily_profit REAL,
        created_at TEXT NOT NULL
      )
    ''');

    // 수익 시계열 테이블
    await db.execute('''
      CREATE TABLE profit_series (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        daily_profit REAL,
        monthly_cumulative REAL,
        annual_cumulative REAL,
        created_at TEXT NOT NULL
      )
    ''');

    // 배당 테이블 (v5)
    await db.execute('''
      CREATE TABLE dividends (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ticker TEXT NOT NULL,
        payment_date TEXT NOT NULL,
        amount_per_share REAL NOT NULL,
        quantity REAL NOT NULL,
        total_amount REAL NOT NULL,
        record_date TEXT,
        ex_dividend_date TEXT,
        notes TEXT,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // 배당 조회 성능을 위한 인덱스
    await db.execute('CREATE INDEX idx_dividend_ticker ON dividends(ticker)');
    await db.execute('CREATE INDEX idx_dividend_payment_date ON dividends(payment_date)');

    // 투자 일지 테이블 (v6)
    await db.execute('''
      CREATE TABLE investment_journals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        mood TEXT,
        tags TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // 날짜 기반 조회 성능을 위한 인덱스
    await db.execute('CREATE INDEX idx_journal_date ON investment_journals(date)');

    // 초기 데이터 삽입 (v3)
    await _insertDefaultCategories(db);
    await _insertSupportedTickers(db);
  }

  // ==================== 종목 마스터 ====================

  Future<void> insertStockMaster(List<StockInfo> stocks) async {
    final db = await database;
    final batch = db.batch();

    for (var stock in stocks) {
      batch.insert(
        'stock_master',
        {
          'ticker': stock.ticker,
          'name': stock.name,
          'market': stock.market,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

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

  Future<List<StockInfo>> searchStocks(String query) async {
    final db = await database;
    final results = await db.query(
      'stock_master',
      where: 'name LIKE ? OR ticker LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
      limit: 50,
    );
    return results.map((map) => StockInfo.fromMap(map)).toList();
  }

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

  // ==================== 포트폴리오 ====================

  Future<int> insertPortfolio(Portfolio portfolio) async {
    final db = await database;
    return await db.insert('portfolios', portfolio.toMap());
  }

  Future<List<Portfolio>> getPortfolios() async {
    final db = await database;
    final results = await db.query(
      'portfolios',
      orderBy: 'created_at DESC',
    );
    return results.map((map) => Portfolio.fromMap(map)).toList();
  }

  Future<List<Portfolio>> getPortfolio() async {
    return getPortfolios();
  }

  Future<Portfolio?> getPortfolioById(int id) async {
    final db = await database;
    final results = await db.query(
      'portfolios',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Portfolio.fromMap(results.first);
  }

  Future<int> updatePortfolio(Portfolio portfolio) async {
    final db = await database;
    return await db.update(
      'portfolios',
      portfolio.toMap(),
      where: 'id = ?',
      whereArgs: [portfolio.id],
    );
  }

  Future<int> updatePortfolioQuantityAndPrice(int id, int quantity, double averagePrice) async {
    final db = await database;
    return await db.update(
      'portfolios',
      {
        'quantity': quantity,
        'average_cost': averagePrice,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updatePortfolioCurrentPrice(int id, double currentPrice) async {
    final db = await database;
    await db.update(
      'portfolios',
      {
        'current_price': currentPrice,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePortfolio(int id) async {
    final db = await database;
    return await db.delete(
      'portfolios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 일별 스냅샷 ====================

  Future<int> insertDailySnapshot({
    required DateTime date,
    required double totalValue,
    required double totalCost,
    required double dailyProfit,
  }) async {
    final db = await database;
    final totalProfit = totalValue - totalCost;

    return await db.insert(
      'daily_snapshots',
      {
        'snapshot_date': date.toIso8601String().split('T')[0],
        'total_value': totalValue,
        'total_investment': totalCost,
        'total_profit': totalProfit,
        'daily_profit': dailyProfit,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getSnapshotByDate(String date) async {
    final db = await database;
    final results = await db.query(
      'daily_snapshots',
      where: 'snapshot_date = ?',
      whereArgs: [date],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return results.first;
  }

  Future<List<Map<String, dynamic>>> getRecentSnapshots({int limit = 30}) async {
    final db = await database;
    return await db.query(
      'daily_snapshots',
      orderBy: 'snapshot_date DESC',
      limit: limit,
    );
  }

  Future<List<Map<String, dynamic>>> getDailySnapshots({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await database;
    final start = startDate.toIso8601String().split('T')[0];
    final end = endDate.toIso8601String().split('T')[0];

    final results = await db.query(
      'daily_snapshots',
      where: 'snapshot_date BETWEEN ? AND ?',
      whereArgs: [start, end],
      orderBy: 'snapshot_date ASC',
    );

    return results.map((row) {
      return {
        'date': DateTime.parse(row['snapshot_date'] as String),
        'totalValue': row['total_value'] as double,
        'totalCost': row['total_investment'] as double,
        'totalProfit': row['total_profit'] as double,
        'dailyProfit': row['daily_profit'] as double? ?? 0.0,
      };
    }).toList();
  }

  Future<double?> getTotalValueByDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];

    final results = await db.query(
      'daily_snapshots',
      columns: ['total_value'],
      where: 'snapshot_date = ?',
      whereArgs: [dateStr],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return results.first['total_value'] as double?;
  }

  /// 가장 최근 스냅샷 조회
  Future<Map<String, dynamic>?> getLastSnapshot() async {
    final db = await database;

    final results = await db.query(
      'daily_snapshots',
      orderBy: 'snapshot_date DESC',
      limit: 1,
    );

    if (results.isEmpty) return null;

    final row = results.first;
    return {
      'date': DateTime.parse(row['snapshot_date'] as String),
      'totalValue': row['total_value'] as double,
      'totalCost': row['total_cost'] as double,
      'dailyProfit': row['daily_profit'] as double,
    };
  }

  // ==================== 수익 시계열 ====================

  Future<int> insertProfitSeries(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      'profit_series',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getProfitSeries({int? year}) async {
    final db = await database;

    if (year != null) {
      // 특정 연도 데이터
      final startDate = '$year-01-01';
      final endDate = '$year-12-31';
      return await db.query(
        'profit_series',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [startDate, endDate],
        orderBy: 'date ASC',
      );
    } else {
      // 전체 데이터
      return await db.query(
        'profit_series',
        orderBy: 'date ASC',
      );
    }
  }

  // ==================== 유틸리티 ====================

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('portfolios');
    await db.delete('daily_snapshots');
    await db.delete('profit_series');
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // ==================== 카테고리 ====================

  /// 모든 카테고리 조회
  Future<List<Category>> getCategories() async {
    final db = await database;
    final results = await db.query('categories', orderBy: 'id ASC');
    return results.map((map) => Category.fromMap(map)).toList();
  }

  /// 카테고리 ID로 조회
  Future<Category?> getCategoryById(int id) async {
    final db = await database;
    final results = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Category.fromMap(results.first);
  }

  // ==================== 지원 종목 ====================

  /// 카테고리별 지원 종목 조회
  Future<List<SupportedTicker>> getSupportedTickersByCategory(
      int categoryId) async {
    final db = await database;
    final results = await db.query(
      'supported_tickers',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'type ASC, name ASC',
    );
    return results.map((map) => SupportedTicker.fromMap(map)).toList();
  }

  /// 티커로 지원 종목 조회
  Future<SupportedTicker?> getSupportedTickerByTicker(String ticker) async {
    final db = await database;
    final results = await db.query(
      'supported_tickers',
      where: 'ticker = ?',
      whereArgs: [ticker],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return SupportedTicker.fromMap(results.first);
  }

  /// 지원 종목 검색 (이름 또는 티커)
  Future<List<SupportedTicker>> searchSupportedTickers(String query) async {
    final db = await database;
    final results = await db.query(
      'supported_tickers',
      where: 'name LIKE ? OR ticker LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'category_id ASC, name ASC',
      limit: 50,
    );
    return results.map((map) => SupportedTicker.fromMap(map)).toList();
  }

  /// 카테고리별 포트폴리오 조회
  Future<List<Portfolio>> getPortfoliosByCategory(int categoryId) async {
    final db = await database;
    final results = await db.query(
      'portfolios',
      where: 'category_id = ?',
      whereArgs: [categoryId],
      orderBy: 'created_at DESC',
    );
    return results.map((map) => Portfolio.fromMap(map)).toList();
  }

  /// 카테고리별 총 평가금액 계산
  Future<Map<int, double>> getCategoryTotalValues() async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT category_id, SUM(current_price * quantity) as total
      FROM portfolios
      WHERE category_id IS NOT NULL
      GROUP BY category_id
    ''');

    final Map<int, double> categoryTotals = {};
    for (var row in results) {
      final categoryId = row['category_id'] as int;
      final total = (row['total'] as num?)?.toDouble() ?? 0.0;
      categoryTotals[categoryId] = total;
    }

    return categoryTotals;
  }

  /// 카테고리별 비중 계산
  Future<Map<int, double>> getCategoryPercentages() async {
    final categoryTotals = await getCategoryTotalValues();
    final grandTotal = categoryTotals.values.fold(0.0, (sum, value) => sum + value);

    if (grandTotal == 0) return {};

    final Map<int, double> percentages = {};
    categoryTotals.forEach((categoryId, total) {
      percentages[categoryId] = (total / grandTotal) * 100;
    });

    return percentages;
  }

  // ==================== 테스트용 더미 데이터 ====================

  /// 테스트용 더미 일일 스냅샷 생성 (최근 90일)
  /// 실제 주식처럼 오르락내리락하는 패턴으로 생성
  Future<void> generateDummySnapshots() async {
    print('🔧 더미 데이터 생성 시작...');

    final db = await database;

    // 기존 스냅샷 삭제
    print('🗑️ 기존 스냅샷 삭제 중...');
    await db.delete('daily_snapshots');

    final now = DateTime.now();
    final random = DateTime.now().millisecondsSinceEpoch; // 시드값

    // 초기 투자금액 설정
    double totalCost = 10000000; // 1000만원
    double baseValue = totalCost;

    print('📊 90일치 데이터 생성 중...');

    // 90일치 데이터 생성
    int insertedCount = 0;
    for (int i = 90; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = date.toIso8601String().split('T')[0];

      // 실제 주식처럼 오르락내리락하는 패턴 생성
      // 1. 사인파 트렌드 (장기 흐름)
      final trendAngle = (90 - i) * 0.07; // 각도
      final trendComponent = sin(trendAngle) * 0.015; // ±1.5% 트렌드

      // 2. 랜덤 노이즈 (일일 변동)
      final seed = (random + i * 7) % 1000;
      final randomNoise = ((seed / 1000) - 0.5) * 0.04; // ±2% 랜덤

      // 3. 변동성 추가 (가끔 큰 움직임)
      final volatilitySeed = (random + i * 13) % 100;
      final volatilityBoost = volatilitySeed < 10
          ? ((volatilitySeed % 2 == 0 ? 1 : -1) * 0.03) // ±3% 급등/급락
          : 0.0;

      // 총 변동률 계산
      final changePercent = trendComponent + randomNoise + volatilityBoost;

      // 전날 대비 변동 (일일 수익)
      final dailyChange = baseValue * changePercent;
      baseValue += dailyChange;

      // 누적 수익
      final totalProfit = baseValue - totalCost;

      try {
        await db.insert('daily_snapshots', {
          'snapshot_date': dateStr,
          'total_value': baseValue,
          'total_investment': totalCost,
          'total_profit': totalProfit,
          'daily_profit': dailyChange,
          'created_at': DateTime.now().toIso8601String(),
        });
        insertedCount++;
      } catch (e) {
        print('❌ 데이터 삽입 실패 ($dateStr): $e');
      }
    }

    print('✅ 더미 데이터 생성 완료: $insertedCount개 삽입됨');
  }

  // ==================== 투자 수익 차트 데이터 ====================

  /// 특정 월의 투자 수익 데이터 조회 (월 누적, 연 누적 계산 포함)
  Future<List<Map<String, dynamic>>> getInvestmentDataForMonth(int year, int month) async {
    final db = await database;

    // 해당 월의 모든 스냅샷 조회
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0); // 월의 마지막 날

    final snapshots = await db.query(
      'daily_snapshots',
      where: 'snapshot_date BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
      orderBy: 'snapshot_date ASC',
    );

    // 연초부터의 누적 수익 계산을 위한 데이터
    final yearStartDate = DateTime(year, 1, 1);
    final yearSnapshots = await db.query(
      'daily_snapshots',
      where: 'snapshot_date BETWEEN ? AND ?',
      whereArgs: [
        yearStartDate.toIso8601String().split('T')[0],
        endDate.toIso8601String().split('T')[0],
      ],
      orderBy: 'snapshot_date ASC',
    );

    // 월 누적, 연 누적 계산
    double monthlyAccumulated = 0.0;
    double yearlyAccumulated = 0.0;

    final result = <Map<String, dynamic>>[];

    for (final snapshot in snapshots) {
      final date = DateTime.parse(snapshot['snapshot_date'] as String);
      final dailyProfit = (snapshot['daily_profit'] as num?)?.toDouble() ?? 0.0;

      // 월 누적 수익 (해당 월 1일부터 누적)
      monthlyAccumulated += dailyProfit;

      // 연 누적 수익 (1월 1일부터 현재 날짜까지의 누적)
      yearlyAccumulated = yearSnapshots
          .where((s) {
            final d = DateTime.parse(s['snapshot_date'] as String);
            return d.isBefore(date) || d.isAtSameMomentAs(date);
          })
          .fold(0.0, (sum, s) => sum + ((s['daily_profit'] as num?)?.toDouble() ?? 0.0));

      result.add({
        'date': date.toIso8601String().split('T')[0],
        'dailyProfit': dailyProfit,
        'monthlyAccumulated': monthlyAccumulated,
        'yearlyAccumulated': yearlyAccumulated,
      });
    }

    return result;
  }

  /// 특정 월의 총 수익 계산
  Future<double> getMonthlyTotalProfit(int year, int month) async {
    final db = await database;

    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0);

    final result = await db.rawQuery('''
      SELECT SUM(daily_profit) as total
      FROM daily_snapshots
      WHERE snapshot_date BETWEEN ? AND ?
    ''', [
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0],
    ]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // ==================== 목표 설정 (포메뽀꼬 전략) ====================

  /// 카테고리 목표 업데이트
  Future<void> updateCategoryGoals({
    required int categoryId,
    double? targetAmount,
    double? targetWeight,
  }) async {
    final db = await database;
    await db.update(
      'categories',
      {
        'target_amount': targetAmount,
        'target_weight': targetWeight,
      },
      where: 'id = ?',
      whereArgs: [categoryId],
    );
  }

  /// 카테고리별 현재 총 금액 조회
  Future<double> getCategoryTotalValue(int categoryId) async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT SUM(p.quantity * COALESCE(p.current_price, p.average_cost)) as total
      FROM portfolios p
      WHERE p.category_id = ?
    ''', [categoryId]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// 전체 포트폴리오 총액 조회
  Future<double> getTotalPortfolioValue() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT SUM(quantity * COALESCE(current_price, average_cost)) as total
      FROM portfolios
      WHERE category_id IS NOT NULL
    ''');

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// 카테고리별 현재 비중 계산
  Future<Map<int, double>> getCategoryWeights() async {
    final totalValue = await getTotalPortfolioValue();

    if (totalValue == 0) return {};

    final categories = await getCategories();
    final Map<int, double> weights = {};

    for (var category in categories) {
      final categoryValue = await getCategoryTotalValue(category.id);
      weights[category.id] = (categoryValue / totalValue) * 100;
    }

    return weights;
  }

  // ==================== 리밸런싱 분석 ====================

  /// 리밸런싱 필요 여부 분석
  Future<Map<String, dynamic>> analyzeRebalancing() async {
    final categories = await getCategories();
    final totalValue = await getTotalPortfolioValue();

    if (totalValue == 0) {
      return {
        'needsRebalancing': false,
        'suggestions': <Map<String, dynamic>>[],
        'totalValue': 0.0,
      };
    }

    final List<Map<String, dynamic>> suggestions = [];
    bool needsRebalancing = false;

    for (var category in categories) {
      // 목표가 설정되지 않은 카테고리는 스킵
      if (category.targetWeight == null || category.targetWeight == 0) {
        continue;
      }

      final currentValue = await getCategoryTotalValue(category.id);
      final currentWeight = (currentValue / totalValue) * 100;
      final targetWeight = category.targetWeight!;
      final deviation = currentWeight - targetWeight;

      // ±5% 기준으로 리밸런싱 필요 판단
      final needsAdjustment = deviation.abs() > 5.0;

      if (needsAdjustment) {
        needsRebalancing = true;
      }

      suggestions.add({
        'categoryId': category.id,
        'categoryName': category.displayName,
        'categoryIcon': category.icon,
        'categoryColor': category.color,
        'currentWeight': currentWeight,
        'targetWeight': targetWeight,
        'deviation': deviation,
        'currentValue': currentValue,
        'targetValue': (totalValue * targetWeight) / 100,
        'needsRebalancing': needsAdjustment,
      });
    }

    return {
      'needsRebalancing': needsRebalancing,
      'suggestions': suggestions,
      'totalValue': totalValue,
      'analyzedAt': DateTime.now().toIso8601String(),
    };
  }

  // ==================== 배당 관리 ====================

  /// 배당 기록 추가
  Future<int> addDividend(Map<String, dynamic> dividend) async {
    final db = await database;
    return await db.insert('dividends', dividend);
  }

  /// 모든 배당 기록 조회
  Future<List<Map<String, dynamic>>> getAllDividends() async {
    final db = await database;
    return await db.query(
      'dividends',
      orderBy: 'payment_date DESC',
    );
  }

  /// 특정 티커의 배당 기록 조회
  Future<List<Map<String, dynamic>>> getDividendsByTicker(String ticker) async {
    final db = await database;
    return await db.query(
      'dividends',
      where: 'ticker = ?',
      whereArgs: [ticker],
      orderBy: 'payment_date DESC',
    );
  }

  /// 특정 연도의 배당 기록 조회
  Future<List<Map<String, dynamic>>> getDividendsByYear(int year) async {
    final db = await database;
    final startDate = DateTime(year, 1, 1).toIso8601String();
    final endDate = DateTime(year, 12, 31).toIso8601String();

    return await db.query(
      'dividends',
      where: 'payment_date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'payment_date DESC',
    );
  }

  /// 특정 월의 배당 기록 조회
  Future<List<Map<String, dynamic>>> getDividendsByMonth(int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1).toIso8601String();
    final endDate = DateTime(year, month + 1, 0).toIso8601String();

    return await db.query(
      'dividends',
      where: 'payment_date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'payment_date DESC',
    );
  }

  /// 특정 월의 배당 총액 계산
  Future<double> getMonthlyDividendTotal(int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1).toIso8601String();
    final endDate = DateTime(year, month + 1, 0).toIso8601String();

    final result = await db.rawQuery('''
      SELECT SUM(total_amount) as total
      FROM dividends
      WHERE payment_date BETWEEN ? AND ?
    ''', [startDate, endDate]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// 연간 배당 총액 계산
  Future<double> getAnnualDividendTotal(int year) async {
    final db = await database;
    final startDate = DateTime(year, 1, 1).toIso8601String();
    final endDate = DateTime(year, 12, 31).toIso8601String();

    final result = await db.rawQuery('''
      SELECT SUM(total_amount) as total
      FROM dividends
      WHERE payment_date BETWEEN ? AND ?
    ''', [startDate, endDate]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// 배당 기록 삭제
  Future<int> deleteDividend(int id) async {
    final db = await database;
    return await db.delete(
      'dividends',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 배당 기록 수정
  Future<int> updateDividend(int id, Map<String, dynamic> dividend) async {
    final db = await database;
    return await db.update(
      'dividends',
      dividend,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 투자 일지 ====================

  /// 투자 일지 추가
  Future<int> addJournal(InvestmentJournal journal) async {
    final db = await database;
    return await db.insert('investment_journals', journal.toMap());
  }

  /// 모든 투자 일지 조회 (최신순)
  Future<List<InvestmentJournal>> getAllJournals() async {
    final db = await database;
    final results = await db.query(
      'investment_journals',
      orderBy: 'date DESC, created_at DESC',
    );
    return results.map((map) => InvestmentJournal.fromMap(map)).toList();
  }

  /// 특정 ID의 투자 일지 조회
  Future<InvestmentJournal?> getJournalById(int id) async {
    final db = await database;
    final results = await db.query(
      'investment_journals',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return InvestmentJournal.fromMap(results.first);
  }

  /// 특정 날짜의 투자 일지 조회
  Future<List<InvestmentJournal>> getJournalsByDate(DateTime date) async {
    final db = await database;
    final dateStr = date.toIso8601String().split('T')[0];
    final results = await db.query(
      'investment_journals',
      where: 'date = ?',
      whereArgs: [dateStr],
      orderBy: 'created_at DESC',
    );
    return results.map((map) => InvestmentJournal.fromMap(map)).toList();
  }

  /// 특정 월의 투자 일지 조회
  Future<List<InvestmentJournal>> getJournalsByMonth(int year, int month) async {
    final db = await database;
    final startDate = DateTime(year, month, 1).toIso8601String().split('T')[0];
    final endDate = DateTime(year, month + 1, 0).toIso8601String().split('T')[0];

    final results = await db.query(
      'investment_journals',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC, created_at DESC',
    );
    return results.map((map) => InvestmentJournal.fromMap(map)).toList();
  }

  /// 투자 일지 수정
  Future<int> updateJournal(InvestmentJournal journal) async {
    final db = await database;
    return await db.update(
      'investment_journals',
      journal.toMap(),
      where: 'id = ?',
      whereArgs: [journal.id],
    );
  }

  /// 투자 일지 삭제
  Future<int> deleteJournal(int id) async {
    final db = await database;
    return await db.delete(
      'investment_journals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 투자 일지 검색 (제목 또는 내용)
  Future<List<InvestmentJournal>> searchJournals(String query) async {
    final db = await database;
    final results = await db.query(
      'investment_journals',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'date DESC, created_at DESC',
    );
    return results.map((map) => InvestmentJournal.fromMap(map)).toList();
  }

  /// 감정별 투자 일지 조회
  Future<List<InvestmentJournal>> getJournalsByMood(String mood) async {
    final db = await database;
    final results = await db.query(
      'investment_journals',
      where: 'mood = ?',
      whereArgs: [mood],
      orderBy: 'date DESC, created_at DESC',
    );
    return results.map((map) => InvestmentJournal.fromMap(map)).toList();
  }
}
