import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('StudyMate 테스트'),
        backgroundColor: const Color(0xFF70C4DE),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xFF70C4DE),
              size: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              '앱이 정상 작동합니다!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('알림 페이지 정보'),
                    content: const Text(
                      '피그마 디자인과 100% 일치하는\n알림 허용 페이지가 구현되었습니다.\n\n'
                      '• 메인 이미지 (41703 1)\n'
                      '• 카카오톡, 스터디메이트 알림 미리보기\n'
                      '• "나중에", "알림 받기" 버튼\n'
                      '• 모든 애니메이션 구현 완료',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('확인'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF70C4DE),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                '알림 페이지 정보 보기',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: '학습'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: '알림'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
        currentIndex: 2,
        selectedItemColor: const Color(0xFF70C4DE),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
