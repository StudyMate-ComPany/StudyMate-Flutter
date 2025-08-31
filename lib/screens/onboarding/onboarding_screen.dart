import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/notification_service.dart';
import '../home/main_navigation_screen.dart';
import './notification_permission_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Figma 디자인에 맞는 온보딩 페이지 구성
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      pageNumber: "1/3",
      title: '핵심만 쏙,\n메이트와 요약해요',
      subtitle: null,
      imagePath: 'assets/images/onboarding_1.png',
      features: ['난이도 맞춤', '저장, 공유 가능', '하루 3회 무료'],
    ),
    OnboardingPage(
      pageNumber: "2/3",
      title: '메이트와 루틴해요',
      subtitle: '알림으로 매일 15분',
      imagePath: 'assets/images/onboarding_2.png',
      features: ['09시 • 12시 • 21시 알림', '매일 같은 시간', '연속일 표시'],
    ),
    OnboardingPage(
      pageNumber: "3/3", 
      title: '메이트와 퀴즈해요',
      subtitle: '반복으로 실력 상승',
      imagePath: 'assets/images/onboarding_3.png',
      features: ['다른 메이트와 함께 퀴즈 대결', '정답률 조절', '오답노트 제공'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // 상태바 설정
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 상단 헤더 - STUDYMATE 로고와 화살표
          SafeArea(
            bottom: false,
            child: Container(
              height: 95, // 높이 더 증가 (80 + 15)
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // STUDYMATE 로고 - 왼쪽 정렬
                    const Text(
                      'STUDYMATE',
                      style: TextStyle(
                        fontFamily: 'ChangwonDangamAsac',
                        fontSize: 24, // 크기 조정
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF70C4DE),
                        letterSpacing: 0,
                        height: 1.2,
                      ),
                    ),
                    // 다음 페이지 화살표 버튼
                    if (_currentPage < _pages.length - 1)
                      GestureDetector(
                        onTap: _nextPage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.arrow_forward,
                            size: 28, // 크기 조정
                            color: Color(0xFF70C4DE),
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
          
          // 페이지 컨텐츠
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _buildPage(_pages[index], index);
              },
            ),
          ),
          
          // 하단 네비게이션
          Container(
            height: 105, // 높이 증가 (90 + 15)
            padding: const EdgeInsets.fromLTRB(24, 15, 24, 0), // 위쪽 패딩 추가
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 페이지 인디케이터 - 중앙
                Center(
                  child: Text(
                    _pages[_currentPage].pageNumber,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF70C4DE),
                    ),
                  ),
                ),
                // 건너뛰기 또는 시작하기 버튼 - 오른쪽
                Align(
                  alignment: Alignment.centerRight,
                  child: _currentPage < _pages.length - 1
                    ? GestureDetector(
                        onTap: _skipOnboarding,
                        child: const Text(
                          '건너뛰기',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF545454),
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: _completeOnboarding,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF70C4DE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '시작하기',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, int index) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 20), // 상단 간격 줄임
            
            // 마스코트 이미지
            SizedBox(
              width: 240, // 크기 줄임
              height: 240,
              child: _buildMascotImage(index),
            ).animate()
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
            
            const SizedBox(height: 50), // 간격 조정
            
            // 메인 타이틀
            Text(
              page.title,
              style: const TextStyle(
                fontFamily: 'ChangwonDangamRound',
                fontSize: 28, // 크기 조정
                fontWeight: FontWeight.w400,
                color: Color(0xFF4D9DB5),
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ).animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: -0.1, end: 0),
            
            // 서브타이틀 (2,3번 페이지)
            if (page.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                page.subtitle!,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF545454),
                  height: 1.44,
                ),
                textAlign: TextAlign.center,
              ).animate()
                .fadeIn(delay: 200.ms, duration: 500.ms),
            ],
            
            const SizedBox(height: 50), // 간격 조정
            
            // 기능 목록 - 체크박스와 구분선 포함
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  // 상단 구분선
                  Container(
                    height: 1,
                    color: const Color(0xFFE5E5E5),
                  ),
                  for (int i = 0; i < (page.features?.length ?? 0); i++) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          // 체크 아이콘
                          Container(
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.only(right: 14),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF70C4DE),
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check,
                                size: 14,
                                color: Color(0xFF70C4DE),
                              ),
                            ),
                          ),
                          // 기능 텍스트
                          Expanded(
                            child: Text(
                              page.features![i],
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16, // 크기 조정
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF545454),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 600 + (i * 100)),
                        duration: 500.ms,
                      )
                      .slideX(begin: -0.1, end: 0),
                    // 구분선 (모든 항목 뒤에)
                    Container(
                      height: 1,
                      color: const Color(0xFFE5E5E5),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMascotImage(int pageIndex) {
    String imagePath;
    Widget fallbackWidget;
    
    switch (pageIndex) {
      case 0:
        imagePath = 'assets/images/onboarding_1.png';
        fallbackWidget = _buildFallbackMascot(
          Icons.auto_awesome,
          '핵심만 쏙!',
        );
        break;
      case 1:
        imagePath = 'assets/images/onboarding_2.png';
        fallbackWidget = _buildFallbackMascot(
          Icons.schedule,
          '매일 루틴!',
        );
        break;
      case 2:
        imagePath = 'assets/images/onboarding_3.png';
        fallbackWidget = _buildFallbackMascot(
          Icons.quiz,
          '퀴즈 대결!',
        );
        break;
      default:
        imagePath = 'assets/images/sm_main.png';
        fallbackWidget = _buildFallbackMascot(
          Icons.school,
          'StudyMate',
        );
    }
    
    return Image.asset(
      imagePath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => fallbackWidget,
    );
  }

  Widget _buildFallbackMascot(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0xFF70C4DE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF70C4DE),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _nextPage() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _completeOnboarding();
    }
  }

  Future<void> _skipOnboarding() async {
    await _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    try {
      print('🚀 [온보딩] _completeOnboarding 호출됨');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedOnboarding', true);
      print('  💾 온보딩 완료 상태 저장됨');
      
      // 알림 권한 요청을 NotificationPermissionScreen에서 처리하도록 변경
      // (알림 받기 버튼을 눌렀을 때만 요청)
      
      if (mounted) {
        print('  📱 NotificationPermissionScreen으로 이동 시도');
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
              const NotificationPermissionScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
        print('  ✅ Navigator.pushReplacement 완료');
      } else {
        print('  ⚠️ mounted가 false입니다');
      }
    } catch (e) {
      print('❌ 온보딩 완료 처리 중 오류: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String pageNumber;
  final String title;
  final String? subtitle;
  final String imagePath;
  final List<String>? features;

  OnboardingPage({
    required this.pageNumber,
    required this.title,
    this.subtitle,
    required this.imagePath,
    this.features,
  });
}