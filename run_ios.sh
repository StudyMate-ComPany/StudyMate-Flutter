#!/bin/bash

# StudyMate Flutter iOS 실행 스크립트
# 이 스크립트는 iOS 앱을 쉽게 실행할 수 있도록 도와줍니다.

echo "🚀 StudyMate iOS 앱 실행 준비 중..."

# Flutter 환경 확인
echo "📋 Flutter 환경 체크..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter가 설치되지 않았습니다."
    echo "👉 https://flutter.dev/docs/get-started/install 에서 설치하세요."
    exit 1
fi

# CocoaPods 확인
echo "📋 CocoaPods 체크..."
if ! command -v pod &> /dev/null; then
    echo "⚠️ CocoaPods가 설치되지 않았습니다. 설치 중..."
    sudo gem install cocoapods
fi

# 의존성 설치
echo "📦 Flutter 패키지 설치 중..."
flutter pub get

echo "📦 iOS 의존성 설치 중..."
cd ios
pod install
cd ..

# 실행 옵션 선택
echo ""
echo "🎯 실행 옵션을 선택하세요:"
echo "1) iOS 시뮬레이터에서 실행 (Debug)"
echo "2) iOS 시뮬레이터에서 실행 (Release)"
echo "3) 연결된 실제 기기에서 실행"
echo "4) Xcode에서 열기"
echo "5) 캐시 정리 후 실행"
echo "0) 종료"

read -p "선택: " choice

case $choice in
    1)
        echo "🏃 iOS 시뮬레이터에서 Debug 모드로 실행 중..."
        flutter run -d iphone
        ;;
    2)
        echo "🏃 iOS 시뮬레이터에서 Release 모드로 실행 중..."
        flutter run -d iphone --release
        ;;
    3)
        echo "📱 연결된 기기 확인 중..."
        flutter devices
        echo ""
        read -p "기기 ID를 입력하세요: " device_id
        flutter run -d $device_id
        ;;
    4)
        echo "🛠️ Xcode에서 프로젝트 열기..."
        open ios/Runner.xcworkspace
        ;;
    5)
        echo "🧹 캐시 정리 중..."
        flutter clean
        rm -rf ios/Pods ios/Podfile.lock
        rm -rf ~/Library/Developer/Xcode/DerivedData
        echo "📦 의존성 재설치 중..."
        flutter pub get
        cd ios && pod install && cd ..
        echo "🏃 iOS 시뮬레이터에서 실행 중..."
        flutter run -d iphone
        ;;
    0)
        echo "👋 종료합니다."
        exit 0
        ;;
    *)
        echo "❌ 잘못된 선택입니다."
        exit 1
        ;;
esac