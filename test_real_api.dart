import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

void main() async {
  print('🔄 Testing StudyMate API Connection...');
  print('=' * 50);
  
  final dio = Dio(BaseOptions(
    baseUrl: 'https://54.161.77.144',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
  
  // SSL 인증서 검증 우회 (개발 환경)
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;
    return client;
  };
  
  // 요청/응답 로깅
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    error: true,
  ));
  
  try {
    // 1. Health Check
    print('\n📍 Testing Health Check...');
    try {
      final health = await dio.get('/api/');
      print('✅ API is accessible');
    } catch (e) {
      print('⚠️ Health check failed: $e');
    }
    
    // 2. Register Test User
    print('\n📍 Testing Registration...');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final testEmail = 'test_$timestamp@studymate.com';
    final testUsername = 'testuser$timestamp';
    
    try {
      final registerResponse = await dio.post('/api/auth/register/', data: {
        'email': testEmail,
        'username': testUsername,
        'password': 'TestPass123!',
        'password_confirm': 'TestPass123!',
        'name': 'Test User',
        'profile_name': 'Test User',
        'terms_accepted': true,
        'privacy_accepted': true,
      });
      
      print('✅ Registration successful!');
      print('   User ID: ${registerResponse.data['user']['id']}');
      print('   Email: ${registerResponse.data['user']['email']}');
      final regToken = registerResponse.data['token'];
      print('   Token: ${regToken != null ? '${regToken.toString().substring(0, regToken.toString().length > 20 ? 20 : regToken.toString().length)}...' : 'No token'}');
      
      final token = registerResponse.data['token'];
      
      // 3. Test Login
      print('\n📍 Testing Login...');
      final loginResponse = await dio.post('/api/auth/login/', data: {
        'email': testEmail,
        'password': 'TestPass123!',
      });
      
      print('✅ Login successful!');
      final loginToken = loginResponse.data['token'];
      print('   Token: ${loginToken != null ? '${loginToken.toString().substring(0, loginToken.toString().length > 20 ? 20 : loginToken.toString().length)}...' : 'No token'}');
      
      // 4. Test Authenticated Request
      print('\n📍 Testing Authenticated Request...');
      dio.options.headers['Authorization'] = 'Token $token';
      
      try {
        final userResponse = await dio.get('/api/users/me/');
        print('✅ User profile retrieved!');
        print('   User: ${userResponse.data}');
      } catch (e) {
        print('⚠️ User profile endpoint not available: $e');
      }
      
      // 5. Test Logout
      print('\n📍 Testing Logout...');
      try {
        final logoutResponse = await dio.post('/api/auth/logout/');
        print('✅ Logout successful!');
      } catch (e) {
        print('⚠️ Logout failed: $e');
      }
      
    } catch (e) {
      print('❌ Registration/Login failed: $e');
    }
    
    // 6. Test with existing user
    print('\n📍 Testing with existing credentials...');
    try {
      final loginResponse = await dio.post('/api/auth/login/', data: {
        'email': 'test@studymate.com',
        'password': 'password123',
      });
      
      print('✅ Existing user login successful!');
      
    } catch (e) {
      print('❌ Existing user login failed: $e');
      print('   This is expected if the user doesn\'t exist');
    }
    
  } catch (e) {
    print('\n❌ Error: $e');
  }
  
  print('\n' + '=' * 50);
  print('✅ API Connection Test Complete!');
  print('\nNext Steps:');
  print('1. Ensure the API server is running at https://54.161.77.144');
  print('2. Check that all required endpoints are implemented');
  print('3. Update API service to handle missing endpoints gracefully');
}