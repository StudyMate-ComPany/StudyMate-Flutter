import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../auth/modern_login_screen.dart';

class ReadyCompleteScreen extends StatefulWidget {
  const ReadyCompleteScreen({super.key});

  @override
  State<ReadyCompleteScreen> createState() => _ReadyCompleteScreenState();
}

class _ReadyCompleteScreenState extends State<ReadyCompleteScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    // 자동 이동 제거 - 버튼을 눌러야만 이동
  }

  void _navigateToLogin() {
    if (_isNavigating) return;
    _isNavigating = true;
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          const ModernLoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF70C4DE),
      body: SafeArea(
        child: Stack(
          children: [
            // 메인 콘텐츠
            Column(
              children: [
                const SizedBox(height: 91), // 147 - 56(status bar)
                
                // 준비가 끝났어요! 텍스트
                const Text(
                  '준비가 끝났어요!',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2857,
                  ),
                ).animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.2, end: 0),
                
                const SizedBox(height: 16),
                
                // 오늘은 요약부터 해봐요
                const Text(
                  '오늘은 요약부터 해봐요',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.3636,
                  ),
                ).animate()
                  .fadeIn(delay: 200.ms, duration: 500.ms),
                
                const SizedBox(height: 17),
                
                // 이제 함께 시작해요
                const Text(
                  '이제 함께 시작해요',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1.4118,
                  ),
                ).animate()
                  .fadeIn(delay: 400.ms, duration: 500.ms),
                
                const SizedBox(height: 92),
                
                // 피그마 캐릭터 이미지
                SizedBox(
                  width: 268,
                  height: 320,
                  child: Image.asset(
                    'assets/images/ready_complete_character.png', // 피그마에서 다운로드한 이미지
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // 이미지가 없을 경우 대체 위젯
                      return Image.asset(
                        'assets/images/onboarding_2.png', // 대체 이미지
                        fit: BoxFit.contain,
                        errorBuilder: (context, error2, stackTrace2) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.celebration_rounded,
                                  size: 100,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  '🎉',
                                  style: TextStyle(fontSize: 60),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ).animate()
                  .scale(
                    delay: 600.ms,
                    duration: 800.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(),
                
                const Spacer(),
                
                // 스터디메이트 시작하기 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: GestureDetector(
                    onTap: _navigateToLogin,
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          '스터디메이트 시작하기',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4D9DB5),
                            height: 1.4444,
                          ),
                        ),
                      ),
                    ),
                  ),
                ).animate()
                  .fadeIn(delay: 800.ms, duration: 500.ms)
                  .slideY(begin: 0.2, end: 0),
                
                const SizedBox(height: 50),
              ],
            ),
          ],
        ),
      ),
    );
  }
}