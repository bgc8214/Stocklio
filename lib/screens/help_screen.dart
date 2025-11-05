import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('도움말'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 헤더
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.help_outline,
                  size: 60,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(height: 12),
                Text(
                  'MyFolio 도움말',
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '포트폴리오 관리를 위한 완벽 가이드',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 포메뽀꼬 전략
          _buildSection(
            context,
            icon: Icons.trending_up,
            iconColor: Colors.green,
            title: '포메뽀꼬 전략이란?',
            content: [
              _buildTextParagraph(
                '포트폴리오 + 메이크 + 빨리 + 꼬박꼬박',
              ),
              const SizedBox(height: 12),
              _buildTextParagraph(
                '3가지 자산군(나스닥, S&P500, 배당)에 분산 투자하여 '
                '꾸준히 자산을 쌓는 장기 투자 전략입니다.',
                isBold: true,
              ),
              const SizedBox(height: 16),
              _buildBulletPoint('목표: 월 100만원 배당 소득 창출'),
              _buildBulletPoint('기간: 약 10-15년 장기 투자'),
              _buildBulletPoint('방법: 매월 일정 금액 자동 투자'),
            ],
          ),

          const SizedBox(height: 24),

          // 3-ETF 설명
          _buildSection(
            context,
            icon: Icons.account_balance,
            iconColor: Colors.blue,
            title: '3-ETF 포트폴리오 구성',
            content: [
              _buildETFCard(
                context,
                category: '나스닥 100',
                tickers: 'QQQ, TIGER 나스닥100',
                description: '미국 기술주 중심의 성장 ETF',
                features: [
                  '애플, 마이크로소프트, 아마존 등 빅테크',
                  '높은 성장 가능성',
                  '변동성 크지만 장기 수익률 우수',
                ],
                color: Colors.purple,
              ),
              const SizedBox(height: 12),
              _buildETFCard(
                context,
                category: 'S&P 500',
                tickers: 'VOO, SPY, TIGER 미국S&P500',
                description: '미국 대표 500개 기업 ETF',
                features: [
                  '미국 경제 전체 성장에 투자',
                  '안정적인 장기 수익',
                  '가장 검증된 지수',
                ],
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildETFCard(
                context,
                category: '배당 ETF',
                tickers: 'SCHD, JEPI, VYM',
                description: '안정적인 현금 흐름 창출',
                features: [
                  '분기별 배당금 지급',
                  '배당 성장 우수 기업',
                  'Fire 전략의 핵심 자산',
                ],
                color: Colors.green,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 앱 사용 가이드
          _buildSection(
            context,
            icon: Icons.phone_android,
            iconColor: Colors.orange,
            title: '앱 사용 가이드',
            content: [
              _buildStepCard(
                context,
                step: 1,
                title: '종목 추가',
                description: '대시보드에서 "종목 추가" 버튼을 눌러 보유 주식을 등록하세요.',
                tips: ['티커 검색으로 빠르게 찾기', '수량과 평균 단가 입력'],
              ),
              const SizedBox(height: 12),
              _buildStepCard(
                context,
                step: 2,
                title: '카테고리 관리',
                description: '카테고리별로 종목을 구분하고 목표 금액을 설정하세요.',
                tips: ['나스닥, S&P500, 배당으로 자동 분류', '목표 비중 설정 가능'],
              ),
              const SizedBox(height: 12),
              _buildStepCard(
                context,
                step: 3,
                title: '수익 추적',
                description: '일별/월별 수익 추이를 차트로 확인하세요.',
                tips: ['자동으로 가격 업데이트', '월별 성과 리포트 제공'],
              ),
              const SizedBox(height: 12),
              _buildStepCard(
                context,
                step: 4,
                title: '투자 일지',
                description: '투자 생각과 감정을 기록하여 심리를 관리하세요.',
                tips: ['감정 태그로 패턴 분석', '과거 결정 회고'],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // FAQ
          _buildSection(
            context,
            icon: Icons.quiz,
            iconColor: Colors.red,
            title: 'FAQ',
            content: [
              _buildFAQItem(
                question: 'Q. 자동으로 주식 가격이 업데이트 되나요?',
                answer: 'A. 네, Yahoo Finance API를 통해 자동으로 가격이 업데이트됩니다. '
                    '다만 실시간은 아니며, 장 마감 후 가격이 반영됩니다.',
              ),
              const Divider(height: 24),
              _buildFAQItem(
                question: 'Q. 여러 증권사 계좌를 한번에 관리할 수 있나요?',
                answer: 'A. 네, 어느 증권사든 보유한 모든 주식을 한곳에서 통합 관리할 수 있습니다. '
                    '증권사 구분 없이 전체 포트폴리오를 확인하세요.',
              ),
              const Divider(height: 24),
              _buildFAQItem(
                question: 'Q. 배당금은 어떻게 기록하나요?',
                answer: 'A. 배당 캘린더 메뉴에서 배당금을 수동으로 기록할 수 있습니다. '
                    '지급일, 배당금액 등을 입력하여 관리하세요.',
              ),
              const Divider(height: 24),
              _buildFAQItem(
                question: 'Q. 데이터는 어디에 저장되나요?',
                answer: 'A. 현재는 앱 내부(로컬 데이터베이스)에만 저장됩니다. '
                    '추후 클라우드 백업 기능이 추가될 예정입니다.',
              ),
              const Divider(height: 24),
              _buildFAQItem(
                question: 'Q. 한국 주식도 지원하나요?',
                answer: 'A. 네, 한국 주식(.KS, .KQ)과 미국 주식을 모두 지원합니다.',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 추가 리소스
          _buildSection(
            context,
            icon: Icons.link,
            iconColor: Colors.teal,
            title: '추가 학습 자료',
            content: [
              _buildLinkCard(
                context,
                title: '포메뽀꼬 전략 상세 가이드',
                description: '3-ETF 포트폴리오 구성 방법',
                icon: Icons.book,
              ),
              const SizedBox(height: 8),
              _buildLinkCard(
                context,
                title: 'Fire 전략 소개',
                description: '경제적 자유 달성 로드맵',
                icon: Icons.local_fire_department,
              ),
              const SizedBox(height: 8),
              _buildLinkCard(
                context,
                title: 'ETF 투자 기초',
                description: '초보자를 위한 ETF 가이드',
                icon: Icons.school,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // 푸터
          Center(
            child: Column(
              children: [
                Text(
                  'MyFolio v1.0.0',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '더 나은 투자 습관을 위해',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> content,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...content,
          ],
        ),
      ),
    );
  }

  Widget _buildTextParagraph(String text, {bool isBold = false}) {
    return Text(
      text,
      style: AppTextStyles.bodyMedium.copyWith(
        height: 1.6,
        fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('  • ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildETFCard(
    BuildContext context, {
    required String category,
    required String tickers,
    required String description,
    required List<String> features,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tickers,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...features.map((feature) => _buildBulletPoint(feature)),
        ],
      ),
    );
  }

  Widget _buildStepCard(
    BuildContext context, {
    required int step,
    required String title,
    required String description,
    required List<String> tips,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$step',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                ),
                const SizedBox(height: 8),
                ...tips.map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              tip,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          answer,
          style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
        ),
      ],
    );
  }

  Widget _buildLinkCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(description, style: AppTextStyles.labelSmall),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // 외부 링크 연결 (추후 구현)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('준비 중인 기능입니다')),
          );
        },
      ),
    );
  }
}
