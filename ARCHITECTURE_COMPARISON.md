# 아키텍처 비교: Flutter 단독 vs Flutter + 백엔드

## 옵션 1: Flutter 단독 (로컬 앱) ⭐ MVP 추천

### 구조
```
Flutter App
├── UI Layer
├── Business Logic (Provider/Bloc)
├── Local Database (SQLite/sqflite)
└── API Layer (직접 호출)
    ├── Alpha Vantage API
    └── 공공데이터포털 API
```

### 장점
✅ **개발 속도 빠름** - 백엔드 개발 불필요, Flutter만 집중
✅ **비용 제로** - 호스팅 비용 없음
✅ **오프라인 작동** - 네트워크 없이도 데이터 조회 가능
✅ **단순한 배포** - 앱 스토어에만 배포하면 됨
✅ **개인정보 보호** - 모든 데이터가 사용자 기기에만 저장

### 단점
❌ **API 키 노출 위험** - 앱 디컴파일 시 API 키 탈취 가능
❌ **기기 종속** - 다른 기기에서 데이터 접근 불가
❌ **데이터 백업 어려움** - 앱 삭제 시 데이터 손실
❌ **API 호출 제한** - 각 사용자가 개별적으로 API 호출 (비효율)
❌ **배터리 소모** - 앱이 직접 백그라운드 작업 수행

### 기술 스택
```yaml
dependencies:
  flutter:
    sdk: flutter

  # 상태 관리
  provider: ^6.0.0  # 또는 flutter_bloc

  # 로컬 데이터베이스
  sqflite: ^2.3.0
  path_provider: ^2.1.0

  # API 호출
  dio: ^5.4.0

  # 백그라운드 작업
  workmanager: ^0.5.1

  # 차트
  fl_chart: ^0.65.0

  # 보안 저장소 (API 키)
  flutter_secure_storage: ^9.0.0

  # 날짜 처리
  intl: ^0.18.0
```

### 데이터 흐름
```
1. 사용자 종목 추가
   → sqflite에 저장

2. 매일 오전/오후 (WorkManager)
   → Alpha Vantage API 호출
   → 현재가 조회
   → 일별 스냅샷 계산
   → sqflite에 저장

3. 대시보드 표시
   → sqflite에서 데이터 읽기
   → UI 렌더링
```

### SQLite 스키마
```sql
-- 포트폴리오
CREATE TABLE portfolios (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ticker TEXT NOT NULL,
  name TEXT NOT NULL,
  quantity REAL NOT NULL,
  average_cost REAL NOT NULL,
  market TEXT NOT NULL,
  created_at TEXT NOT NULL
);

-- 일별 스냅샷
CREATE TABLE daily_snapshots (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  snapshot_date TEXT NOT NULL UNIQUE,
  total_value REAL NOT NULL,
  total_investment REAL NOT NULL,
  total_profit REAL NOT NULL,
  daily_profit REAL,
  created_at TEXT NOT NULL
);

-- 수익 시계열 (그래프용)
CREATE TABLE profit_series (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date TEXT NOT NULL UNIQUE,
  daily_profit REAL,
  monthly_cumulative REAL,
  annual_cumulative REAL,
  created_at TEXT NOT NULL
);
```

### API 키 보안 방안
```dart
// ⚠️ 문제: 하드코딩 시 디컴파일로 노출됨
const API_KEY = 'your_api_key'; // 절대 이렇게 하지 말 것!

// ✅ 해결 1: flutter_secure_storage 사용
final storage = FlutterSecureStorage();
await storage.write(key: 'api_key', value: 'your_key');

// ✅ 해결 2: 환경 변수 (.env 파일)
// .env 파일을 .gitignore에 추가
// flutter_dotenv 패키지 사용

// ✅ 해결 3: 사용자가 직접 API 키 입력
// 앱 설정에서 사용자가 자신의 API 키 등록
```

**⚠️ 중요:** 완벽한 보안은 불가능합니다. 앱을 디컴파일하면 API 키를 추출할 수 있습니다.
무료 API(Alpha Vantage)는 사용자별 키 발급이므로 큰 문제는 아니지만, 상용 서비스에서는 백엔드 필수입니다.

### 개발 기간
- **1-2주**: 기본 UI + 로컬 DB 구축
- **1-2주**: API 연동 + 데이터 계산 로직
- **1-2주**: 그래프 + 스케줄러
- **1주**: 테스트 및 배포
**총 4-7주 (1-2개월)**

---

## 옵션 2: Flutter + 백엔드 (클라우드 앱)

### 구조
```
Flutter App
├── UI Layer
└── API Client
    └── HTTP → Backend Server
                ├── REST API
                ├── Scheduler (Cron)
                ├── PostgreSQL
                └── Stock API Proxy
```

### 장점
✅ **API 키 보안** - 백엔드에서만 API 키 관리
✅ **멀티 디바이스** - 여러 기기에서 동일 데이터 접근
✅ **데이터 백업** - 서버에 안전하게 저장
✅ **효율적인 API 사용** - 서버에서 일괄 조회 후 캐싱
✅ **확장 가능** - 추후 웹 버전, 공유 기능 추가 용이

### 단점
❌ **개발 시간 증가** - 백엔드 개발 + 배포 설정 필요
❌ **운영 비용** - 서버 호스팅 비용 ($5-20/월)
❌ **네트워크 의존** - 오프라인에서 제한적
❌ **복잡도 증가** - 프론트엔드 + 백엔드 동시 관리

### 기술 스택
**프론트엔드:**
- Flutter + Provider/Bloc
- dio (HTTP client)

**백엔드:**
- Node.js/Nest.js 또는 Python/FastAPI
- PostgreSQL
- node-cron (스케줄러)

**인프라:**
- Railway/Render (백엔드)
- Supabase/Neon (DB)

### 개발 기간
**8-13주 (2-3개월)** - TECH_STACK.md 참고

---

## 옵션 3: Flutter + Firebase (하이브리드) ⭐ 균형잡힌 선택

### 구조
```
Flutter App
├── UI Layer
├── Firebase Auth (인증)
├── Firestore (데이터베이스)
├── Firebase Functions (서버리스 백엔드)
└── API Layer (주식 API)
```

### 장점
✅ **빠른 개발** - 백엔드 코드 최소화
✅ **멀티 디바이스** - Firebase로 자동 동기화
✅ **무료 플랜** - 소규모는 무료
✅ **인증 간편** - Firebase Auth 내장
✅ **실시간 동기화** - Firestore 실시간 업데이트

### 단점
❌ **Firebase 종속** - 플랫폼 락인
❌ **복잡한 쿼리 제한** - Firestore는 SQL보다 제한적
❌ **비용 증가 가능** - 사용자 증가 시 비용 급증
❌ **API 키 여전히 문제** - Cloud Functions 필요

### 기술 스택
```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  cloud_firestore: ^4.13.0
  firebase_storage: ^11.5.0
```

**백엔드 (Firebase Functions):**
```javascript
// 매일 실행되는 Cloud Function
exports.updateStockPrices = functions.pubsub
  .schedule('0 16 * * *') // 매일 오후 4시
  .onRun(async (context) => {
    // Alpha Vantage API 호출
    // Firestore에 저장
  });
```

### 개발 기간
**5-9주 (1.5-2개월)**

---

## 📊 비교 표

| 항목 | Flutter 단독 | Flutter + 백엔드 | Flutter + Firebase |
|------|-------------|-----------------|-------------------|
| **개발 기간** | 1-2개월 | 2-3개월 | 1.5-2개월 |
| **개발 난이도** | 쉬움 | 어려움 | 보통 |
| **월 비용** | $0 | $5-20 | $0-10 |
| **멀티 디바이스** | ❌ | ✅ | ✅ |
| **오프라인** | ✅ | ⚠️ | ⚠️ |
| **API 보안** | ⚠️ | ✅ | ✅ |
| **확장성** | ⚠️ | ✅ | ✅ |
| **데이터 백업** | ❌ | ✅ | ✅ |

---

## 🎯 MVP 단계별 추천

### Phase 1: MVP (1-2개월)
**→ Flutter 단독 (로컬 앱)**
- 최소 비용, 최대 속도
- 핵심 기능 검증
- 사용자 피드백 수집

### Phase 2: 베타 (2-3개월)
**→ Firebase 추가**
- 멀티 디바이스 지원
- 계정 시스템 추가
- Cloud Functions로 API 보안

### Phase 3: 정식 출시 (4-6개월)
**→ 자체 백엔드 구축 (필요시)**
- Firebase 비용 절감
- 완전한 커스터마이징
- 고급 기능 (배당금, 알림 등)

---

## 💡 최종 추천: Flutter 단독으로 시작

**MVP는 Flutter 단독으로 시작하세요!**

**이유:**
1. 2-3개월 만에 완성 가능
2. 비용 $0로 시작
3. 핵심 가치(포트폴리오 추적 + 그래프) 빠르게 검증
4. 나중에 백엔드 추가 가능 (점진적 업그레이드)

**다음 파일에서 구체적인 구현 방법을 확인하세요:**
- `FLUTTER_ONLY_GUIDE.md` (곧 작성 예정)

**보안 대응:**
- Alpha Vantage는 무료 API로 키가 노출되어도 큰 문제 없음
- 사용자가 자신의 API 키를 직접 등록하도록 하면 완벽 해결
- 추후 사용자 증가 시 백엔드 추가

**마이그레이션 계획:**
1. 로컬 앱으로 MVP 출시
2. 사용자 피드백 수집
3. 필요 시 Firebase 또는 백엔드 추가
4. 로컬 데이터를 클라우드로 마이그레이션하는 기능 제공
