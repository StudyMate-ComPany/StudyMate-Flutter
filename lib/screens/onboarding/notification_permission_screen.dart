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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 하단 파란색 그라데이션 배경
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.65,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFE8F6FA),
                    const Color(0xFFB8E5F3),
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // 상단 헤더 영역
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      // 메인 타이틀과 화살표
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '알림을 허용해주세요',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF70C4DE),
                              fontFamily: 'Pretendard',
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: const Color(0xFF70C4DE),
                            size: 22,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // 서브타이틀
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '시간 맞춰 살짝 알려드려요',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF666666),
                            fontFamily: 'Pretendard',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 메인 컨텐츠 영역
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 마스코트와 알람 이미지
                      Positioned(
                        top: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 260,
                            height: 260,
                            child: Image.asset(
                              'assets/images/sm_alarm.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      
                      // 알림 카드들 - 겹쳐서 배치
                      Positioned(
                        bottom: 190,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 200,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // STUDYMATE 알림 카드 (뒤)
                              Positioned(
                                bottom: 0,
                                child: Transform.translate(
                                  offset: const Offset(0, -5),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width - 70,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // STUDYMATE 아이콘
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF70C4DE).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'S',
                                              style: TextStyle(
                                                color: const Color(0xFF70C4DE),
                                                fontSize: 20,
                                                fontWeight: FontWeight.w800,
                                                fontFamily: 'Pretendard',
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // 텍스트
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
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w700,
                                                      color: Color(0xFF333333),
                                                      fontFamily: 'Pretendard',
                                                    ),
                                                  ),
                                                  Text(
                                                    '방금',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w400,
                                                      color: const Color(0xFF999999),
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
                                                  color: Color(0xFF666666),
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
                              
                              // 카카오톡 알림 카드 (앞)
                              Positioned(
                                top: 0,
                                child: Container(
                                  width: MediaQuery.of(context).size.width - 70,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
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
                                      // 카카오톡 아이콘
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEE500),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'K',
                                            style: TextStyle(
                                              color: Color(0xFF3C1E1E),
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                              fontFamily: 'Pretendard',
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // 텍스트
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
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF333333),
                                                    fontFamily: 'Pretendard',
                                                  ),
                                                ),
                                                Text(
                                                  '9분 전',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    color: const Color(0xFF999999),
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
                                                color: Color(0xFF666666),
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
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 하단 버튼
                Container(
                  padding: const EdgeInsets.all(20),
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
                                blurRadius: 10,
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
                                fontSize: 18,
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
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF70C4DE),
                                const Color(0xFF5DB4D1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF70C4DE).withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
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
                                fontSize: 18,
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