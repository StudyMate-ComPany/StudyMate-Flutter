import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../auth/figma_login_screen.dart';
import '../../providers/auth_provider.dart';

class GuestMainScreen extends StatefulWidget {
  const GuestMainScreen({super.key});

  @override
  State<GuestMainScreen> createState() => _GuestMainScreenState();
}

class _GuestMainScreenState extends State<GuestMainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    
    // AuthProvider로 로그인 상태 확인
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isAuthenticated;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 상태바 영역 (64px)
          Container(
            height: 64,
            color: Colors.white,
          ),
          
          // 상단 헤더 - STUDYMATE 로고와 알림 (80px)
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // STUDYMATE 로고
                  const Text(
                    'STUDYMATE',
                    style: TextStyle(
                      fontFamily: 'ChangwonDangamAsac',
                      fontSize: 26.69,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF70C4DE),
                      height: 1.2,
                    ),
                  ),
                  // 알림 아이콘과 임시 로그아웃 버튼
                  Row(
                    children: [
                      // 임시 로그아웃 버튼 (로그인된 경우에만 표시)
                      if (isLoggedIn) 
                        Container(
                          width: 36,
                          height: 36,
                          margin: const EdgeInsets.only(right: 8),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.logout,
                              size: 24,
                              color: Colors.red,
                            ),
                            onPressed: () async {
                              // 로그아웃 처리
                              await authProvider.logout();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('로그아웃되었습니다'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      // 알림 아이콘
                      Container(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.notifications_outlined,
                            size: 24,
                            color: Color(0xFF70C4DE),
                          ),
                          onPressed: () {
                            if (isLoggedIn) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('알림이 없습니다'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('로그인이 필요한 서비스입니다'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // 메인 콘텐츠 영역
          Expanded(
            child: Stack(
              children: [
                // 회색 박스 - 화면 너비에 맞춰 조정
                Positioned(
                  left: 20,
                  right: 20,
                  top: 10,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                
                // 캐릭터와 메시지 - 회색 박스 내부 중앙 (로그인 상태에 따라 다른 메시지)
                Positioned(
                  left: 40,
                  right: 40,
                  top: 40,
                  child: Row(
                    children: [
                      // 캐릭터 이미지 (70x70)
                      Container(
                        width: 70,
                        height: 70,
                        child: Image.asset(
                          'assets/images/main_character.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Color(0xFF70C4DE),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      
                      // 메시지 텍스트
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLoggedIn ? '환영합니다! 학습을 시작해볼까요?' : '아직 로그인을 하지 않으셨네요!',
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                height: 1.444,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              isLoggedIn 
                                ? '스터디메이트와 함께 효율적인 학습을 시작하세요' 
                                : '로그인 후 스터디메이트와 함께 학습하세요',
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.black,
                                height: 1.231,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 로그인/학습 시작 버튼 - 회색 박스 아래
                Positioned(
                  left: 30,
                  right: 30,
                  top: 140,
                  child: GestureDetector(
                    onTap: () {
                      if (isLoggedIn) {
                        // 로그인된 사용자는 학습 화면으로 (예: 퀴즈, 포모도로 등)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('학습 기능을 준비 중입니다'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      } else {
                        // 로그인 안 한 사용자는 로그인 화면으로
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FigmaLoginScreen(),
                          ),
                        );
                      }
                    },
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: isLoggedIn ? const Color(0xFF70C4DE) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isLoggedIn ? const Color(0xFF70C4DE) : const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          isLoggedIn ? '학습 시작하기' : '로그인 또는 회원가입 하기',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isLoggedIn ? Colors.white : const Color(0xFF555555),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // 하단 네비게이션 바 - 피그마 (높이: 95px)
          Container(
            height: 95,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFCCCCCC).withOpacity(0.3),
                  offset: const Offset(0, -2),
                  blurRadius: 10,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItemWithCustomIcon(0, _buildHomeIcon, '홈'),
                  _buildNavItemWithCustomIcon(1, _buildQuizIcon, '퀴즈'), 
                  _buildNavItemWithCustomIcon(2, _buildSummaryIcon, '요약'),
                  _buildNavItemWithCustomIcon(3, _buildMyPageIcon, '마이페이지'),
                  _buildNavItemWithCustomIcon(4, _buildStatsIcon, '통계'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItemWithCustomIcon(int index, Widget Function(bool) iconBuilder, String label) {
    final isSelected = _selectedIndex == index;
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isAuthenticated;
    
    return GestureDetector(
      onTap: () {
        if (index != 0 && !isLoggedIn) {
          // 로그인하지 않은 경우 탭 선택 안 함
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('로그인이 필요한 서비스입니다'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // 홈 탭이거나 로그인된 경우에만 탭 선택
          setState(() {
            _selectedIndex = index;
          });
          
          if (index != 0 && isLoggedIn) {
            // 로그인된 사용자는 해당 기능 사용 가능
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label 기능을 준비 중입니다'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            iconBuilder(isSelected),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? const Color(0xFF70C4DE) : const Color(0xFFB8B8B8),
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 홈 아이콘
  Widget _buildHomeIcon(bool isSelected) {
    final color = isSelected ? const Color(0xFF70C4DE) : const Color(0xFFB8B8B8);
    return SvgPicture.asset(
      'assets/icons/nav_home_new.svg',
      width: 32,
      height: 32,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  // 퀴즈 아이콘
  Widget _buildQuizIcon(bool isSelected) {
    final color = isSelected ? const Color(0xFF70C4DE) : const Color(0xFFB8B8B8);
    return SvgPicture.asset(
      'assets/icons/nav_quiz_new.svg',
      width: 32,
      height: 32,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  // 요약 아이콘
  Widget _buildSummaryIcon(bool isSelected) {
    final color = isSelected ? const Color(0xFF70C4DE) : const Color(0xFFB8B8B8);
    return SvgPicture.asset(
      'assets/icons/nav_summary_new.svg',
      width: 32,
      height: 32,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  // 마이페이지 아이콘
  Widget _buildMyPageIcon(bool isSelected) {
    final color = isSelected ? const Color(0xFF70C4DE) : const Color(0xFFB8B8B8);
    return SvgPicture.asset(
      'assets/icons/nav_mypage_new.svg',
      width: 32,
      height: 32,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  // 통계 아이콘
  Widget _buildStatsIcon(bool isSelected) {
    final color = isSelected ? const Color(0xFF70C4DE) : const Color(0xFFB8B8B8);
    return SvgPicture.asset(
      'assets/icons/nav_statistics_new.svg',
      width: 32,
      height: 32,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}