import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/studymate_theme.dart';
import '../home/main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: '알림을 허용해주세요',
      subtitle: '시간 맞춰 살짝 알려드려요',
      imagePath: 'assets/images/characters/sm_alarm.png',
      character: 'assets/images/characters/sm_main.png',
    ),
    OnboardingPage(
      title: '메이트와 루틴해요',
      subtitle: '알림으로 매일 15분',
      imagePath: 'assets/images/characters/sm_study.png',
      checkItems: ['09시 • 12시 • 21시 알림', '매일 같은 시간', '연속일 표시'],
    ),
    OnboardingPage(
      title: '핵심만 쏙,\n메이트와 요약해요',
      imagePath: 'assets/images/characters/sm_glasses.png',
      checkItems: ['난이도 맞춤', '저장, 공유 가능', '하루 3회 무료'],
    ),
    OnboardingPage(
      title: '메이트와 퀴즈해요',
      subtitle: '반복으로 실력 상승',
      imagePath: 'assets/images/characters/sm_quiz_win.png',
      checkItems: ['다른 메이트와 함께 퀴즈 대결', '정답률 조절', '오답노트 제공'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudyMateTheme.lightBlue,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 앱바 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // STUDYMATE 로고
                  Text(
                    'STUDYMATE',
                    style: StudyMateTheme.headingMedium.copyWith(
                      color: StudyMateTheme.primaryBlue,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  // 건너뛰기 버튼
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: () async {
                        // 온보딩 완료 저장
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('hasCompletedOnboarding', true);
                        
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainNavigationScreen(),
                            ),
                          );
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            '건너뛰기',
                            style: StudyMateTheme.bodyMedium.copyWith(
                              color: StudyMateTheme.grayText,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: StudyMateTheme.grayText,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            
            // 페이지 뷰
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 페이지 인디케이터
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? StudyMateTheme.primaryBlue
                              : StudyMateTheme.primaryBlue.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).animate().scale(
                        duration: 300.ms,
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // 다음/시작하기 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          // 온보딩 완료 저장
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('hasCompletedOnboarding', true);
                          
                          if (mounted) {
                            // 메인 화면으로 이동
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainNavigationScreen(),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StudyMateTheme.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1 ? '다음' : '시작하기',
                        style: StudyMateTheme.buttonText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, int index) {
    if (index == 0) {
      // 첫 번째 페이지 - 알림 허용
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            page.title,
            style: StudyMateTheme.headingLarge.copyWith(
              color: StudyMateTheme.primaryBlue,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),
          const SizedBox(height: 16),
          Text(
            page.subtitle!,
            style: StudyMateTheme.bodyLarge.copyWith(
              color: StudyMateTheme.darkNavy,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
          const SizedBox(height: 60),
          
          // 캐릭터와 알람 이미지
          Stack(
            alignment: Alignment.center,
            children: [
              // 알람 이미지
              Image.asset(
                'assets/images/characters/sm_alarm.png',
                width: 120,
                height: 120,
              ).animate()
                .scale(delay: 400.ms, duration: 600.ms)
                .then()
                .shake(duration: 500.ms, hz: 2),
              // 캐릭터
              Positioned(
                bottom: -30,
                right: -30,
                child: Image.asset(
                  'assets/images/characters/sm_main.png',
                  width: 180,
                  height: 180,
                ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
              ),
            ],
          ),
          const SizedBox(height: 40),
          
          // 알림 설정 카드
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: StudyMateTheme.cardDecoration,
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: StudyMateTheme.kakaoYellow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      '카카오톡',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STUDYMATE',
                        style: StudyMateTheme.labelText.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '요약 알림 도착!',
                        style: StudyMateTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(
                  '9분 전',
                  style: StudyMateTheme.bodySmall.copyWith(
                    color: StudyMateTheme.grayText,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 800.ms, duration: 500.ms).slideY(begin: 0.2, end: 0),
        ],
      );
    } else {
      // 나머지 페이지들
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 캐릭터 이미지
            Image.asset(
              page.imagePath,
              width: 240,
              height: 240,
            ).animate()
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
            const SizedBox(height: 40),
            
            // 타이틀
            Text(
              page.title,
              style: StudyMateTheme.headingMedium.copyWith(
                color: StudyMateTheme.primaryBlue,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
            
            if (page.subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                page.subtitle!,
                style: StudyMateTheme.bodyLarge.copyWith(
                  color: StudyMateTheme.darkNavy,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
            ],
            
            if (page.checkItems != null) ...[
              const SizedBox(height: 32),
              ...page.checkItems!.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: StudyMateTheme.primaryBlue.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: StudyMateTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: StudyMateTheme.bodyMedium.copyWith(
                            color: StudyMateTheme.darkNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate()
                  .fadeIn(delay: (500 + index * 100).ms, duration: 500.ms)
                  .slideX(begin: -0.2, end: 0);
              }).toList(),
            ],
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String title;
  final String? subtitle;
  final String imagePath;
  final String? character;
  final List<String>? checkItems;

  OnboardingPage({
    required this.title,
    this.subtitle,
    required this.imagePath,
    this.character,
    this.checkItems,
  });
}