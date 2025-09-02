# SNS 로그인 설정 가이드

## 1. 카카오 로그인 설정

### 1.1 카카오 개발자 등록
1. [카카오 개발자 사이트](https://developers.kakao.com) 접속
2. 로그인 후 "내 애플리케이션" 클릭
3. "애플리케이션 추가하기" 클릭
4. 앱 이름: "StudyMate", 회사명 입력

### 1.2 앱 키 발급
1. 생성된 앱 클릭
2. "앱 키" 메뉴에서 다음 키 확인:
   - Native App Key (Android/iOS용)
   - JavaScript Key (웹용)
   - REST API Key

### 1.3 플랫폼 등록
1. "플랫폼" 메뉴 클릭
2. Android 플랫폼 추가:
   - 패키지명: `com.studymate.studymate_flutter`
   - 키 해시 등록 (디버그용):
     ```bash
     # Mac/Linux
     keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android | openssl sha1 -binary | openssl base64
     
     # Windows
     keytool -exportcert -alias androiddebugkey -keystore %USERPROFILE%\.android\debug.keystore -storepass android -keypass android | openssl sha1 -binary | openssl base64
     ```
3. iOS 플랫폼 추가:
   - Bundle ID: `com.studymate.studymateFlutter`

### 1.4 카카오 로그인 활성화
1. "제품 설정" > "카카오 로그인" 클릭
2. 활성화 설정: ON
3. Redirect URI 설정:
   - `kakao{NATIVE_APP_KEY}://oauth`

## 2. 네이버 로그인 설정

### 2.1 네이버 개발자 등록
1. [네이버 개발자 센터](https://developers.naver.com) 접속
2. "Application" > "애플리케이션 등록"

### 2.2 앱 등록
1. 애플리케이션 이름: "StudyMate"
2. 사용 API: "네이버 로그인" 선택
3. 제공 정보 선택:
   - 이메일 주소 (필수)
   - 회원이름 (필수)
   - 프로필 사진

### 2.3 환경 설정
1. Android 설정:
   - 패키지명: `com.studymate.studymate_flutter`
   - 다운로드 URL: Google Play Store URL (출시 후 입력)
2. iOS 설정:
   - Bundle ID: `com.studymate.studymateFlutter`
   - URL Scheme: `naverlogin`

### 2.4 Client ID/Secret 확인
- 애플리케이션 정보에서 Client ID와 Client Secret 확인

## 3. 구글 로그인 설정

### 3.1 Firebase 프로젝트 생성
1. [Firebase Console](https://console.firebase.google.com) 접속
2. "프로젝트 만들기" 클릭
3. 프로젝트 이름: "StudyMate"

### 3.2 Android 앱 추가
1. Android 패키지명: `com.studymate.studymate_flutter`
2. SHA-1 지문 등록:
   ```bash
   # 디버그 키
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   
   # 릴리즈 키 (배포 시)
   keytool -list -v -keystore {keystore_path} -alias {alias_name}
   ```
3. google-services.json 다운로드
4. `android/app/` 폴더에 저장

### 3.3 iOS 앱 추가
1. iOS Bundle ID: `com.studymate.studymateFlutter`
2. GoogleService-Info.plist 다운로드
3. `ios/Runner/` 폴더에 저장

### 3.4 OAuth 2.0 클라이언트 ID
1. [Google Cloud Console](https://console.cloud.google.com) 접속
2. Firebase 프로젝트 선택
3. "API 및 서비스" > "사용자 인증 정보"
4. OAuth 2.0 클라이언트 ID 확인

## 4. 애플 로그인 설정

### 4.1 Apple Developer 계정
1. [Apple Developer](https://developer.apple.com) 접속 (유료 계정 필요)
2. "Certificates, Identifiers & Profiles" 접속

### 4.2 App ID 설정
1. "Identifiers" > "+" 클릭
2. App IDs 선택
3. Bundle ID: `com.studymate.studymateFlutter`
4. Capabilities에서 "Sign In with Apple" 체크

### 4.3 Service ID 생성
1. "Identifiers" > "+" 클릭
2. Services IDs 선택
3. Description: "StudyMate Login"
4. Identifier: `com.studymate.signin`

### 4.4 Key 생성
1. "Keys" > "+" 클릭
2. Key Name: "StudyMate Sign In"
3. "Sign in with Apple" 체크
4. Primary App ID 선택
5. Key 다운로드 및 저장

## 5. .env 파일 설정

`.env` 파일에 다음 내용 추가:

```env
# 기존 설정...

# 카카오 로그인
KAKAO_NATIVE_APP_KEY=your_kakao_native_app_key
KAKAO_JAVASCRIPT_APP_KEY=your_kakao_javascript_key

# 네이버 로그인
NAVER_CLIENT_ID=your_naver_client_id
NAVER_CLIENT_SECRET=your_naver_client_secret
NAVER_URL_SCHEME=naverlogin

# 구글 로그인
GOOGLE_WEB_CLIENT_ID=your_google_web_client_id
GOOGLE_IOS_CLIENT_ID=your_google_ios_client_id

# 애플 로그인
APPLE_SERVICE_ID=com.studymate.signin
APPLE_TEAM_ID=your_team_id
APPLE_KEY_ID=your_key_id
```

## 6. 테스트 계정

각 플랫폼별 테스트 계정 설정:

### 카카오
- 개발자 사이트에서 테스트 사용자 등록
- "내 애플리케이션" > "팀 관리" > "테스터 관리"

### 네이버
- 개발 단계에서는 개발자 계정으로만 테스트 가능
- 검수 통과 후 모든 사용자 이용 가능

### 구글
- Firebase Console에서 테스트 사용자 추가
- "Authentication" > "Sign-in method" > "승인된 도메인"

### 애플
- TestFlight를 통한 베타 테스트
- Sandbox 계정 사용

## 7. 주의사항

1. **보안**: 
   - API 키는 절대 GitHub에 올리지 마세요
   - .env 파일은 .gitignore에 포함되어 있어야 합니다

2. **배포 시**:
   - 릴리즈 키 해시 추가 등록
   - 프로덕션 환경 설정 변경
   - 각 플랫폼별 심사 준비

3. **에러 처리**:
   - 네트워크 오류
   - 사용자 취소
   - 권한 거부
   - 플랫폼별 에러 코드 처리

## 8. 문제 해결

### 카카오 로그인 안 될 때
- 키 해시가 올바르게 등록되었는지 확인
- 패키지명이 일치하는지 확인
- 인터넷 권한이 있는지 확인

### 네이버 로그인 안 될 때
- URL Scheme 설정 확인
- Client ID/Secret 확인
- 네이버 앱 설치 여부 확인

### 구글 로그인 안 될 때
- SHA-1 지문 등록 확인
- google-services.json 파일 위치 확인
- Firebase 프로젝트 설정 확인

### 애플 로그인 안 될 때
- Bundle ID 일치 확인
- Capabilities 설정 확인
- Provisioning Profile 확인