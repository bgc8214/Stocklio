import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/portfolio_provider.dart';
import '../../providers/category_provider.dart';
import '../../screens/category_portfolio_screen.dart';
import '../../screens/portfolio_list_screen.dart';
import '../../screens/rebalancing_screen.dart';
import '../../screens/dividend_calendar_screen.dart';
import '../../screens/fire_simulator_screen.dart';
import '../../screens/monthly_report_screen.dart';
import '../../screens/journal_list_screen.dart';
import '../../screens/help_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer 헤더
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryBlue,
                  AppColors.primaryBlue.withValues(alpha: 0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'MyFolio',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '포트폴리오 관리',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),

          // 포트폴리오 섹션
          _buildSectionHeader(context, '포트폴리오'),
          _buildMenuItem(
            context,
            icon: Icons.category,
            title: '카테고리별 보기',
            subtitle: '나스닥, S&P500, 배당',
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryPortfolioScreen(),
                ),
              );
              if (context.mounted) {
                await context.read<PortfolioProvider>().loadPortfolio();
                await context.read<CategoryProvider>().loadCategories();
              }
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.list_alt,
            title: '전체 보기',
            subtitle: '모든 보유 종목',
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PortfolioListScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // 분석 및 전략 섹션
          _buildSectionHeader(context, '분석 & 전략'),
          _buildMenuItem(
            context,
            icon: Icons.assessment,
            title: '월별 성과 리포트',
            subtitle: '투자 성과 분석',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MonthlyReportScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.balance,
            title: '리밸런싱',
            subtitle: '목표 비중 조정',
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RebalancingScreen(),
                ),
              );
              if (context.mounted) {
                await context.read<PortfolioProvider>().loadPortfolio();
                await context.read<CategoryProvider>().loadCategories();
              }
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.monetization_on,
            title: '배당 캘린더',
            subtitle: '배당 일정 및 내역',
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DividendCalendarScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.local_fire_department,
            title: 'Fire 전략',
            subtitle: '경제적 자유 시뮬레이터',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FireSimulatorScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // 학습 및 기록 섹션
          _buildSectionHeader(context, '학습 & 기록'),
          _buildMenuItem(
            context,
            icon: Icons.book,
            title: '투자 일지',
            subtitle: '투자 생각과 감정 기록',
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const JournalListScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // 설정 섹션
          _buildSectionHeader(context, '기타'),
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: '도움말',
            subtitle: '사용 가이드 & FAQ',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpScreen(),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.settings,
            title: '설정',
            subtitle: '앱 설정',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('설정 기능은 준비 중입니다')),
              );
            },
          ),

          const SizedBox(height: 16),

          // 버전 정보
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'MyFolio v1.0.0\nPhase 1 MVP',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.secondaryText,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primaryBlue,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.secondaryText,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
