import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'naver_login_service.dart';

class SocialLoginService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final NaverLoginService _naverLoginService = NaverLoginService();
  
  // 네이버 로그인 - SDK 사용
  Future<Map<String, dynamic>?> signInWithNaver(BuildContext context) async {
    try {
      debugPrint('🚀 네이버 로그인 시작 - SDK 사용');
      
      // 네이버 로그인 SDK 실행
      final userData = await _naverLoginService.signIn();
      
      if (userData != null) {
        debugPrint('✅ 네이버 로그인 성공');
        debugPrint('사용자 ID: ${userData['id']}');
        debugPrint('이메일: ${userData['email']}');
        debugPrint('이름: ${userData['name']}');
        
        return userData;
      } else {
        debugPrint('❌ 네이버 로그인 실패 또는 취소');
        return null;
      }
    } catch (e) {
      debugPrint('❌ 네이버 로그인 예외: $e');
      return null;
    }
  }

  // 구글 로그인
  Future<Map<String, dynamic>?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      print('구글 로그인 성공');
      print('사용자 이메일: ${googleUser.email}');
      
      return {
        'id': googleUser.id,
        'email': googleUser.email,
        'name': googleUser.displayName ?? '',
        'profileImage': googleUser.photoUrl ?? '',
        'provider': 'google',
        'access_token': googleAuth.accessToken ?? '',
      };
    } catch (e) {
      print('구글 로그인 실패: $e');
      return null;
    }
  }

  // 카카오 로그인
  Future<Map<String, dynamic>?> signInWithKakao(BuildContext context) async {
    try {
      // 1. 카카오톡 설치 여부 확인
      if (await isKakaoTalkInstalled()) {
        try {
          // 카카오톡으로 로그인
          final OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
          print('카카오톡으로 로그인 성공');
          return await _getKakaoUserInfo(token);
        } catch (error) {
          print('카카오톡으로 로그인 실패 $error');
          
          // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
          // 의도적인 로그인 취소로 보고 카카오 계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
          if (error is PlatformException && error.code == 'CANCELED') {
            return null;
          }
          // 카카오톡에 연결된 카카오 계정이 없는 경우, 카카오 계정으로 로그인
          try {
            final OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
            print('카카오 계정으로 로그인 성공');
            return await _getKakaoUserInfo(token);
          } catch (error) {
            print('카카오 계정으로 로그인 실패 $error');
            return null;
          }
        }
      } else {
        // 카카오톡이 설치되어 있지 않은 경우, 카카오 계정으로 로그인
        try {
          final OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          print('카카오 계정으로 로그인 성공');
          return await _getKakaoUserInfo(token);
        } catch (error) {
          print('카카오 계정으로 로그인 실패 $error');
          return null;
        }
      }
    } catch (e) {
      print('카카오 로그인 예외: $e');
      return null;
    }
  }

  // 카카오 사용자 정보 가져오기
  Future<Map<String, dynamic>?> _getKakaoUserInfo(OAuthToken token) async {
    try {
      final User user = await UserApi.instance.me();
      print('카카오 사용자 정보 요청 성공'
          '\n회원 번호: ${user.id}'
          '\n닉네임: ${user.kakaoAccount?.profile?.nickname}'
          '\n이메일: ${user.kakaoAccount?.email}');
      
      return {
        'id': user.id.toString(),
        'email': user.kakaoAccount?.email ?? '',
        'name': user.kakaoAccount?.profile?.nickname ?? '',
        'profileImage': user.kakaoAccount?.profile?.profileImageUrl ?? '',
        'provider': 'kakao',
        'access_token': token.accessToken,
      };
    } catch (error) {
      print('카카오 사용자 정보 요청 실패 $error');
      return null;
    }
  }

  // Apple 로그인
  Future<Map<String, dynamic>?> signInWithApple(BuildContext context) async {
    try {
      // Apple ID 로그인 요청
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      print('Apple 로그인 성공');
      print('User ID: ${credential.userIdentifier}');
      print('Email: ${credential.email}');
      print('Name: ${credential.givenName} ${credential.familyName}');

      // Apple은 최초 로그인 시에만 이메일과 이름을 제공
      return {
        'id': credential.userIdentifier!,
        'email': credential.email ?? '',
        'name': '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim(),
        'profileImage': '', // Apple은 프로필 이미지를 제공하지 않음
        'provider': 'apple',
        'access_token': credential.identityToken ?? '',
        'authorization_code': credential.authorizationCode,
      };
    } catch (e) {
      print('Apple 로그인 실패: $e');
      return null;
    }
  }

  // Generates a cryptographically secure random nonce
  String _generateNonce([int length = 32]) {
    final charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  // Returns the sha256 hash of [input] in hex notation
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      // 구글 로그아웃
      await _googleSignIn.signOut();
      
      // 카카오 로그아웃
      try {
        await UserApi.instance.logout();
      } catch (e) {
        print('카카오 로그아웃 실패: $e');
      }
      
      // 네이버 로그아웃은 토큰 삭제로 처리
      // NaverOAuthService의 deleteToken 메서드 사용 가능
      
      // Apple 로그아웃은 별도 처리 필요 없음
      
    } catch (e) {
      print('로그아웃 실패: $e');
    }
  }
}