import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';

class SocialLoginService {
  // 백엔드 서버 URL
  static const String baseUrl = 'http://54.161.77.144';
  
  // 소셜 로그인 공통 처리
  static Future<bool> loginWithProvider({
    required String provider,
    required Map<String, dynamic> userInfo,
    required AuthProvider authProvider,
  }) async {
    try {
      debugPrint('🌐 [SocialAuth] Starting $provider login...');
      debugPrint('👤 [SocialAuth] User info: $userInfo');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/social/login/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'provider': provider,
          'access_token': userInfo['access_token'],
          'id': userInfo['id'],
          'email': userInfo['email'] ?? '',
          'name': userInfo['name'] ?? '',
          'profileImage': userInfo['profileImage'] ?? '',
        }),
      );
      
      debugPrint('📍 [SocialAuth] Response status: ${response.statusCode}');
      debugPrint('📍 [SocialAuth] Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // AuthProvider를 통해 로그인 처리
        await authProvider.loginWithSocialToken(
          token: data['token'],
          user: data['user'],
        );
        
        debugPrint('✅ [SocialAuth] Login successful!');
        return true;
      } else {
        debugPrint('❌ [SocialAuth] Login failed: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ [SocialAuth] Error: $e');
      return false;
    }
  }
}