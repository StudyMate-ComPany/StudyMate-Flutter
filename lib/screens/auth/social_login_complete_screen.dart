import 'package:flutter/material.dart';
import 'dart:async';
import '../home/guest_main_screen.dart';

class SocialLoginCompleteScreen extends StatefulWidget {
  final String provider;
  
  const SocialLoginCompleteScreen({
    super.key,
    required this.provider,
  });

  @override
  State<SocialLoginCompleteScreen> createState() => _SocialLoginCompleteScreenState();
}

class _SocialLoginCompleteScreenState extends State<SocialLoginCompleteScreen> {
  @override
  void initState() {
    super.initState();
    // 2초 후 자동으로 메인 화면으로 이동
    Timer(const Duration(seconds: 2), () {
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

  String get providerName {
    switch (widget.provider.toLowerCase()) {
      case 'kakao':
        return '카카오';
      case 'naver':
        return '네이버';
      case 'google':
        return '구글';
      case 'apple':
        return '애플';
      default:
        return widget.provider;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6B314), // 노란색 배경
      body: SafeArea(
        child: Column(
          children: [
            // 상단 여백
            const SizedBox(height: 134),
            
            // 중앙 컨텐츠
            Expanded(
              child: Column(
                children: [
                  // 로그인 완료 텍스트
                  Text(
                    providerName,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.286,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '로그인 완료!',
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.286,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // 구분선
                  Container(
                    width: 100,
                    height: 1,
                    color: Colors.white,
                  ),
                  
                  const SizedBox(height: 152),
                  
                  // 캐릭터 이미지
                  Container(
                    width: 200,
                    height: 242,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/mascot_welcome.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 하단 STUDYMATE 로고
            const Padding(
              padding: EdgeInsets.only(bottom: 50),
              child: Text(
                'STUDYMATE',
                style: TextStyle(
                  fontFamily: 'ChangwonDangamAsac',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.125,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}