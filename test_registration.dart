import 'dart:io';

void main() async {
  print('🧪 회원가입 자동 로그인 테스트 시작');
  
  // 테스트 데이터 준비
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final testEmail = 'test$timestamp@example.com';
  final testName = 'TestUser$timestamp';
  final testUsername = 'user$timestamp';
  final testPassword = 'Test1234!';
  
  print('📝 테스트 계정 정보:');
  print('  - 이메일: $testEmail');
  print('  - 이름: $testName');
  print('  - 사용자명: $testUsername');
  print('  - 비밀번호: $testPassword');
  
  // ADB를 사용한 UI 자동화
  print('\n🔄 앱 재시작...');
  await runCommand('adb shell am force-stop com.studymate.studymate_flutter');
  await Future.delayed(Duration(seconds: 1));
  await runCommand('adb shell am start -n com.studymate.studymate_flutter/com.studymate.studymate_flutter.MainActivity');
  await Future.delayed(Duration(seconds: 3));
  
  print('\n📱 회원가입 화면으로 이동...');
  // "회원가입" 버튼 클릭 (하단에 위치)
  await runCommand('adb shell input tap 360 1200');
  await Future.delayed(Duration(seconds: 2));
  
  print('\n✏️ 회원가입 정보 입력...');
  
  // 이름 필드 클릭 및 입력
  print('  - 이름 입력');
  await runCommand('adb shell input tap 360 400');
  await Future.delayed(Duration(milliseconds: 500));
  await runCommand('adb shell input text "$testName"');
  await Future.delayed(Duration(milliseconds: 500));
  
  // 사용자명 필드로 이동
  print('  - 사용자명 입력');
  await runCommand('adb shell input keyevent 61'); // Tab
  await Future.delayed(Duration(milliseconds: 500));
  await runCommand('adb shell input text "$testUsername"');
  await Future.delayed(Duration(milliseconds: 500));
  
  // 이메일 필드로 이동
  print('  - 이메일 입력');
  await runCommand('adb shell input keyevent 61'); // Tab
  await Future.delayed(Duration(milliseconds: 500));
  await runCommand('adb shell input text "$testEmail"');
  await Future.delayed(Duration(milliseconds: 500));
  
  // 비밀번호 필드로 이동
  print('  - 비밀번호 입력');
  await runCommand('adb shell input keyevent 61'); // Tab
  await Future.delayed(Duration(milliseconds: 500));
  await runCommand('adb shell input text "$testPassword"');
  await Future.delayed(Duration(milliseconds: 500));
  
  // 비밀번호 확인 필드로 이동
  print('  - 비밀번호 확인 입력');
  await runCommand('adb shell input keyevent 61'); // Tab
  await Future.delayed(Duration(milliseconds: 500));
  await runCommand('adb shell input text "$testPassword"');
  await Future.delayed(Duration(milliseconds: 500));
  
  // 키보드 숨기기
  await runCommand('adb shell input keyevent 4'); // Back
  await Future.delayed(Duration(seconds: 1));
  
  // 스크롤 다운하여 약관 보이게 하기
  print('\n📜 약관 동의...');
  await runCommand('adb shell input swipe 360 800 360 300');
  await Future.delayed(Duration(seconds: 1));
  
  // 이용약관 동의 체크박스 클릭
  print('  - 이용약관 동의');
  await runCommand('adb shell input tap 360 900');
  await Future.delayed(Duration(milliseconds: 500));
  
  // 개인정보처리방침 동의 체크박스 클릭
  print('  - 개인정보처리방침 동의');
  await runCommand('adb shell input tap 360 1000');
  await Future.delayed(Duration(milliseconds: 500));
  
  // "가입하기" 버튼 클릭
  print('\n🚀 회원가입 진행...');
  await runCommand('adb shell input tap 360 1150');
  
  // 회원가입 처리 대기
  print('\n⏳ 서버 응답 대기 중...');
  await Future.delayed(Duration(seconds: 5));
  
  // 화면 확인
  print('\n📱 현재 화면 확인...');
  await runCommand('adb shell dumpsys window | grep mCurrentFocus');
  
  // 스크린샷 캡처
  print('\n📸 스크린샷 저장...');
  await runCommand('adb shell screencap -p /sdcard/registration_result.png');
  await runCommand('adb pull /sdcard/registration_result.png /tmp/registration_result.png');
  
  print('\n✅ 테스트 완료!');
  print('📍 스크린샷 위치: /tmp/registration_result.png');
  print('\n🔍 결과 확인:');
  print('  - 홈 화면이 표시되면: 자동 로그인 성공 ✓');
  print('  - 회원가입 화면이 유지되면: 자동 로그인 실패 ✗');
}

Future<void> runCommand(String command) async {
  final result = await Process.run('sh', ['-c', command]);
  if (result.exitCode != 0 && result.stderr.toString().isNotEmpty) {
    print('⚠️ Warning: ${result.stderr}');
  }
}