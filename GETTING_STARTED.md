# 시작하기 (Getting Started)

## 프로젝트 개요

**마이 포트폴리오 (MyFolio)**는 여러 증권사에 흩어진 주식 자산을 한곳에서 통합 관리하고, 투자 성과를 시각적으로 추적하는 Flutter 기반 모바일 앱입니다.

## 현재 상태 ✅

**완료된 작업:**
- ✅ Flutter 프로젝트 생성
- ✅ 필수 패키지 설치 (provider, sqflite, dio, fl_chart 등)
- ✅ 폴더 구조 구성
- ✅ KRX 종목 마스터 데이터 (50개 주요 종목)
- ✅ SQLite 데이터베이스 서비스
- ✅ Yahoo Finance API 서비스
- ✅ 앱 초기화 코드 (종목 마스터 로드)
- ✅ 홈 화면 UI

**다음 단계:**
- 종목 검색 화면 구현
- 포트폴리오 추가 기능
- 대시보드 화면
- 수익 추이 그래프

---

## 개발 환경 설정

### 필수 요구사항
- Flutter SDK 3.27.2 이상
- Dart 3.6.1 이상
- Android Studio 또는 Xcode (플랫폼에 따라)

### 프로젝트 구조
```
my-portfolio/
├── lib/
│   ├── main.dart                    # 앱 진입점
│   ├── models/                      # 데이터 모델
│   │   ├── stock_info.dart          # 종목 정보
│   │   └── portfolio.dart           # 포트폴리오
│   ├── services/                    # 비즈니스 로직
│   │   ├── database_service.dart    # SQLite 데이터베이스
│   │   └── yahoo_finance_service.dart # 주식 데이터 API
│   ├── providers/                   # 상태 관리 (TODO)
│   ├── screens/                     # 화면 (TODO)
│   └── widgets/                     # 재사용 위젯 (TODO)
├── assets/
│   └── krx_stocks.json              # KRX 종목 마스터 데이터
└── pubspec.yaml                     # 패키지 설정
```

---

## 실행 방법

### 1. 패키지 설치
```bash
flutter pub get
```

### 2. 코드 분석
```bash
flutter analyze
```

### 3. 앱 실행
```bash
# Android 에뮬레이터 또는 연결된 기기에서 실행
flutter run

# iOS 시뮬레이터에서 실행
flutter run -d ios

# 웹에서 실행
flutter run -d chrome
```

### 4. 빌드
```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web
```

---

## 주요 기능 설명

### 1. 종목 검색 (종목명 → 티커)

**문제:** Yahoo Finance는 종목명으로 직접 검색이 어렵습니다.

**해결:**
- KRX 종목 마스터 데이터를 로컬 SQLite에 저장
- 사용자가 "삼성전자" 입력 → 로컬 DB 검색 → "005930.KS" 티커 찾기
- 티커로 Yahoo Finance API 호출하여 현재가 조회

**예시:**
```dart
// 1. 종목 검색
final db = DatabaseService();
final results = await db.searchStockByName('삼성전자');
// 결과: StockInfo(ticker: '005930.KS', name: '삼성전자', market: 'KOSPI')

// 2. 현재가 조회
final yahoo = YahooFinanceService();
final price = await yahoo.getCurrentPrice('005930.KS');
// 결과: 71500.0 (예시)
```

### 2. Yahoo Finance API (완전 무료!)

**장점:**
- ✅ API 키 불필요
- ✅ 호출 제한 없음
- ✅ 한국 주식 (.KS, .KQ) 지원
- ✅ 미국 주식 (AAPL, TSLA 등) 지원
- ✅ 과거 데이터 제공

**API 사용 예시:**
```dart
final service = YahooFinanceService();

// 현재가 조회
final price = await service.getCurrentPrice('005930.KS'); // 삼성전자

// 여러 종목 일괄 조회
final prices = await service.getBatchPrices([
  '005930.KS',  // 삼성전자
  'AAPL',       // 애플
  '035720.KS',  // 카카오
]);

// 과거 데이터 조회
final history = await service.getHistoricalData(
  ticker: '005930.KS',
  startDate: DateTime(2025, 1, 1),
  endDate: DateTime.now(),
);
```

### 3. SQLite 데이터베이스

**테이블 구조:**
```sql
-- 종목 마스터 (검색용)
stock_master (id, ticker, name, market, created_at)

-- 포트폴리오
portfolios (id, ticker, name, quantity, average_cost, market, created_at, updated_at)

-- 일별 스냅샷
daily_snapshots (id, snapshot_date, total_value, total_investment, total_profit, daily_profit, created_at)

-- 수익 시계열
profit_series (id, date, daily_profit, monthly_cumulative, annual_cumulative, created_at)
```

---

## 개발 팁

### Hot Reload
코드 수정 후 `r` 키를 누르면 앱을 재시작하지 않고 변경사항을 즉시 반영합니다.

### Hot Restart
앱을 완전히 재시작하려면 `R` (대문자) 키를 누릅니다.

### 디버그 콘솔
`flutter run` 실행 시 콘솔에서 다음 명령어 사용 가능:
- `r`: Hot reload
- `R`: Hot restart
- `h`: 도움말
- `q`: 종료

### VS Code 확장
- Flutter
- Dart
- Flutter Widget Snippets

### 디버깅
```dart
// 콘솔에 출력
print('디버그 메시지');

// 디버거 브레이크포인트
debugger(); // dart:developer import 필요
```

---

## 다음 구현 순서

### Phase 1: 종목 검색 및 추가 (1주)
1. 검색 화면 UI
2. 로컬 DB 검색 기능
3. Yahoo Finance API 연동 확인
4. 포트폴리오 추가 화면 (수량, 평단가 입력)
5. SQLite에 저장

### Phase 2: 포트폴리오 목록 (1주)
1. 보유 종목 리스트 화면
2. 현재가, 평가금액, 수익률 계산
3. 수정/삭제 기능

### Phase 3: 대시보드 (1주)
1. 요약 카드 (총 평가금액, 수익률 등)
2. 일일 스냅샷 저장 로직
3. 백그라운드 스케줄러 (WorkManager)

### Phase 4: 그래프 (1-2주)
1. fl_chart 라이브러리 통합
2. 일일/월간/연간 수익 그래프
3. 데이터 계산 로직

---

## 문제 해결

### 패키지 설치 오류
```bash
flutter clean
flutter pub get
```

### 빌드 오류
```bash
flutter clean
flutter pub get
flutter build apk
```

### iOS 빌드 오류
```bash
cd ios
pod install
cd ..
flutter run
```

---

## 참고 문서

- **PRD**: `prd.md` - 제품 요구사항 명세서
- **기술 스택**: `TECH_STACK.md` - 기술 스택 상세 비교
- **아키텍처**: `FINAL_ARCHITECTURE.md` - 최종 확정 아키텍처
- **종목 검색**: `STOCK_SEARCH_SOLUTION.md` - 종목 검색 솔루션
- **Claude 가이드**: `CLAUDE.md` - Claude Code를 위한 프로젝트 가이드

---

## 지원

질문이나 문제가 있으면 다음을 확인하세요:
- Flutter 공식 문서: https://docs.flutter.dev
- Dart 문서: https://dart.dev/guides
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter

---

**마지막 업데이트:** 2025년 10월 27일
**개발 진행률:** 20% (기반 인프라 완료)
