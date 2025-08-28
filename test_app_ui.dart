import 'package:flutter_test/flutter_test.dart';
import 'package:studymate_flutter/main.dart';

/// StudyMate 앱 UI 기능 테스트 시나리오
/// 
/// 테스트 시나리오:
/// 1. 회원가입 화면으로 이동
/// 2. 새로운 계정 생성
/// 3. 로그인 테스트
/// 4. 홈 화면 확인
/// 5. 학습 목표 추가
/// 6. 학습 세션 시작/종료
/// 7. AI 채팅 테스트
/// 8. 통계 확인
void main() {
  group('StudyMate 앱 기능 테스트', () {
    testWidgets('앱 초기 화면은 로그인 화면이어야 함', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // 로그인 화면 요소 확인
      expect(find.text('로그인'), findsOneWidget);
      expect(find.text('회원가입'), findsOneWidget);
    });
    
    testWidgets('회원가입 플로우 테스트', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // 회원가입 버튼 탭
      await tester.tap(find.text('회원가입'));
      await tester.pumpAndSettle();
      
      // 회원가입 폼 필드 확인
      expect(find.text('이름'), findsOneWidget);
      expect(find.text('이메일'), findsOneWidget);
      expect(find.text('비밀번호'), findsOneWidget);
    });
  });
}

/// 테스트 실행 방법:
/// 1. 앱에서 로그인 화면 확인
/// 2. "회원가입" 버튼 클릭
/// 3. 다음 정보로 회원가입:
///    - 이름: 테스트유저
///    - 이메일: testuser2024@studymate.com
///    - 비밀번호: Test1234!
/// 4. 회원가입 후 자동 로그인 확인
/// 5. 홈 화면에서 하단 네비게이션 탭 확인:
///    - 홈, 목표, 스마트 도우미, 통계, 프로필
/// 6. "목표" 탭 클릭 후 "+" 버튼으로 새 목표 추가
/// 7. 스마트 도우미 탭에서 질문 입력 테스트
/// 8. 통계 탭에서 학습 시간 확인