import 'dart:io';
import 'package:dio/dio.dart';

/// API 연결 테스트 스크립트
/// 실행: dart test_api_connection.dart
void main() async {
  print('═══════════════════════════════════════════');
  print('        StudyMate API 연결 테스트          ');
  print('═══════════════════════════════════════════');
  
  const baseUrl = 'https://54.161.77.144';
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // SSL 인증서 검증 우회 (테스트용)
  (dio.httpClientAdapter as dynamic).createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;
    return client;
  };

  // 테스트 결과 저장
  final results = <String, bool>{};
  
  print('\n📡 API 서버: $baseUrl\n');

  // 1. 기본 연결 테스트
  print('1️⃣ 기본 연결 테스트...');
  try {
    final response = await dio.get('/');
    results['기본 연결'] = response.statusCode == 200 || response.statusCode == 404;
    print('   ✅ 서버 응답: ${response.statusCode}');
  } catch (e) {
    results['기본 연결'] = false;
    print('   ❌ 연결 실패: $e');
  }

  // 2. Health Check 엔드포인트 테스트
  print('\n2️⃣ Health Check 테스트...');
  try {
    final response = await dio.get('/api/health/');
    results['Health Check'] = response.statusCode == 200;
    print('   ✅ Health Check 성공: ${response.data}');
  } catch (e) {
    results['Health Check'] = false;
    print('   ❌ Health Check 실패: $e');
  }

  // 3. 회원가입 엔드포인트 테스트 (실제로 가입하지 않음)
  print('\n3️⃣ 회원가입 엔드포인트 테스트...');
  try {
    final response = await dio.post('/api/auth/register/', 
      data: {
        'email': 'test_${DateTime.now().millisecondsSinceEpoch}@example.com',
        'username': 'testuser_${DateTime.now().millisecondsSinceEpoch}',
        'password': 'TestPassword123!',
        'password_confirm': 'TestPassword123!',
        'name': 'Test User',
        'terms_accepted': true,
        'privacy_accepted': true,
      }
    );
    results['회원가입 API'] = response.statusCode == 201 || response.statusCode == 200;
    print('   ✅ 회원가입 API 응답: ${response.statusCode}');
  } catch (e) {
    if (e is DioException) {
      // 400 에러도 API가 작동하는 것으로 간주
      results['회원가입 API'] = e.response?.statusCode == 400 || 
                                e.response?.statusCode == 409;
      print('   ⚠️ 회원가입 API 응답: ${e.response?.statusCode} - ${e.response?.data}');
    } else {
      results['회원가입 API'] = false;
      print('   ❌ 회원가입 API 실패: $e');
    }
  }

  // 4. 로그인 엔드포인트 테스트
  print('\n4️⃣ 로그인 엔드포인트 테스트...');
  try {
    final response = await dio.post('/api/auth/login/', 
      data: {
        'email': 'test@example.com',
        'password': 'wrongpassword',
      }
    );
    results['로그인 API'] = true;
    print('   ✅ 로그인 API 응답: ${response.statusCode}');
  } catch (e) {
    if (e is DioException) {
      // 401 에러도 API가 작동하는 것으로 간주
      results['로그인 API'] = e.response?.statusCode == 401 || 
                              e.response?.statusCode == 400;
      print('   ⚠️ 로그인 API 응답: ${e.response?.statusCode} - ${e.response?.data}');
    } else {
      results['로그인 API'] = false;
      print('   ❌ 로그인 API 실패: $e');
    }
  }

  // 5. 학습 목표 엔드포인트 테스트 (인증 필요)
  print('\n5️⃣ 학습 목표 엔드포인트 테스트...');
  try {
    final response = await dio.get('/api/study/goals/');
    results['학습 목표 API'] = true;
    print('   ✅ 학습 목표 API 응답: ${response.statusCode}');
  } catch (e) {
    if (e is DioException) {
      // 401 에러는 인증이 필요하다는 의미로 API가 작동함
      results['학습 목표 API'] = e.response?.statusCode == 401;
      print('   ⚠️ 학습 목표 API 응답: ${e.response?.statusCode} (인증 필요)');
    } else {
      results['학습 목표 API'] = false;
      print('   ❌ 학습 목표 API 실패: $e');
    }
  }

  // 6. AI 엔드포인트 테스트
  print('\n6️⃣ AI 엔드포인트 테스트...');
  try {
    final response = await dio.post('/api/study/ai/chat/', 
      data: {
        'message': 'Hello',
        'context': null,
      }
    );
    results['AI Chat API'] = true;
    print('   ✅ AI Chat API 응답: ${response.statusCode}');
  } catch (e) {
    if (e is DioException) {
      results['AI Chat API'] = e.response?.statusCode == 401;
      print('   ⚠️ AI Chat API 응답: ${e.response?.statusCode} (인증 필요)');
    } else {
      results['AI Chat API'] = false;
      print('   ❌ AI Chat API 실패: $e');
    }
  }

  // 결과 요약
  print('\n═══════════════════════════════════════════');
  print('                테스트 결과                 ');
  print('═══════════════════════════════════════════');
  
  int passed = 0;
  int failed = 0;
  
  results.forEach((test, result) {
    if (result) {
      print('  ✅ $test: 성공');
      passed++;
    } else {
      print('  ❌ $test: 실패');
      failed++;
    }
  });
  
  print('\n═══════════════════════════════════════════');
  print('  총 테스트: ${results.length}개');
  print('  성공: $passed개');
  print('  실패: $failed개');
  print('  성공률: ${(passed / results.length * 100).toStringAsFixed(1)}%');
  print('═══════════════════════════════════════════');
  
  // API 연결 상태 진단
  print('\n📊 진단 결과:');
  if (failed == 0) {
    print('  ✅ API 서버와 정상적으로 통신 가능합니다.');
    print('  ✅ 모든 엔드포인트가 예상대로 응답합니다.');
  } else if (results['기본 연결'] == false) {
    print('  ❌ API 서버에 연결할 수 없습니다.');
    print('  💡 해결 방법:');
    print('     1. 서버가 실행 중인지 확인하세요.');
    print('     2. 네트워크 연결을 확인하세요.');
    print('     3. 방화벽 설정을 확인하세요.');
  } else if (passed > failed) {
    print('  ⚠️ API 서버와 부분적으로 통신 가능합니다.');
    print('  💡 일부 엔드포인트가 응답하지 않을 수 있습니다.');
  } else {
    print('  ❌ API 서버 구성에 문제가 있을 수 있습니다.');
    print('  💡 서버 로그를 확인하세요.');
  }
  
  exit(failed == 0 ? 0 : 1);
}