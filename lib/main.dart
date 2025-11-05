import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/database_service.dart';
import 'services/background_service.dart';
import 'models/stock_info.dart';
import 'providers/portfolio_provider.dart';
import 'providers/category_provider.dart';
import 'screens/dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 종목 마스터 데이터 초기화
  await initializeStockMaster();

  // 백그라운드 서비스 초기화
  await initializeBackgroundService();

  runApp(const MyApp());
}

/// 백그라운드 서비스 초기화
Future<void> initializeBackgroundService() async {
  try {
    debugPrint('🚀 백그라운드 서비스 시작...');

    // WorkManager 초기화
    await BackgroundService.initialize();

    // 일일 자동 업데이트 작업 등록
    await BackgroundService.registerDailyUpdate();

    debugPrint('✅ 백그라운드 서비스 초기화 완료');
  } catch (e) {
    debugPrint('❌ 백그라운드 서비스 초기화 실패: $e');
  }
}

/// 종목 마스터 데이터 초기화
Future<void> initializeStockMaster() async {
  final db = DatabaseService();
  final prefs = await SharedPreferences.getInstance();

  // 마지막 업데이트 확인
  final lastUpdate = prefs.getString('stock_master_last_update');
  final now = DateTime.now();

  bool shouldUpdate = false;
  if (lastUpdate == null) {
    shouldUpdate = true;
  } else {
    final lastUpdateDate = DateTime.parse(lastUpdate);
    final diff = now.difference(lastUpdateDate);
    // 30일마다 업데이트
    shouldUpdate = diff.inDays > 30;
  }

  if (shouldUpdate) {
    debugPrint('📦 종목 마스터 데이터 업데이트 중...');

    try {
      // assets/krx_stocks.json 파일 로드
      final jsonString = await rootBundle.loadString('assets/krx_stocks.json');
      final jsonList = json.decode(jsonString) as List;
      final stocks = jsonList.map((e) => StockInfo.fromJson(e)).toList();

      // 데이터베이스에 저장
      await db.insertStockMaster(stocks);
      await prefs.setString('stock_master_last_update', now.toIso8601String());

      debugPrint('✅ 종목 마스터 데이터 업데이트 완료! (총 ${stocks.length}개 종목)');
    } catch (e) {
      debugPrint('❌ 종목 마스터 데이터 로드 실패: $e');
    }
  } else {
    debugPrint('✅ 종목 마스터 데이터가 최신 상태입니다.');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: MaterialApp(
        title: 'MyFolio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // darkTheme: AppTheme.darkTheme, // Phase 2
        home: const DashboardScreen(),
      ),
    );
  }
}

