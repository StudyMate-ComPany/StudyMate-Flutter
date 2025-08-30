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
    // 상태바 설정
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    
                    // 메인 타이틀
                    const Text(
                      '알림을 허용해주세요',
                      style: TextStyle(
                        fontSize: 28, // Figma 디자인의 정확한 크기
                        fontWeight: FontWeight.w800, // Pretendard 800
                        color: Color(0xFF70C4DE), // rgba(112, 196, 222, 1)
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.2, end: 0),
                    
                    const SizedBox(height: 16),
                    
                    // 서브타이틀
                    const Text(
                      '시간 맞춰 살짝 알려드려요',
                      style: TextStyle(
                        fontSize: 18, // Figma 디자인의 정확한 크기
                        fontWeight: FontWeight.w600, // Pretendard 600
                        color: Color(0xFF555555), // rgba(85, 85, 85, 1)
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                    
                    const SizedBox(height: 60),
                    
                    // 알림 허용 UI - Flutter 위젯으로 구현
                    Container(
                      width: double.infinity,
                      height: 400,
                      child: Column(
                        children: [
                          // 마스코트 캐릭터 (알람 이미지)
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              child: Image.asset(
                                'assets/images/sm_alarm.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF70C4DE),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.notifications_active,
                                      size: 60,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          
                          // 알림 예시 카드들
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                // 카카오톡 알림 예시
                                _buildNotificationCard(
                                  appName: '카카오톡',
                                  message: '1개의 메세지',
                                  time: '9분 전',
                                  color: const Color(0xFFFEE500),
                                  textColor: const Color(0xFF3C1E1E),
                                ),
                                
                                const SizedBox(height: 12),
                                
                                // STUDYMATE 알림 예시
                                _buildNotificationCard(
                                  appName: 'STUDYMATE',
                                  message: '요약 알림 도착!',
                                  time: '방금',
                                  color: const Color(0xFF70C4DE),
                                  textColor: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate()
                      .fadeIn(duration: 500.ms)
                      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                    
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),
          
          // 하단 버튼 영역
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // 나중에 버튼
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _skipNotification,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: const Color(0xFF555555),
                          side: const BorderSide(color: Color(0xFF555555), width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          '나중에',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF555555),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // 알림 받기 버튼
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _allowNotification,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF70C4DE),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '알림 받기',
                          style: TextStyle(
                            fontSize: 18,
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
          ),
        ],
        ),
      ),
    );
  }

  // 알림 허용
  Future<void> _allowNotification() async {
    try {
      // 시스템 알림 권한 요청
      final status = await Permission.notification.request();
      
      if (status.isGranted) {
        // 권한이 허용된 경우
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('알림 권한이 허용되었습니다'),
              backgroundColor: Color(0xFF70C4DE),
              duration: Duration(seconds: 2),
            ),
          );
        }
        
        // NotificationService 초기화
        await NotificationService().requestPermission();
      } else if (status.isDenied) {
        // 권한이 거부된 경우
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('알림 권한이 거부되었습니다. 설정에서 변경할 수 있습니다'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else if (status.isPermanentlyDenied) {
        // 권한이 영구적으로 거부된 경우
        if (mounted) {
          // 설정 화면으로 이동하도록 안내
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('알림 권한 필요'),
                content: const Text('알림을 받으려면 설정에서 권한을 허용해주세요'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _navigateToLogin();
                    },
                    child: const Text('나중에'),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await openAppSettings(); // 설정 화면 열기
                      _navigateToLogin();
                    },
                    child: const Text('설정 열기'),
                  ),
                ],
              );
            },
          );
          return; // 다이얼로그 표시 후 종료
        }
      }
      
      // 완료 후 로그인 화면으로 이동
      await Future.delayed(const Duration(seconds: 1));
      await _navigateToLogin();
    } catch (e) {
      print('알림 권한 요청 실패: $e');
      // 실패해도 다음 화면으로 진행
      await _navigateToLogin();
    }
  }

  // 알림 건너뛰기
  Future<void> _skipNotification() async {
    await _navigateToLogin();
  }

  // 로그인 화면으로 이동
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

  // 알림 카드 위젯 생성
  Widget _buildNotificationCard({
    required String appName,
    required String message,
    required String time,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 앱 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              appName == '카카오톡' ? Icons.chat_bubble : Icons.school,
              color: textColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          
          // 텍스트 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appName,
                      style: TextStyle(
                        fontSize: 16, // Figma 디자인 크기
                        fontWeight: FontWeight.w600, // Pretendard 600
                        color: textColor,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12, // Figma 디자인 크기
                        fontWeight: FontWeight.w400, // Pretendard 400
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 12, // Figma 디자인 크기
                    fontWeight: FontWeight.w400, // Pretendard 400
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}