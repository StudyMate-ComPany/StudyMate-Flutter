# 📱 StudyMate Flutter - iOS 앱 실행 가이드

## 🎯 프로젝트 정보
- **앱 이름**: 스터디메이트
- **Bundle ID**: com.studymate.app
- **최소 iOS 버전**: iOS 13.0
- **Flutter SDK**: 3.5.4+

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
studymate/
├── lib/                    # Dart 소스 코드
│   └── main.dart          # 앱 진입점
├── ios/                   # iOS 플랫폼 코드
│   ├── Runner/           # iOS 앱 설정
│   │   ├── Info.plist   # 앱 권한 및 설정
│   │   └── Assets.xcassets # 앱 아이콘 및 리소스
│   └── Podfile          # CocoaPods 의존성
├── android/              # Android 플랫폼 코드
└── pubspec.yaml         # Flutter 의존성

```

## 🔑 주요 기능

- **AI 학습 도우미**: 24시간 실시간 질의응답
- **스마트 분석**: 학습 패턴 분석 및 리포트
- **스터디 그룹**: 온라인 스터디룸 및 화면 공유
- **맞춤형 문제**: 수준별 문제 자동 생성

## 📦 사용된 주요 패키지

- **네트워킹**: dio, http
- **상태 관리**: provider
- **저장소**: shared_preferences, path_provider
- **UI/UX**: shimmer, lottie, cached_network_image
- **유틸리티**: intl, url_launcher, connectivity_plus
- **권한**: permission_handler
- **이미지**: image_picker

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

---

마지막 업데이트: 2025-08-22