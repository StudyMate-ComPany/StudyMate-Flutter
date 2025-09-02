import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'onboarding/ready_complete_screen.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({Key? key}) : super(key: key);

  @override
  State<NotificationPermissionScreen> createState() => _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState extends State<NotificationPermissionScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _arrowAnimation;
  bool _showNotificationCards = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _arrowAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _showNotificationCards = true;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ReadyCompleteScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 그라데이션 배경 - 피그마: y=209px에서 시작
          Positioned(
            top: 209,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.68],
                  colors: [
                    Colors.white,
                    const Color(0xFF70C4DE),
                  ],
                ),
              ),
            ),
          ),
          // 메인 컨텐츠
          SafeArea(
            child: Column(
              children: [
                // 상단 간격
                const SizedBox(height: 39), // 95 - 56(SafeArea) = 39
                // 메인 컨텐츠 패딩
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      children: [
                        // 타이틀 섹션
                        Container(
                          width: 380,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 타이틀과 서브타이틀
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '알림을 허용해주세요',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w800,
                                      fontSize: 28,
                                      height: 36/28, // line-height
                                      color: Color(0xFF70C4DE),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    '시간 맞춰 살짝 알려드려요',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      height: 26/18, // line-height
                                      color: Color(0xFF555555),
                                    ),
                                  ),
                                ],
                              ),
                              // 화살표 아이콘
                              AnimatedBuilder(
                                animation: _arrowAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(_arrowAnimation.value, 0),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.arrow_forward,
                                        color: const Color(0xFF70C4DE),
                                        size: 30,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 94),
                        
                        // 메인 이미지
                        Container(
                          width: 300,
                          height: 271,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/notification-main.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 97),
                        
                        // 알림 카드들
                        AnimatedOpacity(
                          opacity: _showNotificationCards ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 800),
                          child: Column(
                            children: [
                              // 카카오톡 알림 카드
                              Container(
                                width: 358,
                                height: 64.26,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14.69,
                                  vertical: 11.02,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25.24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // 카카오 아이콘 배경
                                    Container(
                                      width: 42.23,
                                      height: 42.23,
                                      padding: const EdgeInsets.all(5.51),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFE746).withOpacity(0.52),
                                        borderRadius: BorderRadius.circular(9.64),
                                      ),
                                      child: Center(
                                        child: Image.asset(
                                          'assets/images/kakao-icon.png',
                                          width: 24.5,
                                          height: 22.52,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(
                                              Icons.message,
                                              size: 20,
                                              color: Color(0xFF3C1E1E),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 9.18),
                                    // 텍스트 내용
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            '카카오톡',
                                            style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              height: 24/16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const Text(
                                            '1개의 메세지',
                                            style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              height: 16/12,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // 시간
                                    const Text(
                                      '9분 전',
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        height: 16/12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30.13),
                              
                              // 스터디메이트 알림 카드
                              Container(
                                width: 390,
                                height: 70,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(27.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // 스터디메이트 아이콘 배경
                                    Container(
                                      width: 46,
                                      height: 46,
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10.5),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                          width: 1,
                                        ),
                                      ),
                                      child: Image.asset(
                                        'assets/images/studymate-icon.png',
                                        width: 33,
                                        height: 33,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Icon(
                                            Icons.school,
                                            size: 28,
                                            color: Color(0xFF70C4DE),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // 텍스트 내용
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            'STUDYMATE',
                                            style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              height: 24/16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const Text(
                                            '요약 알림 도착!',
                                            style: TextStyle(
                                              fontFamily: 'Pretendard',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              height: 16/12,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // 시간
                                    const Text(
                                      '방금',
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        height: 16/12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // 하단 버튼들
                        Padding(
                          padding: const EdgeInsets.only(bottom: 122), // 피그마 위치에 맞게
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 나중에 버튼
                              Container(
                                width: 180,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ReadyCompleteScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    '나중에',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      height: 26/18,
                                      color: Color(0xFF555555),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              // 알림 받기 버튼
                              Container(
                                width: 180,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4D9DB5),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: TextButton(
                                  onPressed: _requestNotificationPermission,
                                  child: const Text(
                                    '알림 받기',
                                    style: TextStyle(
                                      fontFamily: 'Pretendard',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      height: 26/18,
                                      color: Colors.white,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}