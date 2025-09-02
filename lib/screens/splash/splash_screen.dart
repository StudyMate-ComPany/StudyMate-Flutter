import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../onboarding/onboarding_screen.dart';
import '../home/guest_main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  
  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    _progressController.forward();
    _initializeApp();
  }
  
  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      print('🚀 [SplashScreen] 앱 초기화 시작');
      
      // 상태바 스타일 설정
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      );

      // 최소 3초간 스플래시 화면 표시
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) {
        print('⚠️ [SplashScreen] Widget이 mounted 상태가 아님');
        return;
      }

      // 온보딩 완료 여부 확인
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;
      print('📱 [SplashScreen] 온보딩 완료 여부: $hasCompletedOnboarding');

      if (!mounted) {
        print('⚠️ [SplashScreen] Widget이 mounted 상태가 아님 (2차 체크)');
        return;
      }

      // 플로우: 스플래시 -> 온보딩(첫 실행) -> 로그인 화면
      if (!hasCompletedOnboarding) {
        print('🎯 [SplashScreen] 온보딩 화면으로 이동');
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      } else {
        // 온보딩을 완료한 사용자는 게스트 메인 화면으로 이동
        print('🎯 [SplashScreen] 게스트 메인 화면으로 이동');
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const GuestMainScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ [SplashScreen] 에러 발생: $e');
      print('📍 Stack trace: $stackTrace');
      
      // 에러 발생 시에도 온보딩 화면으로 이동
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF70C4DE), // Figma: RGB(112, 196, 222)
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 마스코트 이미지 - Figma: 159.41 x 159.41px
            Container(
              width: 159.41,
              height: 159.41,
              child: Image.asset(
                'assets/images/sm_main.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 159.41,
                    height: 159.41,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 80,
                    ),
                  );
                },
              ),
            ).animate()
              .fadeIn(duration: 600.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 500.ms,
              ),
            
            const SizedBox(height: 4), // Figma: 3.71px 간격
            
            // STUDYMATE 텍스트 - Figma: ChangwonDangamAsac Bold, 26.69px
            const Text(
              'STUDYMATE',
              style: TextStyle(
                fontFamily: 'ChangwonDangamAsac',
                fontSize: 26.69,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0,
                height: 1.2, // 32.03px / 26.69px
              ),
            ).animate()
              .fadeIn(delay: 200.ms, duration: 500.ms),
            
            const SizedBox(height: 192), // Figma: STUDYMATE에서 부제목까지 간격
            
            // "나만의 학습도우미" - Figma: Pretendard SemiBold, 18px
            const Text(
              '나만의 학습도우미',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0,
                height: 1.44, // 26px / 18px
              ),
            ).animate()
              .fadeIn(delay: 400.ms, duration: 500.ms),
          ],
        ),
      ),
    );
  }
}