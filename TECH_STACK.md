# 기술 스택 문서 (Tech Stack Document)

**프로젝트:** 마이 포트폴리오 (MyFolio)
**작성일:** 2025년 10월 27일
**버전:** 1.0

---

## 1. 기술 스택 개요

### 1.1 선택 기준
- **크로스 플랫폼:** Android와 iOS 동시 지원을 위한 단일 코드베이스
- **개발 속도:** MVP를 빠르게 출시하기 위한 생산성 높은 프레임워크
- **커뮤니티 및 라이브러리:** 풍부한 차트 라이브러리와 금융 앱 레퍼런스
- **비용 효율:** 무료 또는 저렴한 API 및 인프라

---

## 2. 프론트엔드 (모바일 앱)

### 2.1 Flutter
**선택 이유:**
- Android와 iOS를 동시에 개발할 수 있는 크로스 플랫폼 프레임워크
- Google이 직접 관리하며, 활발한 커뮤니티와 풍부한 패키지 생태계
- 네이티브 수준의 성능과 부드러운 애니메이션
- 다양한 차트 라이브러리 지원 (fl_chart, syncfusion_flutter_charts 등)

**주요 패키지:**
- **fl_chart** 또는 **syncfusion_flutter_charts**: 수익 추이 그래프 (선형 + 영역 차트)
- **provider** 또는 **bloc**: 상태 관리
- **dio**: HTTP 클라이언트
- **sqflite**: 로컬 데이터베이스 (오프라인 캐싱)
- **flutter_secure_storage**: 보안 저장소 (토큰 저장)

### 2.2 UI/UX 가이드라인
- Material Design 3 또는 Cupertino 위젯 사용
- 다크 모드 대비 디자인 (MVP 이후 구현)
- 반응형 레이아웃 (다양한 화면 크기 지원)

---

## 3. 백엔드

### 3.1 Node.js + Express 또는 Nest.js
**선택 이유:**
- JavaScript/TypeScript 기반으로 프론트엔드와 언어 통일 가능
- 비동기 처리에 강하며, 주식 데이터 API 호출에 적합
- Nest.js는 TypeScript 기반의 구조화된 프레임워크로 확장성 우수

**주요 기능:**
- REST API 제공 (포트폴리오 CRUD, 대시보드 데이터)
- 인증/인가 (JWT 기반)
- 일일 스케줄 작업 (node-cron 또는 Bull Queue)
- 주식 데이터 API 프록시 (클라이언트에 API 키 노출 방지)

**대안:**
- **Python + FastAPI**: 금융 데이터 처리에 강하며, 많은 주식 라이브러리 존재 (yfinance, pandas)
- **Go**: 고성능이 필요할 경우 고려

### 3.2 스케줄러
**node-cron** 또는 **Bull Queue**
- 매일 장 마감 후 (한국 시간 기준 오후 3:30, 미국 시간 기준 오전 9:30 ET 이후) 실행
- 모든 사용자의 포트폴리오에 대해 일별 스냅샷 계산 및 저장
- 휴장일 감지 및 스킵 로직 필요

---

## 4. 데이터베이스

### 4.1 PostgreSQL
**선택 이유:**
- 관계형 데이터베이스로 데이터 무결성 보장
- 시계열 데이터 처리에 적합 (TimescaleDB 확장 가능)
- JSON 타입 지원으로 유연한 데이터 저장 가능

**스키마 설계:**

#### users 테이블
```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

#### portfolios 테이블
```sql
CREATE TABLE portfolios (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  ticker VARCHAR(20) NOT NULL,
  name VARCHAR(100) NOT NULL,
  quantity DECIMAL(18, 8) NOT NULL,
  average_cost DECIMAL(18, 2) NOT NULL,
  market VARCHAR(10) NOT NULL, -- 'KRX', 'NASDAQ', 'NYSE' 등
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

#### daily_snapshots 테이블
```sql
CREATE TABLE daily_snapshots (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  snapshot_date DATE NOT NULL,
  total_value DECIMAL(18, 2) NOT NULL,
  total_investment DECIMAL(18, 2) NOT NULL,
  total_profit DECIMAL(18, 2) NOT NULL,
  daily_profit DECIMAL(18, 2),
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, snapshot_date)
);
```

#### profit_series 테이블 (그래프용)
```sql
CREATE TABLE profit_series (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  daily_profit DECIMAL(18, 2),
  monthly_cumulative DECIMAL(18, 2),
  annual_cumulative DECIMAL(18, 2),
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, date)
);
```

### 4.2 대안
- **MySQL/MariaDB**: PostgreSQL과 유사하나 TimescaleDB 미지원
- **MongoDB**: NoSQL로 유연하나 시계열 데이터 쿼리가 상대적으로 복잡

---

## 5. 주식 데이터 API

### 5.1 한국 주식 데이터

#### 옵션 1: 한국투자증권 KIS Developers API (추천)
**공식 사이트:** https://apiportal.koreainvestment.com

**장점:**
- 국내 증권사 최초 오픈 API로 신뢰성 높음
- 국내/해외 주식 시세, 과거 데이터, 실시간 호가 제공
- REST API와 WebSocket 지원
- HTS 설치 불필요
- 공식 GitHub 샘플 코드 제공

**단점:**
- 실제 계좌 필요 (최대 2개 계좌 등록 가능)
- API 호출 제한 있음 (분당 요청 수 제한)

**사용 방법:**
1. 한국투자증권 계좌 개설
2. KIS Developers 포털에서 APP Key, APP Secret 발급
3. OAuth 토큰 발급 후 REST API 호출
4. 주요 API: 주식 현재가 시세, 주식 일별 시세, 해외 주식 시세 등

#### 옵션 2: 공공데이터포털 API (무료)
**공식 사이트:** https://www.data.go.kr

**제공 API:**
- 금융위원회_주식시세정보
- 한국예탁결제원_주식정보서비스
- 금융위원회_증권상품시세정보 (ETF, ETN 등)
- 금융위원회_지수시세정보

**장점:**
- 완전 무료
- 계좌 불필요
- 공공 데이터로 신뢰성 있음

**단점:**
- 실시간 데이터가 아닌 일별 종가 데이터
- API 응답 속도가 느릴 수 있음
- XML 형식 응답 (JSON 변환 필요)

**MVP 권장:**
- 공공데이터포털 API로 시작 (무료, 계좌 불필요)
- 실시간 데이터가 필요한 경우 KIS Developers API로 전환

### 5.2 해외 주식 데이터

#### 옵션 1: Alpha Vantage (추천)
**공식 사이트:** https://www.alphavantage.co

**장점:**
- 무료 플랜: 하루 500회 API 호출
- 20만개 이상 글로벌 종목 (20개 이상 거래소)
- 20년 이상의 과거 데이터
- JSON 및 CSV 형식 지원
- 기술적 지표 50개 이상 제공
- Nasdaq, AWS, 런던증권거래소와 공식 파트너십

**단점:**
- 무료 플랜은 호출 제한 있음 (분당 5회)
- 실시간 데이터는 유료 플랜 필요

**주요 API:**
- `TIME_SERIES_DAILY`: 일별 OHLCV 데이터
- `GLOBAL_QUOTE`: 현재가 조회
- `SYMBOL_SEARCH`: 종목 검색

#### 옵션 2: yfinance (Python 라이브러리)
**GitHub:** https://github.com/ranaroussi/yfinance

**장점:**
- 완전 무료
- 사용하기 매우 쉬움
- 방대한 과거 데이터
- Python 기반 백엔드에 바로 통합 가능

**단점:**
- 비공식 라이브러리 (야후 파이낸스의 비공식 래퍼)
- 야후가 구조 변경 시 작동 중단 가능성
- API 호출 제한 없으나 과도한 요청 시 차단 가능

#### 옵션 3: KIS Developers API (해외 주식 지원)
- 한국투자증권 API는 미국 주식도 지원
- 단일 API로 국내/해외 통합 가능

**MVP 권장:**
- Alpha Vantage로 시작 (무료, 안정적)
- 백엔드가 Python이라면 yfinance 고려
- 국내 주식도 KIS API 사용 시 해외도 통합 가능

---

## 6. 인증 및 보안

### 6.1 인증 방식
- **JWT (JSON Web Token)**: 상태 비저장 인증
- **Refresh Token**: 장기 세션 유지
- **OAuth 2.0** (추후): 구글, 카카오 소셜 로그인

### 6.2 보안 고려사항
- 패스워드 해싱: **bcrypt** 또는 **argon2**
- HTTPS 통신 필수
- API 키는 백엔드에서만 관리 (클라이언트에 노출 금지)
- Rate Limiting: API 남용 방지
- Input Validation: SQL Injection, XSS 방어

---

## 7. 인프라 및 배포

### 7.1 호스팅
**백엔드:**
- **AWS EC2** 또는 **Lightsail**: 저렴하고 확장 가능
- **Heroku**: 간편한 배포 (무료 플랜 종료됨, Hobby 플랜 $7/월)
- **Railway**: 간편한 배포, 무료 플랜 제공
- **Vercel** 또는 **Netlify**: Serverless Functions (경량 백엔드)

**데이터베이스:**
- **AWS RDS** (PostgreSQL)
- **Supabase**: PostgreSQL + 인증 + 실시간 기능 통합 (무료 플랜)
- **Neon**: Serverless PostgreSQL (무료 플랜)

**파일 스토리지 (프로필 이미지 등):**
- **AWS S3**
- **Cloudflare R2** (S3 호환, 저렴함)

### 7.2 CI/CD
- **GitHub Actions**: 자동 빌드 및 배포
- **Codemagic** 또는 **Bitrise**: Flutter 앱 자동 빌드

### 7.3 모니터링
- **Sentry**: 에러 추적
- **Google Analytics** 또는 **Mixpanel**: 사용자 분석

---

## 8. 개발 환경

### 8.1 버전 관리
- **Git** + **GitHub** 또는 **GitLab**

### 8.2 코드 품질
- **ESLint** + **Prettier** (백엔드)
- **dart analyze** + **flutter_lints** (Flutter)

### 8.3 테스트
- **Jest** (백엔드 단위 테스트)
- **Flutter Test** (위젯 테스트)
- **Integration Test** (E2E 테스트)

---

## 9. MVP 구현 로드맵

### Phase 1: 기본 인프라 (1-2주)
- Flutter 프로젝트 초기화
- 백엔드 서버 구축 (Express/Nest.js)
- PostgreSQL 데이터베이스 스키마 설계
- JWT 인증 구현

### Phase 2: 포트폴리오 관리 (2-3주)
- 종목 검색 API 연동 (Alpha Vantage 또는 KIS API)
- 종목 추가/수정/삭제 기능
- 포트폴리오 목록 조회

### Phase 3: 대시보드 (2-3주)
- 일일 스냅샷 스케줄러 구현
- 총 평가금액, 수익률 계산 로직
- 대시보드 UI (카드 형태 요약 정보)

### Phase 4: 그래프 및 시각화 (2-3주)
- 수익 추이 그래프 구현 (일일/월간/연간)
- 차트 라이브러리 통합 (fl_chart)
- 데이터 캐싱 및 성능 최적화

### Phase 5: 테스트 및 배포 (1-2주)
- 통합 테스트
- 버그 수정
- Google Play 및 App Store 배포

**예상 총 개발 기간:** 8-13주 (2-3개월)

---

## 10. 비용 예상 (MVP)

| 항목 | 서비스 | 월 비용 (예상) |
|------|--------|---------------|
| 백엔드 호스팅 | Railway / Heroku | $0 - $7 |
| 데이터베이스 | Supabase / Neon 무료 플랜 | $0 |
| 주식 API | Alpha Vantage 무료 + 공공데이터 | $0 |
| 도메인 | Namecheap | $10/년 (~$1/월) |
| **합계** | | **$0 - $8/월** |

**확장 시 추가 비용:**
- Alpha Vantage 유료 플랜: $50/월 (분당 75회, 실시간 데이터)
- AWS RDS: $15-30/월
- 증가된 트래픽 대응: 백엔드 스케일업

---

## 11. 기술적 과제 및 해결 방안

### 11.1 API 호출 제한
**문제:** 무료 API는 호출 제한이 있음
**해결:**
- 백엔드에서 데이터 캐싱 (Redis)
- 장 마감 후 일괄 조회 및 DB 저장
- 실시간 데이터 대신 15분 지연 데이터 사용

### 11.2 휴장일 처리
**문제:** 주말, 공휴일에는 시세 데이터 없음
**해결:**
- 휴장일 캘린더 DB 저장 (한국거래소, NYSE 휴장일)
- 스케줄러에서 휴장일 확인 후 스킵

### 11.3 시차 처리
**문제:** 한국과 미국 시장의 시차
**해결:**
- UTC 기준으로 모든 시간 저장
- 한국: 오후 3:30 종가 → UTC 06:30
- 미국: 오후 4:00 종가 (ET) → UTC 21:00 (서머타임 고려)

### 11.4 데이터 정합성
**문제:** 사용자가 종목 수정 시 과거 데이터 불일치
**해결:**
- 포트폴리오 변경 이력 테이블 생성
- 스냅샷은 과거 시점 기준으로 변경하지 않음
- 변경 시점부터 새로운 계산 적용

---

## 12. 참고 자료

### 공식 문서
- Flutter: https://flutter.dev/docs
- Nest.js: https://nestjs.com
- PostgreSQL: https://www.postgresql.org/docs

### 주식 API
- KIS Developers: https://apiportal.koreainvestment.com
- Alpha Vantage: https://www.alphavantage.co/documentation
- 공공데이터포털: https://www.data.go.kr

### 커뮤니티
- KIS API 튜토리얼: https://wikidocs.net/book/7845
- Flutter 주식 앱 예제: https://github.com/search?q=flutter+stock+app

---

**문서 작성자:** Claude Code
**최종 수정일:** 2025년 10월 27일
