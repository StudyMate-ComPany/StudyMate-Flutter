# 🚀 StudyMate Flutter 프로젝트 설정 가이드

## 📋 목차
1. [개발 환경 준비](#개발-환경-준비)
2. [프로젝트 클론 및 설정](#프로젝트-클론-및-설정)
3. [플랫폼별 설정](#플랫폼별-설정)
4. [환경 변수 설정](#환경-변수-설정)
5. [개발 도구 설정](#개발-도구-설정)
6. [트러블슈팅](#트러블슈팅)

## 🛠️ 개발 환경 준비

### 시스템 요구사항
- **운영체제**: macOS (iOS 개발), Windows/Linux/macOS (Android 개발)
- **RAM**: 최소 8GB (16GB 권장)
- **저장공간**: 최소 10GB 여유 공간

### 필수 소프트웨어 설치

#### 1. Flutter SDK 설치
```bash
# macOS (Homebrew 사용)
brew install flutter

# 또는 공식 사이트에서 다운로드
# https://flutter.dev/docs/get-started/install
```

#### 2. Dart SDK
Flutter SDK에 포함되어 있음

#### 3. IDE 설치
- **VS Code** (권장)
  ```bash
  # Flutter 및 Dart 확장 설치
  code --install-extension Dart-Code.flutter
  code --install-extension Dart-Code.dart-code
  ```
  
- **Android Studio**
  - [공식 사이트](https://developer.android.com/studio)에서 다운로드
  - Flutter 플러그인 설치

#### 4. iOS 개발 도구 (macOS만 해당)
```bash
# Xcode 설치 (App Store)
# CocoaPods 설치
sudo gem install cocoapods
```

#### 5. Android 개발 도구
- Android Studio 설치 후 SDK Manager에서:
  - Android SDK
  - Android SDK Command-line Tools
  - Android SDK Build-Tools
  - Android SDK Platform-Tools

### Flutter 환경 검증
```bash
flutter doctor -v
```

모든 항목이 ✓ 표시되어야 합니다.

## 📦 프로젝트 클론 및 설정

### 1. 레포지토리 클론
```bash
git clone https://github.com/your-org/StudyMate-Flutter.git
cd StudyMate-Flutter
```

### 2. 의존성 설치
```bash
# Flutter 패키지 설치
flutter pub get

# iOS 의존성 설치 (macOS만)
cd ios
pod install
cd ..
```

### 3. 환경 변수 설정
프로젝트 루트에 `.env` 파일 생성:
```bash
cp .env.example .env
```

`.env` 파일 편집:
```env
# API 설정
API_BASE_URL=https://api.studymate.com
API_TIMEOUT=30000

# OpenAI 설정
OPENAI_API_KEY=your_openai_api_key_here

# Firebase 설정 (선택사항)
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_API_KEY=your_api_key

# 기타 설정
DEBUG_MODE=true
ENABLE_LOGGING=true
```

## 🍎 iOS 플랫폼 설정

### 1. 번들 ID 설정
`ios/Runner.xcodeproj`를 Xcode에서 열기:
```bash
open ios/Runner.xcworkspace
```

- Runner > General > Bundle Identifier: `com.studymate.app`

### 2. 서명 설정
- Runner > Signing & Capabilities
- Team 선택 (Apple Developer 계정 필요)
- Automatically manage signing 체크

### 3. 권한 설정
`ios/Runner/Info.plist`에 필요한 권한 추가:
```xml
<key>NSCameraUsageDescription</key>
<string>프로필 사진 촬영을 위해 카메라 접근이 필요합니다.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>프로필 사진 선택을 위해 사진 라이브러리 접근이 필요합니다.</string>
<key>NSMicrophoneUsageDescription</key>
<string>음성 녹음 기능을 위해 마이크 접근이 필요합니다.</string>
```

### 4. 최소 iOS 버전 설정
`ios/Podfile`:
```ruby
platform :ios, '13.0'
```

## 🤖 Android 플랫폼 설정

### 1. 앱 ID 설정
`android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        applicationId "com.studymate.app"
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

### 2. 권한 설정
`android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

### 3. ProGuard 규칙 (Release 빌드)
`android/app/proguard-rules.pro`:
```proguard
# Flutter 관련 규칙
-keep class io.flutter.** { *; }
-keep class com.studymate.** { *; }
```

## 🛠️ 개발 도구 설정

### VS Code 설정
`.vscode/settings.json`:
```json
{
  "dart.flutterSdkPath": "/usr/local/flutter",
  "editor.formatOnSave": true,
  "editor.rulers": [80],
  "dart.lineLength": 80,
  "files.autoSave": "onFocusChange"
}
```

### 추천 VS Code 확장
- Flutter
- Dart
- Flutter Widget Snippets
- Awesome Flutter Snippets
- Pubspec Assist
- Flutter Color
- Error Lens

### Git Hooks 설정
```bash
# pre-commit hook 설정
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh
flutter analyze
flutter test
EOF

chmod +x .git/hooks/pre-commit
```

## 🐛 디버깅 설정

### VS Code launch.json
`.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "StudyMate (Debug)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": ["--debug"]
    },
    {
      "name": "StudyMate (Profile)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": ["--profile"]
    },
    {
      "name": "StudyMate (Release)",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": ["--release"]
    }
  ]
}
```

## 🔍 코드 품질 도구

### 1. 정적 분석
```bash
# 코드 분석
flutter analyze

# 자동 수정
dart fix --apply
```

### 2. 코드 포맷팅
```bash
# 전체 프로젝트 포맷팅
dart format .

# 특정 파일 포맷팅
dart format lib/main.dart
```

### 3. 테스트 실행
```bash
# 모든 테스트 실행
flutter test

# 특정 테스트 파일 실행
flutter test test/widget_test.dart

# 커버리지 리포트 생성
flutter test --coverage
```

## 🚨 트러블슈팅

### 일반적인 문제 해결

#### 1. Flutter 버전 충돌
```bash
# Flutter 버전 확인
flutter --version

# 특정 버전으로 변경
flutter downgrade 3.5.4
```

#### 2. 캐시 문제
```bash
# Flutter 캐시 정리
flutter clean
rm -rf ~/.pub-cache
flutter pub cache repair
flutter pub get
```

#### 3. iOS 빌드 실패
```bash
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod deintegrate
pod install --repo-update
cd ..
flutter clean
flutter pub get
```

#### 4. Android 빌드 실패
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### 5. 의존성 충돌
```bash
# pubspec.lock 삭제 후 재설치
rm pubspec.lock
flutter pub get
```

### 에러 메시지별 해결법

#### "Waiting for another flutter command to release the startup lock"
```bash
rm ~/flutter/bin/cache/lockfile
```

#### "CocoaPods not installed"
```bash
sudo gem install cocoapods
pod setup
```

#### "Android SDK not found"
```bash
flutter config --android-sdk /path/to/android/sdk
```

## 📚 추가 리소스

- [Flutter 공식 문서](https://flutter.dev/docs)
- [Dart 공식 문서](https://dart.dev/guides)
- [StudyMate API 문서](API_DOCS.md)
- [기여 가이드](CONTRIBUTING.md)

## 💬 지원

문제가 계속될 경우:
1. [GitHub Issues](https://github.com/your-org/StudyMate-Flutter/issues) 확인
2. 새 이슈 생성
3. 개발팀 연락: dev@studymate.app

---

최종 업데이트: 2025-08-30