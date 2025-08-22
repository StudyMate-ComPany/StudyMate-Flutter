# StudyMate Flutter App

AI-powered learning platform mobile application built with Flutter.

## 📱 Overview

StudyMate is a comprehensive learning management platform that helps students enhance their learning experience through AI-powered features. This Flutter application provides a mobile interface for both iOS and Android platforms.

## ✨ Features

### Core Features (MVP)
- **User Authentication**
  - Login/Register
  - Guest mode (Skip)
  - Secure token management

- **Home Dashboard**
  - Learning statistics
  - Daily goals tracking
  - Progress visualization
  - Quick actions menu

- **AI-Powered Learning**
  - Generate summaries from text/links
  - Create personalized quizzes
  - Intelligent content recommendations

- **Live Collaboration**
  - Create/Join quiz rooms
  - Real-time multiplayer quizzes
  - Live chat during sessions
  - Instant rankings

- **Statistics & Analytics**
  - Learning patterns analysis
  - Strength/weakness identification
  - Peer comparison
  - Progress tracking

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- iOS development setup (for iOS builds)
  - Xcode 14.0 or higher
  - iOS 12.0 or higher
- Android development setup (for Android builds)
  - Android Studio
  - Android SDK
  - Minimum SDK: API 21 (Android 5.0)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/StudyMate-Company/StudyMate-Flutter.git
cd StudyMate-Flutter
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure API endpoint**

Update the API base URL in `lib/core/constants/api_constants.dart`:
```dart
static const String baseUrl = 'http://your-api-url/api';
```

4. **Run the app**
```bash
# For iOS
flutter run -d ios

# For Android
flutter run -d android

# For all available devices
flutter run
```

## 📂 Project Structure

```
lib/
├── core/               # Core functionality
│   ├── constants/      # App constants
│   ├── services/       # API services
│   └── utils/          # Utility functions
├── models/             # Data models
├── providers/          # State management
├── screens/            # UI screens
│   ├── auth/          # Authentication screens
│   ├── home/          # Home dashboard
│   ├── study/         # Study features
│   ├── quiz/          # Quiz screens
│   ├── collaboration/ # Live quiz rooms
│   └── stats/         # Statistics
├── widgets/            # Reusable widgets
└── main.dart          # App entry point
```

## 🛠️ Technologies Used

- **Flutter**: Cross-platform mobile framework
- **Dart**: Programming language
- **Provider**: State management
- **Dio**: HTTP client
- **flutter_secure_storage**: Secure storage for tokens
- **shared_preferences**: Local storage
- **intl**: Internationalization

## 🔧 Configuration

### API Configuration
The app connects to the StudyMate API backend. Configure the endpoints in:
- `lib/core/constants/api_constants.dart`

### Authentication
The app uses JWT tokens for authentication. Tokens are securely stored using flutter_secure_storage.

## 📱 Screens

### Authentication Flow
1. **Splash Screen**: App introduction
2. **Login Screen**: User authentication
3. **Register Screen**: New user registration
4. **Guest Mode**: Skip authentication

### Main Features
1. **Home Dashboard**: Overview and quick actions
2. **Study Summary**: AI-generated summaries
3. **Quiz Center**: Create and take quizzes
4. **Live Rooms**: Multiplayer quiz rooms
5. **Statistics**: Learning analytics
6. **Profile**: User settings

## 🎨 UI/UX Design

The app follows Material Design 3 guidelines with:
- Clean and intuitive interface
- Consistent color scheme
- Responsive layouts
- Smooth animations
- Dark mode support (planned)

## 🧪 Testing

Run tests using:
```bash
flutter test
```

## 📦 Building for Production

### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🚀 Deployment

### Android
1. Build the release APK/AAB
2. Upload to Google Play Console
3. Configure app details and screenshots
4. Submit for review

### iOS
1. Build the release IPA
2. Upload to App Store Connect
3. Configure app details and screenshots
4. Submit for review

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is proprietary and confidential.

## 📞 Support

For support, email support@studymate.com

## 🔗 Related Projects

- [StudyMate API](https://github.com/StudyMate-Company/StudyMate-API) - Backend API server
- StudyMate Web (Coming soon) - Web application

## 📱 Screenshots

(Screenshots will be added soon)

## 🎯 Roadmap

- [ ] Push notifications
- [ ] Offline mode
- [ ] Dark theme
- [ ] Multi-language support
- [ ] Social features
- [ ] Advanced analytics
- [ ] Voice input
- [ ] AR features