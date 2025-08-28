class AppConstants {
  // API
  static const String baseUrl = 'https://54.161.77.144';
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // App Info
  static const String appName = '스터디메이트';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI 기반 학습 도우미';
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';
  
  // Default Values
  static const int defaultStudyDuration = 25; // minutes
  static const int defaultBreakDuration = 5; // minutes
  static const int defaultLongBreakDuration = 15; // minutes
  static const int defaultSessionsUntilLongBreak = 4;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;
  
  // Study Constants
  static const List<String> defaultSubjects = [
    '수학',
    '과학',
    '영어',
    '역사',
    '지리',
    '물리',
    '화학',
    '생물학',
    '컴퓨터 과학',
    '문학',
    '미술',
    '음악',
    '체육',
    '외국어',
    '철학',
    '심리학',
    '경제학',
    '경영학',
  ];
  
  static const List<String> studyTypes = [
    '읽기',
    '쓰기',
    '문제 해결',
    '암기',
    '연구',
    '연습',
    '복습',
    '토론',
    '프로젝트 작업',
    '발표 준비',
  ];
  
  static const List<String> difficultyLevels = [
    '초급',
    '중급',
    '고급',
    '전문가',
  ];
}

class AppColors {
  // Primary Colors
  static const primaryBlue = 0xFF1976D2;
  static const primaryLight = 0xFF42A5F5;
  static const primaryDark = 0xFF0D47A1;
  
  // Secondary Colors
  static const secondaryGreen = 0xFF4CAF50;
  static const secondaryOrange = 0xFFFF9800;
  static const secondaryPurple = 0xFF9C27B0;
  static const secondaryRed = 0xFFF44336;
  
  // Neutral Colors
  static const grey100 = 0xFFF5F5F5;
  static const grey200 = 0xFFE0E0E0;
  static const grey300 = 0xFFBDBDBD;
  static const grey400 = 0xFF9E9E9E;
  static const grey500 = 0xFF757575;
  static const grey600 = 0xFF616161;
  static const grey700 = 0xFF424242;
  static const grey800 = 0xFF212121;
  
  // Status Colors
  static const success = 0xFF4CAF50;
  static const warning = 0xFFFF9800;
  static const error = 0xFFF44336;
  static const info = 0xFF2196F3;
  
  // Goal Type Colors
  static const dailyGoal = 0xFF4CAF50;
  static const weeklyGoal = 0xFF2196F3;
  static const monthlyGoal = 0xFF9C27B0;
  static const customGoal = 0xFFFF9800;
  
  // Session Status Colors
  static const activeSession = 0xFF4CAF50;
  static const pausedSession = 0xFFFF9800;
  static const completedSession = 0xFF2196F3;
  static const cancelledSession = 0xFFF44336;
}