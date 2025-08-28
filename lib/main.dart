import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/local_storage_service.dart';
import 'services/notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/study_provider.dart';
import 'providers/ai_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/learning_plan_provider.dart';
import 'screens/auth/modern_login_screen.dart';
import 'screens/home/new_home_screen.dart';
import 'theme/modern_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // 시스템 UI 오버레이 스타일 설정
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Initialize local storage
  await LocalStorageService.initialize();
  
  // Initialize notification service
  try {
    await NotificationService().initialize();
    await NotificationService().scheduleDailyStudyReminders();
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
            
            // 테마 설정 - 모던 테마 사용
            theme: ModernTheme.lightTheme,
            themeMode: ThemeMode.light,
        
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
        
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            switch (authProvider.state) {
              case AuthState.loading:
                return Scaffold(
                  backgroundColor: ModernTheme.backgroundColor,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: ModernTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(
                            Icons.school,
                            size: 50,
                            color: Colors.white,
                          ),
                        ).animate()
                          .fadeIn(duration: 600.ms)
                          .scale(delay: 300.ms),
                        const SizedBox(height: 24),
                        const Text(
                          '스터디메이트',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: ModernTheme.primaryColor,
                          ),
                        ).animate()
                          .fadeIn(delay: 600.ms),
                        const SizedBox(height: 8),
                        const Text(
                          '로딩 중...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ).animate()
                          .fadeIn(delay: 800.ms),
                        const SizedBox(height: 32),
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(ModernTheme.primaryColor),
                        ).animate()
                          .fadeIn(delay: 1000.ms),
                      ],
                    ),
                  ),
                );
              case AuthState.authenticated:
                return const NewHomeScreen();
              case AuthState.unauthenticated:
              case AuthState.error:
              default:
                return const ModernLoginScreen();
            }
          },
        ),
          );
        },
      ),
    );
  }
}