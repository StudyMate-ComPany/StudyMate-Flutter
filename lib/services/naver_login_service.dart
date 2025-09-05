import 'package:flutter/material.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';

/// 네이버 로그인 SDK를 사용한 완벽한 구현
class NaverLoginService {
  static const String _clientId = '3GhqSVoT4bk045ohLmcW';
  static const String _clientSecret = 'jCdAcwX_M3';
  static const String _clientName = 'StudyMate';
  
  // 로그인 진행 중 플래그
  static bool _isLoginInProgress = false;
  static DateTime? _lastLoginAttempt;
  
  /// SDK 초기화
  Future<void> initialize() async {
    try {
      await FlutterNaverLogin.initSdk(
        clientId: _clientId,
        clientSecret: _clientSecret,
        clientName: _clientName,
      );
      debugPrint('✅ 네이버 로그인 SDK 초기화 성공');
    } catch (e) {
      debugPrint('❌ 네이버 로그인 SDK 초기화 실패: $e');
    }
  }
  
  /// 네이버 로그인
  Future<Map<String, dynamic>?> signIn() async {
    // 중복 호출 방지
    if (_isLoginInProgress) {
      debugPrint('⚠️ 네이버 로그인이 이미 진행 중입니다');
      return null;
    }
    
    // 너무 빠른 연속 호출 방지 (1초 이내)
    if (_lastLoginAttempt != null) {
      final timeDiff = DateTime.now().difference(_lastLoginAttempt!);
      if (timeDiff.inMilliseconds < 1000) {
        debugPrint('⚠️ 너무 빠른 연속 호출입니다');
        return null;
      }
    }
    
    try {
      _isLoginInProgress = true;
      _lastLoginAttempt = DateTime.now();
      
      // SDK 초기화
      await initialize();
      
      // 기존 로그인 상태 확인 후 로그아웃
      await FlutterNaverLogin.logOut();
      
      // 로그인 시도
      final NaverLoginResult result = await FlutterNaverLogin.logIn();
      
      if (result.status == NaverLoginStatus.loggedIn) {
        debugPrint('✅ 네이버 로그인 성공');
        
        // 사용자 정보 반환
        final account = result.account;
        return {
          'id': account.id,
          'email': account.email,
          'name': account.name,
          'nickname': account.nickname ?? '',
          'profileImage': account.profileImage ?? '',
          'gender': account.gender ?? '',
          'age': account.age ?? '',
          'birthday': account.birthday ?? '',
          'birthyear': account.birthyear ?? '',
          'mobile': account.mobile ?? '',
          'provider': 'naver',
          'access_token': result.accessToken?.accessToken ?? '',
          'refresh_token': result.accessToken?.refreshToken ?? '',
          'expires_at': result.accessToken?.expiresAt ?? '',
        };
      } else if (result.status == NaverLoginStatus.cancelledByUser) {
        debugPrint('❌ 사용자가 네이버 로그인을 취소했습니다');
        return null;
      } else {
        debugPrint('❌ 네이버 로그인 실패: ${result.errorMessage}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ 네이버 로그인 예외 발생: $e');
      return null;
    } finally {
      _isLoginInProgress = false;
    }
  }
  
  /// 로그아웃
  Future<void> signOut() async {
    try {
      await FlutterNaverLogin.logOut();
      debugPrint('✅ 네이버 로그아웃 성공');
    } catch (e) {
      debugPrint('❌ 네이버 로그아웃 실패: $e');
    }
  }
  
  /// 토큰 삭제 (연동 해제)
  Future<void> deleteToken() async {
    try {
      await FlutterNaverLogin.logOutAndDeleteToken();
      debugPrint('✅ 네이버 연동 해제 성공');
    } catch (e) {
      debugPrint('❌ 네이버 연동 해제 실패: $e');
    }
  }
  
  /// 현재 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    try {
      final result = await FlutterNaverLogin.currentAccount();
      return result != null;
    } catch (e) {
      return false;
    }
  }
  
  /// 현재 사용자 정보 가져오기
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final account = await FlutterNaverLogin.currentAccount();
      if (account != null) {
        final token = await FlutterNaverLogin.currentAccessToken;
        return {
          'id': account.id,
          'email': account.email,
          'name': account.name,
          'nickname': account.nickname ?? '',
          'profileImage': account.profileImage ?? '',
          'gender': account.gender ?? '',
          'age': account.age ?? '',
          'birthday': account.birthday ?? '',
          'birthyear': account.birthyear ?? '',
          'mobile': account.mobile ?? '',
          'provider': 'naver',
          'access_token': token?.accessToken ?? '',
          'refresh_token': token?.refreshToken ?? '',
          'expires_at': token?.expiresAt ?? '',
        };
      }
      return null;
    } catch (e) {
      debugPrint('❌ 현재 사용자 정보 가져오기 실패: $e');
      return null;
    }
  }
}