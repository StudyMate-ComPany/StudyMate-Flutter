# 📱 StudyMate Flutter - iOS 앱 실행 가이드

## 🎯 프로젝트 정보
- **앱 이름**: 스터디메이트 (StudyMate)
- **Bundle ID**: com.studymate.app
- **패키지명**: studymate_flutter
- **버전**: 1.0.0+1
- **최소 iOS 버전**: iOS 13.0
- **최소 Android SDK**: 21
- **Flutter SDK**: 3.5.4+
- **Dart SDK**: ^3.5.4

## 📋 사전 요구사항

### 필수 설치 항목
```bash
# Xcode (App Store에서 설치)
# Flutter SDK
# CocoaPods
brew install cocoapods
```

## 🚀 빠른 시작

### 1. 의존성 설치
```bash
# Flutter 패키지 설치
flutter pub get

# iOS 의존성 설치
cd ios
pod install
cd ..
```

### 2. iOS 시뮬레이터 실행
```bash
# 사용 가능한 시뮬레이터 확인
flutter devices

# iOS 시뮬레이터 실행
flutter run -d iphone
```

### 3. 실제 기기에서 실행
```bash
# 기기 연결 후
flutter run -d <device-id>
```

## 🛠️ 개발 명령어

### 빌드 및 실행
```bash
# Debug 모드 실행
flutter run

# Release 모드 실행
flutter run --release

# 프로필 모드 실행
flutter run --profile
```

### 빌드만 하기
```bash
# iOS 앱 빌드 (시뮬레이터용)
flutter build ios --simulator

# iOS 앱 빌드 (실제 기기용)
flutter build ios --no-codesign
```

### 정리 및 재빌드
```bash
# 캐시 정리
flutter clean

# iOS 관련 정리
cd ios
pod deintegrate
pod cache clean --all
rm -rf ~/Library/Developer/Xcode/DerivedData
cd ..

# 재설치
flutter pub get
cd ios && pod install && cd ..
```

## 📱 Xcode에서 실행

1. Xcode 열기
```bash
open ios/Runner.xcworkspace
```

2. 상단 툴바에서 시뮬레이터 또는 실제 기기 선택
3. ▶️ 버튼 클릭하여 실행

## 🔧 일반적인 문제 해결

### CocoaPods 관련 오류
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
```

### 빌드 오류
```bash
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter run
```

### 시뮬레이터가 안 보일 때
```bash
# Xcode 열기
open -a Simulator

# 시뮬레이터 리셋
xcrun simctl shutdown all
xcrun simctl erase all
```

## 📝 프로젝트 구조

```
StudyMate-Flutter/
├── lib/                    # Dart 소스 코드
│   ├── main.dart          # 앱 진입점
│   ├── config/            # 앱 설정 및 상수
│   ├── l10n/              # 다국어 지원
│   ├── models/            # 데이터 모델
│   ├── providers/         # 상태 관리 (Provider)
│   ├── screens/           # 화면 컴포넌트
│   │   ├── auth/          # 인증 관련 화면
│   │   ├── home/          # 홈 화면
│   │   ├── learning/      # 학습 기능
│   │   ├── onboarding/    # 온보딩
│   │   ├── profile/       # 프로필
│   │   ├── settings/      # 설정
│   │   ├── study/         # 스터디 그룹
│   │   └── subscription/  # 구독 관리
│   ├── services/          # API 및 서비스 로직
│   ├── theme/             # 앱 테마 및 스타일
│   ├── utils/             # 유틸리티 함수
│   └── widgets/           # 재사용 가능한 위젯
├── assets/                # 정적 리소스
│   ├── images/            # 이미지 파일
│   ├── icons/             # 아이콘
│   └── fonts/             # 커스텀 폰트
├── ios/                   # iOS 플랫폼 코드
│   ├── Runner/           # iOS 앱 설정
│   │   ├── Info.plist   # 앱 권한 및 설정
│   │   └── Assets.xcassets # 앱 아이콘 및 리소스
│   └── Podfile          # CocoaPods 의존성
├── android/              # Android 플랫폼 코드
├── test/                 # 단위 테스트
├── integration_test/     # 통합 테스트
├── .agents/              # AI 에이전트 설정
└── pubspec.yaml         # Flutter 의존성 관리

```

## 🔑 주요 기능

- **스마트 학습 도우미**: 24시간 실시간 질의응답
- **스마트 분석**: 학습 패턴 분석 및 리포트
- **스터디 그룹**: 온라인 스터디룸 및 화면 공유
- **맞춤형 문제**: 수준별 문제 자동 생성

## 📦 사용된 주요 패키지

### 네트워킹
- `dio: ^5.4.0` - 강력한 HTTP 클라이언트
- `http: ^1.2.0` - 기본 HTTP 통신

### 상태 관리
- `provider: ^6.1.1` - Flutter 상태 관리

### 저장소
- `shared_preferences: ^2.2.2` - 간단한 데이터 영구 저장
- `path_provider: ^2.1.1` - 파일 시스템 경로
- `sqflite: ^2.3.0` - SQLite 데이터베이스
- `path: ^1.8.3` - 경로 조작 유틸리티

### UI/UX
- `flutter_animate: ^4.5.0` - 애니메이션 효과
- `lottie: ^3.1.0` - Lottie 애니메이션
- `google_fonts: ^6.2.1` - Google 폰트
- `flutter_svg: ^2.0.9` - SVG 이미지 렌더링
- `cached_network_image: ^3.3.1` - 네트워크 이미지 캐싱
- `shimmer: ^3.0.0` - 로딩 효과

### 유틸리티
- `intl: ^0.19.0` - 국제화 및 지역화
- `url_launcher: ^6.2.2` - URL 실행
- `connectivity_plus: ^5.0.2` - 네트워크 연결 상태
- `uuid: ^4.5.1` - UUID 생성

### 권한 & 미디어
- `permission_handler: ^11.1.0` - 권한 관리
- `image_picker: ^1.0.5` - 이미지 선택 및 촬영

### 알림
- `flutter_local_notifications: ^17.2.3` - 로컬 알림
- `timezone: ^0.9.4` - 시간대 처리

### 환경 설정
- `flutter_dotenv: ^5.1.0` - 환경 변수 관리

### 커스텀 폰트
- ChangwonDangamAsac (Bold)
- ChangwonDangamRound (Regular)

## 🚨 권한 설정

앱에서 요청하는 권한:
- 📷 카메라: 프로필 사진 촬영
- 🖼️ 사진 라이브러리: 프로필 사진 선택
- 🎤 마이크: 음성 녹음 기능
- 📊 사용자 추적: 맞춤형 학습 추천

## 🔄 업데이트 방법

```bash
# Flutter SDK 업데이트
flutter upgrade

# 패키지 업데이트
flutter pub upgrade

# iOS 의존성 업데이트
cd ios
pod update
cd ..
```

## 📞 지원

문제가 발생하면:
1. `flutter doctor -v` 실행하여 환경 확인
2. GitHub Issues에 문제 제보
3. 개발팀 문의: dev@studymate.app

## 🧪 테스트

### 단위 테스트 실행
```bash
flutter test
```

### 통합 테스트 실행
```bash
flutter test integration_test
```

### 테스트 커버리지 확인
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 🛡️ 환경 변수 설정

`.env` 파일을 프로젝트 루트에 생성하고 다음 변수들을 설정:

```env
API_BASE_URL=your_api_base_url
OPENAI_API_KEY=your_openai_api_key
```

## 📱 앱 아이콘 생성

```bash
flutter pub run flutter_launcher_icons
```

## 🔨 빌드 최적화

### iOS 앱 배포용 빌드
```bash
flutter build ios --release
```

### Android 앱 배포용 빌드
```bash
flutter build apk --release
flutter build appbundle --release  # Google Play Store용
```

## 📊 성능 프로파일링

```bash
# 프로필 모드로 실행
flutter run --profile

# DevTools 실행
flutter pub global activate devtools
flutter pub global run devtools
```

## 🤝 기여 가이드

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 있습니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

---

마지막 업데이트: 2025-08-30