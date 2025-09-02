# 📡 StudyMate API 문서

## 📋 목차
1. [API 개요](#api-개요)
2. [인증](#인증)
3. [주요 엔드포인트](#주요-엔드포인트)
4. [서비스 아키텍처](#서비스-아키텍처)
5. [에러 처리](#에러-처리)

## 🌐 API 개요

### 기본 정보
- **Base URL**: `https://api.studymate.com/v1`
- **프로토콜**: HTTPS
- **인증 방식**: Bearer Token (JWT)
- **응답 형식**: JSON
- **문자 인코딩**: UTF-8

### HTTP 헤더
```http
Content-Type: application/json
Accept: application/json
Authorization: Bearer {access_token}
X-App-Version: 1.0.0
X-Platform: iOS/Android
```

## 🔐 인증

### 1. 회원가입
```dart
POST /auth/register

// Request Body
{
  "email": "user@example.com",
  "password": "password123",
  "name": "홍길동",
  "phone": "010-1234-5678",
  "birthDate": "2000-01-01",
  "gender": "M",
  "agreeTerms": true,
  "agreeMarketing": false
}

// Response
{
  "success": true,
  "data": {
    "userId": "user_123456",
    "email": "user@example.com",
    "name": "홍길동",
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": 3600
  }
}
```

### 2. 로그인
```dart
POST /auth/login

// Request Body
{
  "email": "user@example.com",
  "password": "password123"
}

// Response
{
  "success": true,
  "data": {
    "userId": "user_123456",
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": 3600
  }
}
```

### 3. 토큰 갱신
```dart
POST /auth/refresh

// Request Body
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}

// Response
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": 3600
  }
}
```

### 4. 로그아웃
```dart
POST /auth/logout

// Request Header
Authorization: Bearer {access_token}

// Response
{
  "success": true,
  "message": "로그아웃되었습니다."
}
```

## 📚 주요 엔드포인트

### 사용자 관리

#### 프로필 조회
```dart
GET /users/profile

// Response
{
  "success": true,
  "data": {
    "userId": "user_123456",
    "email": "user@example.com",
    "name": "홍길동",
    "phone": "010-1234-5678",
    "profileImage": "https://cdn.studymate.com/profiles/user_123456.jpg",
    "level": 3,
    "points": 1250,
    "studyTime": 3600,
    "joinDate": "2024-01-01T00:00:00Z"
  }
}
```

#### 프로필 수정
```dart
PATCH /users/profile

// Request Body (multipart/form-data)
{
  "name": "김철수",
  "phone": "010-9876-5432",
  "profileImage": File // 이미지 파일
}

// Response
{
  "success": true,
  "data": {
    "userId": "user_123456",
    "name": "김철수",
    "phone": "010-9876-5432",
    "profileImage": "https://cdn.studymate.com/profiles/user_123456_new.jpg"
  }
}
```

### 학습 관리

#### 질문하기 (AI 튜터)
```dart
POST /learning/ask

// Request Body
{
  "question": "2차 방정식의 근의 공식을 설명해주세요",
  "subject": "mathematics",
  "grade": "high_school_2",
  "context": "previous_conversation_id" // 선택사항
}

// Response
{
  "success": true,
  "data": {
    "conversationId": "conv_789012",
    "answer": "2차 방정식 ax² + bx + c = 0의 근의 공식은...",
    "references": [
      {
        "title": "2차 방정식",
        "url": "https://studymate.com/ref/quadratic"
      }
    ],
    "relatedQuestions": [
      "판별식이란 무엇인가요?",
      "2차 방정식의 그래프는 어떻게 그리나요?"
    ]
  }
}
```

#### 학습 기록 조회
```dart
GET /learning/history?page=1&limit=20&subject=mathematics

// Response
{
  "success": true,
  "data": {
    "total": 150,
    "page": 1,
    "limit": 20,
    "items": [
      {
        "sessionId": "session_345678",
        "subject": "mathematics",
        "topic": "2차 방정식",
        "startTime": "2024-08-30T10:00:00Z",
        "endTime": "2024-08-30T11:30:00Z",
        "duration": 5400,
        "questionsAsked": 12,
        "score": 85
      }
    ]
  }
}
```

#### 문제 생성
```dart
POST /learning/generate-problems

// Request Body
{
  "subject": "mathematics",
  "topic": "quadratic_equations",
  "difficulty": "medium",
  "count": 5,
  "type": "multiple_choice"
}

// Response
{
  "success": true,
  "data": {
    "problemSetId": "ps_567890",
    "problems": [
      {
        "id": "prob_1",
        "question": "x² - 5x + 6 = 0의 해는?",
        "options": [
          "x = 2, 3",
          "x = 1, 6",
          "x = -2, -3",
          "x = 0, 5"
        ],
        "correctAnswer": 0,
        "explanation": "인수분해하면 (x-2)(x-3) = 0이므로..."
      }
    ]
  }
}
```

### 스터디 그룹

#### 스터디 그룹 목록
```dart
GET /study-groups?category=mathematics&page=1&limit=10

// Response
{
  "success": true,
  "data": {
    "total": 45,
    "items": [
      {
        "groupId": "group_123",
        "name": "수학 마스터즈",
        "description": "고등학교 수학 심화 학습",
        "category": "mathematics",
        "memberCount": 12,
        "maxMembers": 20,
        "leader": {
          "userId": "user_789",
          "name": "김선생"
        },
        "createdAt": "2024-08-01T00:00:00Z"
      }
    ]
  }
}
```

#### 스터디 그룹 생성
```dart
POST /study-groups

// Request Body
{
  "name": "영어 회화 스터디",
  "description": "일상 영어 회화 연습",
  "category": "english",
  "maxMembers": 10,
  "isPublic": true,
  "tags": ["speaking", "conversation", "beginner"]
}

// Response
{
  "success": true,
  "data": {
    "groupId": "group_456",
    "name": "영어 회화 스터디",
    "inviteCode": "ENG2024"
  }
}
```

### 구독 관리

#### 구독 플랜 조회
```dart
GET /subscriptions/plans

// Response
{
  "success": true,
  "data": [
    {
      "planId": "basic",
      "name": "베이직",
      "price": 9900,
      "period": "monthly",
      "features": [
        "기본 AI 튜터",
        "일일 질문 30개",
        "기본 문제 생성"
      ]
    },
    {
      "planId": "premium",
      "name": "프리미엄",
      "price": 19900,
      "period": "monthly",
      "features": [
        "고급 AI 튜터",
        "무제한 질문",
        "맞춤형 문제 생성",
        "학습 분석 리포트",
        "스터디 그룹 무제한"
      ]
    }
  ]
}
```

#### 구독 신청
```dart
POST /subscriptions/subscribe

// Request Body
{
  "planId": "premium",
  "paymentMethod": "card",
  "autoRenew": true
}

// Response
{
  "success": true,
  "data": {
    "subscriptionId": "sub_789012",
    "planId": "premium",
    "startDate": "2024-08-30T00:00:00Z",
    "endDate": "2024-09-30T00:00:00Z",
    "status": "active"
  }
}
```

## 🏗️ 서비스 아키텍처

### 서비스 구조
```dart
lib/services/
├── api/
│   ├── api_client.dart         // HTTP 클라이언트 설정
│   ├── api_interceptor.dart    // 요청/응답 인터셉터
│   └── api_endpoints.dart      // API 엔드포인트 상수
├── auth/
│   ├── auth_service.dart       // 인증 서비스
│   └── token_manager.dart      // 토큰 관리
├── learning/
│   ├── ai_tutor_service.dart   // AI 튜터 서비스
│   ├── problem_service.dart    // 문제 생성 서비스
│   └── history_service.dart    // 학습 기록 서비스
├── user/
│   └── user_service.dart       // 사용자 관리 서비스
└── storage/
    ├── local_storage.dart      // 로컬 저장소
    └── secure_storage.dart     // 보안 저장소
```

### API 클라이언트 예제
```dart
// api_client.dart
import 'package:dio/dio.dart';

class ApiClient {
  late Dio _dio;
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.studymate.com/v1',
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(LogInterceptor());
  }
  
  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    return await _dio.get(path, queryParameters: params);
  }
  
  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }
  
  Future<Response> patch(String path, {dynamic data}) async {
    return await _dio.patch(path, data: data);
  }
  
  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}
```

### 인증 인터셉터 예제
```dart
// auth_interceptor.dart
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await TokenManager.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // 토큰 갱신 로직
      final newToken = await TokenManager.refreshToken();
      if (newToken != null) {
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final response = await _retry(err.requestOptions);
        handler.resolve(response);
        return;
      }
    }
    handler.next(err);
  }
}
```

## ❌ 에러 처리

### 에러 응답 형식
```json
{
  "success": false,
  "error": {
    "code": "AUTH_001",
    "message": "인증 토큰이 유효하지 않습니다.",
    "details": {
      "field": "token",
      "reason": "expired"
    }
  }
}
```

### 에러 코드

| 코드 | HTTP Status | 설명 |
|------|------------|------|
| AUTH_001 | 401 | 인증 토큰 없음 또는 유효하지 않음 |
| AUTH_002 | 401 | 토큰 만료 |
| AUTH_003 | 403 | 권한 없음 |
| USER_001 | 404 | 사용자를 찾을 수 없음 |
| USER_002 | 409 | 이미 존재하는 이메일 |
| VALIDATION_001 | 400 | 유효하지 않은 요청 데이터 |
| SERVER_001 | 500 | 내부 서버 오류 |
| RATE_LIMIT_001 | 429 | API 호출 제한 초과 |

### 에러 처리 예제
```dart
try {
  final response = await apiClient.post('/auth/login', data: {
    'email': email,
    'password': password,
  });
  
  if (response.data['success']) {
    // 성공 처리
    final token = response.data['data']['accessToken'];
    await TokenManager.saveToken(token);
  }
} on DioError catch (e) {
  if (e.response != null) {
    final error = e.response!.data['error'];
    switch (error['code']) {
      case 'AUTH_001':
        showError('이메일 또는 비밀번호가 올바르지 않습니다.');
        break;
      case 'VALIDATION_001':
        showError('입력 정보를 확인해주세요.');
        break;
      default:
        showError('오류가 발생했습니다. 다시 시도해주세요.');
    }
  } else {
    showError('네트워크 연결을 확인해주세요.');
  }
}
```

## 📊 API 사용 제한

### Rate Limiting
- **일반 사용자**: 분당 60회
- **프리미엄 사용자**: 분당 120회
- **API 키별**: 시간당 1000회

### Response Headers
```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1693468800
```

## 🔧 개발/테스트 환경

### 개발 서버
- **Base URL**: `https://dev-api.studymate.com/v1`
- **특징**: 실시간 로그, 느슨한 검증

### 스테이징 서버
- **Base URL**: `https://staging-api.studymate.com/v1`
- **특징**: 프로덕션과 동일한 환경

### 테스트 계정
```
Email: test@studymate.com
Password: Test123!@#
```

## 📱 WebSocket 연결

### 실시간 채팅 (스터디 그룹)
```dart
// WebSocket 연결
final channel = WebSocketChannel.connect(
  Uri.parse('wss://api.studymate.com/ws/chat'),
);

// 인증
channel.sink.add(json.encode({
  'type': 'auth',
  'token': accessToken,
}));

// 메시지 전송
channel.sink.add(json.encode({
  'type': 'message',
  'groupId': 'group_123',
  'content': '안녕하세요!',
}));

// 메시지 수신
channel.stream.listen((message) {
  final data = json.decode(message);
  print('Received: ${data['content']}');
});
```

## 📝 변경 이력

### v1.0.0 (2024-08-30)
- 초기 API 릴리스
- 기본 인증 및 학습 기능
- AI 튜터 서비스
- 스터디 그룹 기능

### v1.1.0 (예정)
- 화면 공유 API 추가
- 실시간 협업 도구
- 고급 분석 기능

---

최종 업데이트: 2025-08-30