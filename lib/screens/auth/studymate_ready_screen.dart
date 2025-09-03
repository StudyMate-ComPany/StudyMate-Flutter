import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home/guest_main_screen.dart';
import '../../providers/auth_provider.dart';

class StudyMateReadyScreen extends StatefulWidget {
  const StudyMateReadyScreen({super.key});

  @override
  State<StudyMateReadyScreen> createState() => _StudyMateReadyScreenState();
}

class _StudyMateReadyScreenState extends State<StudyMateReadyScreen> {
  @override
  void initState() {
    super.initState();
    // 3초 후 게스트 메인 화면으로 이동 (일단 모든 사용자를 게스트 화면으로)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const GuestMainScreen(),
          ),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF70C4DE),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 스타 아이콘 (피그마 디자인에 맞춤)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF70C4DE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 큰 별
                  const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 80,
                  ),
                  // 작은 별들
                  Positioned(
                    top: 10,
                    right: 15,
                    child: Icon(
                      Icons.star,
                      color: Colors.white.withOpacity(0.8),
                      size: 24,
                    ),
                  ),
                  Positioned(
                    bottom: 15,
                    left: 10,
                    child: Icon(
                      Icons.star,
                      color: Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // 메인 텍스트
            const Text(
              '스마트 학습 플래너와',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                height: 1.4,
              ),
            ),
            const Text(
              '시작해보세요!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            // 설명 텍스트
            Text(
              '당신의 학습을 맞춤주시면\n맞춤형 학습 플랜을 만들어드려요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 60),
            // 학습 플래너 만들기 버튼
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // 게스트 메인 화면으로 이동
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GuestMainScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.rocket_launch,
                        color: Color(0xFF70C4DE),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '학습 플래너 만들기',
                        style: TextStyle(
                          color: Color(0xFF1E1E1E),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}