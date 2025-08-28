#!/bin/bash

echo "🚀 StudyMate App Launcher"
echo "========================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Navigate to project directory
cd "$(dirname "$0")"

echo "📱 Checking Flutter environment..."
flutter doctor

echo ""
echo "📦 Getting dependencies..."
flutter pub get

echo ""
echo "🔍 Available devices:"
flutter devices

echo ""
echo -e "${YELLOW}Choose your platform:${NC}"
echo "1) iOS Simulator (iPhone 16 Pro)"
echo "2) Android Emulator"
echo "3) Both (iOS and Android)"
echo "4) Web Browser"
echo "5) All platforms"
echo "0) Exit"

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        echo -e "${GREEN}📱 Launching on iOS Simulator...${NC}"
        flutter run -d DBF74A60-5537-4741-898F-EB733055B29B
        ;;
    2)
        echo -e "${GREEN}🤖 Launching on Android Emulator...${NC}"
        flutter run -d emulator-5554
        ;;
    3)
        echo -e "${GREEN}📱🤖 Launching on both iOS and Android...${NC}"
        # Run iOS in background
        flutter run -d DBF74A60-5537-4741-898F-EB733055B29B &
        IOS_PID=$!
        
        # Wait a bit before starting Android
        sleep 5
        
        # Run Android
        flutter run -d emulator-5554 &
        ANDROID_PID=$!
        
        echo ""
        echo -e "${YELLOW}Apps are launching on both platforms!${NC}"
        echo "iOS Process ID: $IOS_PID"
        echo "Android Process ID: $ANDROID_PID"
        echo ""
        echo "Press Ctrl+C to stop both apps"
        
        # Wait for both processes
        wait $IOS_PID
        wait $ANDROID_PID
        ;;
    4)
        echo -e "${GREEN}🌐 Launching in Web Browser...${NC}"
        flutter run -d chrome
        ;;
    5)
        echo -e "${GREEN}🚀 Launching on all available platforms...${NC}"
        flutter run -d all
        ;;
    0)
        echo "👋 Goodbye!"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid choice!${NC}"
        exit 1
        ;;
esac

echo ""
echo "✅ Done!"