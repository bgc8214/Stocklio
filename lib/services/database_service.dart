import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/stock_info.dart';
import '../models/portfolio.dart';

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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // current_price 컬럼 추가
      await db.execute('ALTER TABLE portfolios ADD COLUMN current_price REAL');
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
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
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
}
