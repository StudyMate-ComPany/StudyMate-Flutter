import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/notification_service.dart';
import '../home/main_navigation_screen.dart';
import './ready_complete_screen.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({super.key});

  @override
  State<NotificationPermissionScreen> createState() => _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState extends State<NotificationPermissionScreen> {
  
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 배경 그라디언트 - Figma와 동일
          Positioned(
            top: 209,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Color(0xFF70C4DE),
                  ],
                  stops: [0.0, 0.68],
                ),
              ),
            ),
          ),
          
          // 메인 컨텐츠
          SafeArea(
            child: Column(
              children: [
                // 상단 컨텐츠
                Container(
                  margin: const EdgeInsets.only(
                    top: 39, // 95 - 56(status bar)
                    left: 25,
                    right: 25,
                  ),
                  width: 390,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '알림을 허용해주세요',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF70C4DE),
                          fontFamily: 'Pretendard',
                          height: 1.2857,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        '시간 맞춰 살짝 알려드려요',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF555555),
                          fontFamily: 'Pretendard',
                          height: 1.444,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(flex: 1),
                
                // 캐릭터 이미지
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 280,
                    maxHeight: 250,
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/notification_character.png',
                    width: 230,
                    height: 208,
                      fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.alarm,
                          size: 150,
                          color: Color(0xFF70C4DE),
                        ),
                      );
                    },
                  ),
                ).animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                
                const Spacer(flex: 1),
                
                // 알림 카드 스택
                Container(
                  height: 100.13,
                  width: double.infinity,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // 카카오톡 알림 (뒤쪽) - 투명 배경에 흰색 테두리
                      Positioned(
                        top: 0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25.24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                          width: 358,
                          height: 64.26,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.69,
                            vertical: 11.02,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(25.24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.6),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // 카카오 아이콘 - 노란색 배경
                              Container(
                                width: 36,
                                height: 36,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE746).withOpacity(0.52),
                                  borderRadius: BorderRadius.circular(9.64),
                                ),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/images/kakao_logo.svg',
                                    width: 24.5,
                                    height: 22.52,
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xFF3C1E1E),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 9.18),
                              // 텍스트
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        '카카오톡',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          fontFamily: 'Pretendard',
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        '1개의 메세지',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                          fontFamily: 'Pretendard',
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 시간
                              const Text(
                                '9분 전',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                            ],
                          ),
                            ),
                          ),
                        ).animate()
                          .fadeIn(duration: 600.ms, delay: 400.ms)
                          .slideY(begin: 0.1, end: 0),
                      ),
                      
                      // STUDYMATE 알림 (앞쪽) - 투명 배경에 흰색 테두리
                      Positioned(
                        top: 30.13,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(27.5),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                          width: 390,
                          height: 70,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(27.5),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.7),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // STUDYMATE 아이콘
                              Container(
                                width: 40,
                                height: 40,
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.5),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4.5),
                                  child: Image.asset(
                                    'assets/images/studymate_logo.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // 로고가 없을 경우 기본 이미지 사용
                                      return Image.asset(
                                        'assets/images/characters/mascot_profile.png',
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error2, stackTrace2) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF70C4DE).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(4.5),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.school,
                                                size: 24,
                                                color: Color(0xFF70C4DE),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              // 텍스트
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'STUDYMATE',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          fontFamily: 'Pretendard',
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        '요약 알림 도착!',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                          fontFamily: 'Pretendard',
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // 시간
                              const Text(
                                '방금',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                            ],
                          ),
                            ),
                          ),
                        ).animate()
                          .fadeIn(duration: 600.ms, delay: 200.ms)
                          .slideY(begin: -0.2, end: 0, duration: 600.ms, curve: Curves.easeOutBack),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // 하단 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      // 나중에 버튼
                      Expanded(
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TextButton(
                            onPressed: _skipNotification,
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              '나중에',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF555555),
                                fontFamily: 'Pretendard',
                                height: 1.444,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 20),
                      
                      // 알림 받기 버튼
                      Expanded(
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4D9DB5),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ElevatedButton(
                            onPressed: _allowNotification,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              '알림 받기',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: 'Pretendard',
                                height: 1.444,
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
          ),
        ],
      ),
    );
  }

  Future<void> _allowNotification() async {
    try {
      final status = await Permission.notification.request();
      
      if (status.isGranted) {
        print('알림 권한이 허용되었습니다');
        await NotificationService().requestPermission();
      } else if (status.isDenied) {
        print('알림 권한이 거부되었습니다');
      } else if (status.isPermanentlyDenied) {
        print('알림 권한이 영구적으로 거부되었습니다');
      }
      
      await _navigateToLogin();
    } catch (e) {
      print('알림 권한 요청 실패: $e');
      await _navigateToLogin();
    }
  }

  Future<void> _skipNotification() async {
    await _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
            const ReadyCompleteScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }
}