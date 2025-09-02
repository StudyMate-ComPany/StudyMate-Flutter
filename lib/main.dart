import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'providers/ai_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/learning_plan_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/study_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/home/main_navigation_screen.dart';
import 'screens/test_screen.dart';
import 'screens/onboarding/notification_permission_screen.dart';
import 'screens/onboarding/notification_permission_screen_exact.dart';
import 'screens/auth/login_screen.dart';
import 'services/local_storage_service.dart';
import 'services/notification_service.dart';
import 'theme/studymate_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // 카카오 SDK 초기화
  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '',
    javaScriptAppKey: dotenv.env['KAKAO_JAVASCRIPT_APP_KEY'] ?? '',
  );
  
  // 시스템 UI 오버레이 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Initialize local storage
  await LocalStorageService.initialize();
  
  // Initialize notification service - 권한 요청 없이 초기화만
  try {
    // 알림 서비스는 초기화하되, 권한 요청은 온보딩에서 처리
    // await NotificationService().initialize();
    // await NotificationService().scheduleDailyStudyReminders();
  } catch (e) {
    debugPrint('알림 초기화 실패: $e');
    // 알림 권한이 없어도 앱은 정상 실행되도록 처리
  }
  
  runApp(const StudyMateApp());
}

class StudyMateApp extends StatelessWidget {
  const StudyMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudyProvider()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => LearningPlanProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: '스터디메이트 📚',
            debugShowCheckedModeBanner: false,
            
            // 테마 설정 - StudyMate 테마 사용
            theme: StudyMateTheme.lightTheme,
            darkTheme: StudyMateTheme.darkTheme,
            themeMode: ThemeMode.system, // 시스템 설정 따르기
        
        // 한국어 지역화 설정 - 강제로 한글 설정
        locale: const Locale('ko', 'KR'),
        localeResolutionCallback: (locale, supportedLocales) {
          // 항상 한국어를 반환
          return const Locale('ko', 'KR');
        },
        supportedLocales: const [
          Locale('ko', 'KR'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        
        // 앱 시작 - 스플래시 화면으로 시작
        home: const SplashScreen(),
          );
        },
      ),
    );
  }
}