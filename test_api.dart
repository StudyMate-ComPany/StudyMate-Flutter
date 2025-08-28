import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

void main() async {
  print('🚀 StudyMate API Connection Test');
  print('=' * 50);
  
  final dio = Dio(BaseOptions(
    baseUrl: 'https://54.161.77.144',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Configure SSL
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;
    return client;
  };

  // Add logging interceptor
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    error: true,
  ));

  // Test endpoints
  final tests = [
    {'name': 'Root endpoint', 'method': 'GET', 'path': '/'},
    {'name': 'Health check', 'method': 'GET', 'path': '/api/health/'},
    {'name': 'Auth check', 'method': 'GET', 'path': '/api/auth/'},
    {'name': 'Goals endpoint', 'method': 'GET', 'path': '/api/study/goals/'},
    {'name': 'Sessions endpoint', 'method': 'GET', 'path': '/api/study/sessions/'},
  ];

  int passed = 0;
  int failed = 0;
  
  for (final test in tests) {
    print('\n📍 Testing: ${test['name']}');
    print('   Method: ${test['method']} ${test['path']}');
    
    try {
      Response response;
      if (test['method'] == 'GET') {
        response = await dio.get(test['path'] as String);
      } else {
        response = await dio.post(test['path'] as String);
      }
      
      print('   ✅ Status: ${response.statusCode}');
      print('   📦 Response: ${response.data.toString().substring(0, 100 < response.data.toString().length ? 100 : response.data.toString().length)}...');
      passed++;
    } catch (e) {
      if (e is DioException) {
        print('   ❌ Error: ${e.response?.statusCode} - ${e.message}');
        if (e.response != null) {
          print('   📦 Response: ${e.response?.data}');
        }
      } else {
        print('   ❌ Error: $e');
      }
      failed++;
    }
  }

  print('\n' + '=' * 50);
  print('📊 Test Results:');
  print('   ✅ Passed: $passed');
  print('   ❌ Failed: $failed');
  print('   📈 Success Rate: ${(passed / (passed + failed) * 100).toStringAsFixed(1)}%');
  
  // Test authentication
  print('\n🔐 Testing Authentication...');
  try {
    final authResponse = await dio.post('/api/auth/login/', data: {
      'email': 'test@example.com',
      'password': 'Test123!@#',
    });
    
    print('   ✅ Login successful!');
    print('   🎫 Token: ${authResponse.data['token']?.substring(0, 20)}...');
    
    // Test authenticated request
    if (authResponse.data['token'] != null) {
      dio.options.headers['Authorization'] = 'Token ${authResponse.data['token']}';
      
      print('\n🔒 Testing Authenticated Requests...');
      try {
        final profileResponse = await dio.get('/api/user/profile/');
        print('   ✅ Profile accessed: ${profileResponse.data}');
      } catch (e) {
        print('   ❌ Profile access failed: $e');
      }
      
      try {
        final goalsResponse = await dio.get('/api/study/goals/');
        print('   ✅ Goals accessed: ${goalsResponse.data}');
      } catch (e) {
        print('   ❌ Goals access failed: $e');
      }
    }
  } catch (e) {
    print('   ❌ Login failed: $e');
  }
  
  exit(0);
}