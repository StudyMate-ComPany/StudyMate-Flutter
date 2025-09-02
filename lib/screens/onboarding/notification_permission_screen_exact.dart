import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ready_complete_screen.dart';

class NotificationPermissionScreenExact extends StatelessWidget {
  const NotificationPermissionScreenExact({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    // Figma 디자인 기준 440x956
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / 440;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 그라데이션 배경 (y: 209px부터 시작)
          Positioned(
            top: 209 * scaleFactor,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFF70C4DE),
                  ],
                  stops: [0.0, 0.68],
                ),
              ),
            ),
          ),
          
          // 메인 콘텐츠
          SafeArea(
            child: Column(
              children: [
                // 상태바 영역 (높이: 56px)
                Container(
                  height: 56 * scaleFactor,
                  padding: EdgeInsets.symmetric(horizontal: 18 * scaleFactor),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 시간
                      Text(
                        '9:41',
                        style: TextStyle(
                          fontFamily: 'SF Pro',
                          fontSize: 17 * scaleFactor,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      // 오른쪽 아이콘들
                      Row(
                        children: [
                          Icon(Icons.signal_cellular_4_bar, 
                            size: 16 * scaleFactor, 
                            color: Colors.black),
                          SizedBox(width: 4 * scaleFactor),
                          Icon(Icons.wifi, 
                            size: 16 * scaleFactor, 
                            color: Colors.black),
                          SizedBox(width: 4 * scaleFactor),
                          Icon(Icons.battery_full, 
                            size: 24 * scaleFactor, 
                            color: Colors.black),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 스크롤 가능한 컨텐츠
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: 39 * scaleFactor),
                        
                        // 상단 텍스트와 화살표
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25 * scaleFactor),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 텍스트 부분
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '알림을 허용해주세요',
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 28 * scaleFactor,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF70C4DE),
                                        height: 1.3,
                                      ),
                                    ),
                                    SizedBox(height: 5 * scaleFactor),
                                    Text(
                                      '시간 맞춰 살짝 알려드려요',
                                      style: TextStyle(
                                        fontFamily: 'Pretendard',
                                        fontSize: 18 * scaleFactor,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF555555),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 20 * scaleFactor),
                              // 화살표 아이콘
                              SizedBox(
                                width: 40 * scaleFactor,
                                height: 40 * scaleFactor,
                                child: Center(
                                  child: Transform.rotate(
                                    angle: -math.pi / 4,
                                    child: Icon(
                                      Icons.arrow_upward,
                                      color: const Color(0xFF70C4DE),
                                      size: 24 * scaleFactor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 94 * scaleFactor),
                        
                        // 종 이미지
                        SizedBox(
                          width: 300 * scaleFactor,
                          height: 271 * scaleFactor,
                          child: Image.asset(
                            'assets/images/freepik_notification_bell-57d63d.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        
                        SizedBox(height: 97 * scaleFactor),
                        
                        // 알림 카드들 - 정확한 Figma 스펙으로 구현
                        SizedBox(
                          width: 390 * scaleFactor,
                          height: 100.13 * scaleFactor,
                          child: Stack(
                            children: [
                              // 카카오톡 알림 카드 (뒤) - 정확한 Figma 위치: x:16, y:0
                              Positioned(
                                left: 16 * scaleFactor,
                                top: 0,
                                child: Container(
                                  width: 358 * scaleFactor,
                                  height: 64.26 * scaleFactor,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent, // 투명 배경
                                    borderRadius: BorderRadius.circular(25.24 * scaleFactor),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: 14.69 * scaleFactor,
                                      right: 14.69 * scaleFactor,
                                      top: 11.02 * scaleFactor,
                                      bottom: 11.02 * scaleFactor,
                                    ),
                                    child: Row(
                                      children: [
                                        // 카카오 아이콘 - 반투명 노란색 배경
                                        Container(
                                          width: 42.23 * scaleFactor,
                                          height: 42.23 * scaleFactor,
                                          padding: EdgeInsets.all(5.51 * scaleFactor), // Figma padding
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFE746).withOpacity(0.52), // 반투명 노란색
                                            borderRadius: BorderRadius.circular(9.63 * scaleFactor),
                                          ),
                                          child: Center(
                                            child: Icon(
                                              Icons.chat_bubble_rounded,
                                              color: const Color(0xFF3C1E1E),
                                              size: 18 * scaleFactor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 9.18 * scaleFactor),
                                        // 텍스트 영역 - 고정 너비로 overflow 방지
                                        SizedBox(
                                          width: 88.12 * scaleFactor,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '카카오톡',
                                                style: TextStyle(
                                                  fontFamily: 'Pretendard',
                                                  fontSize: 16 * scaleFactor,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  height: 1.5,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                '1개의 메세지',
                                                style: TextStyle(
                                                  fontFamily: 'Pretendard',
                                                  fontSize: 12 * scaleFactor,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white,
                                                  height: 1.33,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 여백 조정
                                        SizedBox(width: 159.72 * scaleFactor), // Figma gap
                                        // 시간 텍스트
                                        Text(
                                          '9분 전',
                                          style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontSize: 12 * scaleFactor,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                            height: 1.33,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              
                              // 스터디메이트 알림 카드 (앞) - 정확한 Figma 위치: x:0, y:30.13
                              Positioned(
                                left: 0,
                                top: 30.13 * scaleFactor,
                                child: Container(
                                  width: 390 * scaleFactor,
                                  height: 70 * scaleFactor,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent, // 투명 배경
                                    borderRadius: BorderRadius.circular(27.5 * scaleFactor),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: 16 * scaleFactor,
                                      right: 16 * scaleFactor,
                                      top: 12 * scaleFactor,
                                      bottom: 12 * scaleFactor,
                                    ),
                                    child: Row(
                                      children: [
                                        // 스터디메이트 아이콘
                                        Container(
                                          width: 46 * scaleFactor,
                                          height: 46 * scaleFactor,
                                          padding: EdgeInsets.all(6 * scaleFactor),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10.5 * scaleFactor),
                                          ),
                                          child: Image.asset(
                                            'assets/images/studymate_icon.png',
                                            width: 33 * scaleFactor,
                                            height: 33 * scaleFactor,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(width: 10 * scaleFactor),
                                        // 텍스트 영역 - 고정 너비로 overflow 방지
                                        SizedBox(
                                          width: 96 * scaleFactor,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'STUDYMATE',
                                                style: TextStyle(
                                                  fontFamily: 'Pretendard',
                                                  fontSize: 16 * scaleFactor,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  height: 1.5,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                              Text(
                                                '요약 알림 도착!',
                                                style: TextStyle(
                                                  fontFamily: 'Pretendard',
                                                  fontSize: 12 * scaleFactor,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white,
                                                  height: 1.33,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // 여백 조정
                                        SizedBox(width: 174 * scaleFactor), // Figma gap
                                        // 시간 텍스트
                                        Text(
                                          '방금',
                                          style: TextStyle(
                                            fontFamily: 'Pretendard',
                                            fontSize: 12 * scaleFactor,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                            height: 1.33,
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
                        
                        SizedBox(height: 122 * scaleFactor),
                        
                        // 버튼들
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 25 * scaleFactor),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 나중에 버튼
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // 나중에 버튼 - 준비 끝 화면으로 이동
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ReadyCompleteScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 60 * scaleFactor,
                                    margin: EdgeInsets.only(right: 10 * scaleFactor),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15 * scaleFactor),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '나중에',
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: 18 * scaleFactor,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF555555),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // 알림 받기 버튼
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    // 알림 권한 요청
                                    await Permission.notification.request();
                                    
                                    // 권한 요청 후 준비 끝 화면으로 이동
                                    if (context.mounted) {
                                      await Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ReadyCompleteScreen(),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: 60 * scaleFactor,
                                    margin: EdgeInsets.only(left: 10 * scaleFactor),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4D9DB5),
                                      borderRadius: BorderRadius.circular(15 * scaleFactor),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '알림 받기',
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: 18 * scaleFactor,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        SizedBox(height: 50 * scaleFactor),
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