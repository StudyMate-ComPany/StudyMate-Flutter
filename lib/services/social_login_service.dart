import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
// import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SocialLoginService {
  static final SocialLoginService _instance = SocialLoginService._internal();
  factory SocialLoginService() => _instance;
  SocialLoginService._internal();

  // 구글 로그인 인스턴스
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  // 카카오 로그인
  Future<Map<String, dynamic>?> signInWithKakao(BuildContext context) async {
    debugPrint('🔐 [SocialLogin] Starting Kakao login...');
    debugPrint('📱 [SocialLogin] App Key: ${dotenv.env['KAKAO_NATIVE_APP_KEY']}');
    
    // 디버그용 키 해시 출력
    try {
      final keyHash = await KakaoSdk.origin;
      debugPrint('🔑 [Debug] Kakao Key Hash: $keyHash');
      debugPrint('📦 [Debug] Package Name: com.studymate.studymate_flutter');
      
      // SDK 버전 확인
      debugPrint('🔧 [Debug] Kakao SDK initialized: ${KakaoSdk.origin}');
    } catch (e) {
      debugPrint('❌ [Debug] Failed to get debug info: $e');
    }
    
    try {
      // 카카오톡 설치 여부 확인
      bool isInstalled = await isKakaoTalkInstalled();
      debugPrint('📱 [SocialLogin] KakaoTalk installed: $isInstalled');
      
      if (isInstalled) {
        try {
          debugPrint('📲 [SocialLogin] Attempting KakaoTalk login...');
          // 카카오톡으로 로그인
          final OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
          debugPrint('✅ [SocialLogin] KakaoTalk login successful');
          debugPrint('🔑 [Response] Access Token: ${token.accessToken}');
          debugPrint('🔑 [Response] Refresh Token: ${token.refreshToken}');
          debugPrint('🔑 [Response] ID Token: ${token.idToken}');
          debugPrint('🔑 [Response] Scopes: ${token.scopes}');
          debugPrint('📦 [Response] Full Token Object: $token');
        } catch (error) {
          debugPrint('⚠️ 카카오톡으로 로그인 실패: $error');
          
          // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
          try {
            debugPrint('🌐 [SocialLogin] Fallback to Kakao account login...');
            final OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
            debugPrint('✅ [SocialLogin] Kakao account login successful');
            debugPrint('🔑 [Response] Access Token: ${token.accessToken}');
            debugPrint('🔑 [Response] Refresh Token: ${token.refreshToken}');
            debugPrint('🔑 [Response] ID Token: ${token.idToken}');
            debugPrint('🔑 [Response] Scopes: ${token.scopes}');
            debugPrint('📦 [Response] Full Token Object: $token');
          } catch (error) {
            debugPrint('❌ 카카오계정으로 로그인 실패: $error');
            return null;
          }
        }
      } else {
        // 카카오톡이 설치되어 있지 않으면 카카오계정으로 로그인
        try {
          debugPrint('🌐 [SocialLogin] Attempting Kakao account login (no KakaoTalk)...');
          debugPrint('📍 [Debug] Calling loginWithKakaoAccount...');
          
          // 명시적으로 스코프 지정
          final OAuthToken token = await UserApi.instance.loginWithKakaoAccount(
            prompts: [Prompt.login], // 항상 로그인 프롬프트 표시
          );
          debugPrint('✅ [SocialLogin] Kakao account login successful');
          debugPrint('✅ [Debug] Token received from Kakao');
          debugPrint('🔑 [Response] Access Token: ${token.accessToken}');
          debugPrint('🔑 [Response] Refresh Token: ${token.refreshToken}');
          debugPrint('🔑 [Response] ID Token: ${token.idToken}');
          debugPrint('🔑 [Response] Scopes: ${token.scopes}');
          debugPrint('📦 [Response] Full Token Object: $token');
        } catch (error) {
          debugPrint('❌ 카카오계정으로 로그인 실패: $error');
          debugPrint('📍 [Debug] Error type: ${error.runtimeType}');
          debugPrint('📍 [Debug] Error details: $error');
          if (error.toString().contains('CANCELED')) {
            debugPrint('🚫 [Debug] User canceled login');
          } else if (error.toString().contains('REDIRECT')) {
            debugPrint('🔄 [Debug] Redirect issue detected');
          }
          return null;
        }
      }

      // 사용자 정보 가져오기
      try {
        // 액세스 토큰 가져오기
        final tokenInfo = await UserApi.instance.accessTokenInfo();
        debugPrint('🎫 Access Token ID: ${tokenInfo.id}');
        debugPrint('⏰ Token Expires In: ${tokenInfo.expiresIn}초');
        
        // 실제 액세스 토큰 가져오기
        final token = await TokenManagerProvider.instance.manager.getToken();
        final accessToken = token?.accessToken;
        debugPrint('🔑 Access Token: $accessToken');
        
        User user = await UserApi.instance.me();
        debugPrint('✅ 카카오 로그인 성공');
        debugPrint('👤 사용자 정보: ${user.id}');
        debugPrint('📝 닉네임: ${user.kakaoAccount?.profile?.nickname}');
        debugPrint('📧 이메일: ${user.kakaoAccount?.email}');
        
        final userData = {
          'id': user.id.toString(),
          'email': user.kakaoAccount?.email ?? '',
          'name': user.kakaoAccount?.profile?.nickname ?? '',
          'profileImage': user.kakaoAccount?.profile?.profileImageUrl ?? '',
          'provider': 'kakao',
          'access_token': accessToken,  // 액세스 토큰 추가
        };
        
        debugPrint('📦 Returning user data to AuthProvider: $userData');
        return userData;
      } catch (error) {
        debugPrint('❌ 사용자 정보 가져오기 실패: $error');
        debugPrint('📝 [Error] Type: ${error.runtimeType}');
        debugPrint('📝 [Error] Details: $error');
        return null;
      }
    } catch (error) {
      debugPrint('❌ [KAKAO LOGIN ERROR] 카카오 로그인 에러: $error');
      debugPrint('📝 [Error] Type: ${error.runtimeType}');
      debugPrint('📝 [Error] Stack trace: ${StackTrace.current}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('카카오 로그인에 실패했습니다'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return null;
    }
  }

  // 네이버 로그인 (일시적으로 비활성화)
  Future<Map<String, dynamic>?> signInWithNaver(BuildContext context) async {
    // 네이버 로그인 패키지 문제 해결 후 활성화
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('네이버 로그인은 준비 중입니다'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    return null;
    
    // try {
    //   final NaverLoginResult result = await FlutterNaverLogin.logIn();
    //   
    //   if (result.status == NaverLoginStatus.loggedIn) {
    //     final NaverAccountResult account = result.account;
    //     
    //     print('네이버 로그인 성공');
    //     print('액세스 토큰: ${result.accessToken}');
    //     print('사용자 이름: ${account.name}');
    //     print('사용자 이메일: ${account.email}');
    //     
    //     return {
    //       'id': account.id,
    //       'email': account.email,
    //       'name': account.name,
    //       'profileImage': account.profileImage ?? '',
    //       'provider': 'naver',
    //     };
    //   } else {
    //     print('네이버 로그인 실패: ${result.errorMessage}');
    //     if (context.mounted) {
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         const SnackBar(
    //           content: Text('네이버 로그인에 실패했습니다'),
    //           duration: Duration(seconds: 2),
    //         ),
    //       );
    //     }
    //     return null;
    //   }
    // } catch (error) {
    //   print('네이버 로그인 에러: $error');
    //   if (context.mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(
    //         content: Text('네이버 로그인에 실패했습니다'),
    //         duration: Duration(seconds: 2),
    //       ),
    //     );
    //   }
    //   return null;
    // }
  }

  // 구글 로그인
  Future<Map<String, dynamic>?> signInWithGoogle(BuildContext context) async {
    try {
      // 구글 로그인 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // 사용자가 로그인을 취소한 경우
        return null;
      }

      // 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      print('구글 로그인 성공');
      print('사용자 이름: ${googleUser.displayName}');
      print('사용자 이메일: ${googleUser.email}');
      print('액세스 토큰: ${googleAuth.accessToken}');
      
      return {
        'id': googleUser.id,
        'email': googleUser.email,
        'name': googleUser.displayName ?? '',
        'profileImage': googleUser.photoUrl ?? '',
        'provider': 'google',
        'accessToken': googleAuth.accessToken,
        'idToken': googleAuth.idToken,
      };
    } catch (error) {
      print('구글 로그인 에러: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('구글 로그인에 실패했습니다'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return null;
    }
  }

  // 애플 로그인
  Future<Map<String, dynamic>?> signInWithApple(BuildContext context) async {
    try {
      // nonce 생성
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);

      // 애플 로그인 요청
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      print('애플 로그인 성공');
      print('사용자 ID: ${credential.userIdentifier}');
      print('이메일: ${credential.email}');
      print('이름: ${credential.givenName} ${credential.familyName}');

      // 애플은 처음 로그인할 때만 이메일과 이름을 제공합니다
      // 이후 로그인에서는 userIdentifier만 제공됩니다
      return {
        'id': credential.userIdentifier ?? '',
        'email': credential.email ?? '',
        'name': '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim(),
        'profileImage': '',
        'provider': 'apple',
        'identityToken': credential.identityToken,
        'authorizationCode': credential.authorizationCode,
      };
    } catch (error) {
      print('애플 로그인 에러: $error');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('애플 로그인에 실패했습니다'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return null;
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      // 카카오 로그아웃
      try {
        await UserApi.instance.logout();
      } catch (e) {
        print('카카오 로그아웃 에러: $e');
      }

      // 네이버 로그아웃 (일시적으로 비활성화)
      // try {
      //   await FlutterNaverLogin.logOut();
      // } catch (e) {
      //   print('네이버 로그아웃 에러: $e');
      // }

      // 구글 로그아웃
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        print('구글 로그아웃 에러: $e');
      }

      // 애플은 별도의 로그아웃이 없음
    } catch (error) {
      print('로그아웃 에러: $error');
    }
  }

  // nonce 생성 함수 (애플 로그인용)
  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  // SHA256 해시 함수 (애플 로그인용)
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}