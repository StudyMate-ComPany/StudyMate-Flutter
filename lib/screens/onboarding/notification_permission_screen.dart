import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/notification_service.dart';
import '../home/main_navigation_screen.dart';
import '../auth/login_screen.dart';

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              const Color(0xFF70C4DE).withOpacity(0.15),
            ],
            stops: const [0.0, 0.68],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 상단 헤더 - 피그마 디자인과 동일하게
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '알림을 허용해주세요',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF70C4DE),
                            fontFamily: 'Pretendard',
                            height: 1.2,
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF70C4DE).withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF70C4DE),
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      '시간 맞춰 살짝 알려드려요',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF545454),
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ],
                ),
              ),
              
              // 중앙 컨텐츠
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 알람 들고 있는 손과 마스코트
                    Positioned(
                      top: 30,
                      child: SizedBox(
                        width: 300,
                        height: 300,
                        child: Image.asset(
                          'assets/images/sm_alarm.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    
                    // 알림 카드들 - Figma 디자인과 동일하게
                    Positioned(
                      bottom: 180,
                      left: 24,
                      right: 24,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // STUDYMATE 알림 (아래쪽, 뒤에 위치)
                          Positioned(
                            top: 50,
                            child: Opacity(
                              opacity: 0.7,
                              child: Container(
                                width: MediaQuery.of(context).size.width - 60,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                    child: Row(
                                  children: [
                                    // STUDYMATE 아이콘
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: const Color(0xFFE8F4F8),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(11),
                                        child: Container(
                                          color: const Color(0xFFE8F4F8),
                                          padding: const EdgeInsets.all(6),
                                          child: Image.asset(
                                            'assets/images/sm_main.png',
                                            fit: BoxFit.contain,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.school,
                                                color: Color(0xFF70C4DE),
                                                size: 24,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'STUDYMATE',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF1A1A1A),
                                                  fontFamily: 'Pretendard',
                                                ),
                                              ),
                                              const Text(
                                                '방금',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xFF8E8E93),
                                                  fontFamily: 'Pretendard',
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          const Text(
                                            '요약 알림 도착!',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF636366),
                                              fontFamily: 'Pretendard',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // 카카오톡 알림 (위쪽, 앞에 위치) - 피그마 디자인과 동일하게
                          Container(
                            width: MediaQuery.of(context).size.width - 48,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.6),
                                width: 2,
                              ),
                            ),
                                child: Row(
                              children: [
                                // 카카오톡 아이콘
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE500),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/icons/kakao_icon.png',
                                      width: 26,
                                      height: 26,
                                      fit: BoxFit.contain,
                                      errorBuilder: (context, error, stackTrace) {
                                        // 카카오 아이콘이 없을 경우 대체 텍스트
                                        return const Text(
                                          'K',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF3C1E1E),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            '카카오톡',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1A1A1A),
                                              fontFamily: 'Pretendard',
                                            ),
                                          ),
                                          const Text(
                                            '9분 전',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: Color(0xFF8E8E93),
                                              fontFamily: 'Pretendard',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        '1개의 메세지',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF636366),
                                          fontFamily: 'Pretendard',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ).animate()
                            .fadeIn(duration: 600.ms, delay: 200.ms)
                            .slideY(begin: -0.2, end: 0, duration: 600.ms, curve: Curves.easeOutBack),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 하단 버튼
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Row(
                  children: [
                    // 나중에 버튼
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: _skipNotification,
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            '나중에',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF666666),
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // 알림 받기 버튼
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF6FBDE0),
                              Color(0xFF5CAED4),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6FBDE0).withOpacity(0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _allowNotification,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            '알림 받기',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: 'Pretendard',
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
            const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }
}