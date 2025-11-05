# CLAUDE.md

이 파일은 Claude Code (claude.ai/code)가 이 레포지토리에서 작업할 때 참고하는 가이드입니다.

## 프로젝트 개요

**마이 포트폴리오 (MyFolio)**는 여러 증권사에 흩어진 주식 자산을 한곳에서 통합 관리하고, 투자 성과를 시각적으로 추적하는 개인 맞춤형 포트폴리오 트래킹 앱입니다.

### 핵심 가치
- 여러 증권사 계좌의 주식을 하나의 대시보드에서 통합 관리
- 일별/월별/연간 수익 추이를 그래프로 시각화
- 과거 연도와 현재 투자 성과 비교 분석

## 프로젝트 상태

현재 이 프로젝트는 **기획 단계**입니다. prd.md 파일에 전체 제품 명세가 작성되어 있습니다. 기능을 구현하기 전에 prd.md의 2.1-2.3 섹션을 참고하세요.

## 아키텍처 설계 (PRD 기반)

### 핵심 기술 요구사항

**주식 데이터 연동**
- 금융 데이터 API 연동 필수 (Alpha Vantage, yfinance, 또는 증권사 API)
- 국내/해외 주식의 실시간 및 과거 시세 데이터 필요

**일일 계산 엔진**
- 매일 장 마감 후 스케줄 작업 실행
- 포트폴리오 평가금액 스냅샷 계산 및 저장
- 일일 수익 계산 = (당일 종가 기준 총 평가금액) - (전일 종가 기준 총 평가금액)
- 월간 누적 수익 계산 (매월 1일 0으로 리셋)
- 연간 누적 수익 계산 (매년 1월 1일 0으로 리셋)

**데이터베이스 스키마 (필수 테이블)**
- Users: 인증 및 사용자 프로필 데이터
- Portfolio: 사용자 보유 종목 (티커, 수량, 평균 단가)
- DailySnapshots: 일별 포트폴리오 평가금액 및 계산된 수익 데이터
- 차트 렌더링을 위한 일별/월별/연간 수익 시계열 데이터 별도 테이블

### 데이터 모델 개념

**포트폴리오 계산식:**
- 총 평가금액 = SUM(현재가 × 보유 수량)
- 총 투자원금 = SUM(평균 단가 × 보유 수량)
- 총 누적수익 = 총 평가금액 - 총 투자원금
- 일일 수익 = 오늘의 총 평가금액 - 어제의 총 평가금액

**그래프 데이터 시리즈 (prd.md:2.2.2 참고):**
1. 일일 수익 꺾은선 그래프: 0을 기준으로 위아래로 표시되는 일별 수익/손실
2. 월간 누적 수익 영역 그래프: 해당 월 1일부터 현재까지 일일 수익 누적 (매월 리셋)
3. 연간 누적 수익 영역 그래프: 해당 연도 1월 1일부터 현재까지 일일 수익 누적 (매년 리셋)

## MVP 범위

prd.md의 4번 섹션에 따라 MVP는 다음을 포함합니다:
1. 수동 종목 관리 (티커/종목명 검색, 수량과 평균 단가 입력)
2. 기본 대시보드 (총 평가금액, 수익률, 당일 변동 등 핵심 지표)
3. 현재 연도 기준 수익 추이 그래프만 제공
4. 이메일 기반 인증

MVP에서 제외되는 기능:
- 과거 연도 비교 기능
- 배당금 추적
- 다크 모드
- 증권사 API 자동 연동

## 개발 가이드라인

### 기능 구현 시 참고사항

**종목 검색 및 입력 (prd.md:2.1.1)**
- 국내 주식 및 해외 주식 모두 검색 지원
- 입력 필드: 티커/종목명 검색, 보유 수량, 평균 단가
- 데이터베이스에 티커, 수량, 평단가 저장

**대시보드 요구사항 (prd.md:2.2)**
- 상단 섹션: 총 평가금액, 투자원금, 총 수익 (금액 + %), 당일 수익 (금액 + %) 카드 표시
- 메인 섹션: 3개 시리즈가 겹쳐진 수익 추이 그래프 (일일 선, 월간 영역, 연간 영역)
- 연도 선택 드롭다운 (MVP 이후) 과거 데이터 비교용

**데이터 일관성**
- 장 마감 후 일일 스냅샷 작업이 안정적으로 실행되어야 함
- 휴장일 처리 (장이 열리지 않은 날 계산 스킵)
- 해외 주식의 시차 고려 필요

### 기술 스택 선택 시 고려사항

PRD에서는 특정 기술을 지정하지 않았습니다. 스택 선택 시 다음을 고려하세요:
- 스케줄 작업 지원 가능한 백엔드 (cron, job queue 등)
- 시계열 데이터를 효율적으로 처리하는 데이터베이스 (PostgreSQL + TimescaleDB 등)
- 여러 시리즈 타입을 지원하는 프론트엔드 차트 라이브러리 (선 + 영역 차트)
- 충분한 API 호출 한도와 과거 데이터 제공하는 주식 데이터 API

## 기술 스택 (최종 확정) ⭐

상세 내용은 **FINAL_ARCHITECTURE.md** 참고

### Phase 1: MVP (1-2개월)

**프론트엔드:**
- Flutter (Android/iOS 크로스 플랫폼)
- fl_chart (그래프)
- provider (상태 관리)
- sqflite (로컬 데이터베이스)

**주식 데이터 API:**
- **Yahoo Finance** (완전 무료, API 키 불필요) ✅
- `yahoo_finance_data_reader` Flutter 패키지
- 한국 주식: `.KS` (KOSPI), `.KQ` (KOSDAQ)
- 미국 주식: 티커 그대로 (예: AAPL, TSLA)

**백그라운드 작업:**
- workmanager (일일 자동 업데이트)

**비용:** $25 (Google Play 등록 1회)

### Phase 2: 정식 출시 (+3-4주)

**추가 스택:**
- Firebase Authentication (이메일/구글 로그인)
- Cloud Firestore (클라우드 데이터베이스)
- Firebase Storage (프로필 이미지 등)

**비용:** $0/월 (Firebase 무료 플랜), $99/년 (iOS App Store)

**총 개발 기간:** 약 3개월
**총 비용:** MVP $25, 정식 출시 $0-10/월

## 개발 워크플로우 (필수 준수) ⚠️

### 기능 개발 시 필수 절차

모든 기능 개발은 다음 순서를 **반드시** 따라야 합니다:

```bash
# 1단계: 기능 구현
# - 코드 작성

# 2단계: 정적 분석 (필수)
flutter analyze

# 3단계: 테스트 코드 작성 (필수)
# - test/ 디렉토리에 단위 테스트 작성
# - 비즈니스 로직, 계산 함수, DB 쿼리 등 테스트

# 4단계: 테스트 실행 (필수)
flutter test

# 5단계: 분석 + 테스트 통합 실행
flutter analyze && flutter test
```

### 규칙

✅ **반드시 해야 하는 것:**
- 기능 구현 후 `flutter analyze` 실행
- 항상 테스트 코드 작성
- 모든 테스트가 통과해야 완료

❌ **하지 않아야 하는 것:**
- `flutter run`으로 UI 테스트 (사용자가 직접 수행)
- 테스트 없이 PR/커밋
- analyze 경고 무시

### 테스트 작성 가이드

**테스트해야 할 대상:**
- ✅ 비즈니스 로직 (계산, 변환, 검증)
- ✅ 데이터베이스 쿼리
- ✅ 모델 직렬화/역직렬화
- ✅ 유틸리티 함수

**테스트 파일 위치:**
```
lib/services/database_service.dart
→ test/services/database_service_test.dart

lib/models/dividend.dart
→ test/models/dividend_test.dart

lib/utils/currency_formatter.dart
→ test/utils/currency_formatter_test.dart
```

### 예시

```dart
// test/services/database_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:stocklio/services/database_service.dart';

void main() {
  group('배당 계산 테스트', () {
    test('연간 배당 총액이 올바르게 계산됨', () async {
      final db = DatabaseService();
      // Given, When, Then
    });
  });
}
```

## 개발 명령어

**Flutter:**
```bash
# 코드 품질 검사 (필수)
flutter analyze

# 단위 테스트 실행 (필수)
flutter test

# 특정 테스트만 실행
flutter test test/services/database_service_test.dart

# 커버리지 리포트
flutter test --coverage

# 빌드 (Android)
flutter build apk --release

# 빌드 (iOS)
flutter build ios --release
```

**UI 테스트:**
```bash
# ❌ Claude는 실행하지 않음 (사용자가 직접 테스트)
# flutter run
```

## 중요 컨텍스트

- PRD와 사용자 커뮤니케이션은 한글로 진행됩니다
- 타겟 사용자는 여러 계좌를 관리하는 개인 투자자입니다
- 복잡한 기능보다 단순하고 깔끔한 UI를 우선시합니다
- 적극적인 트레이딩 기능이 아닌 추적과 시각화에 집중합니다
- API 키는 절대 클라이언트에 노출하지 않고 백엔드 프록시를 통해 호출합니다