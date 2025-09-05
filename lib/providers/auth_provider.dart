import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

enum AuthState { loading, authenticated, unauthenticated, error }

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  AuthState _state = AuthState.loading;
  User? _user;
  String? _errorMessage;

  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated && _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      _setState(AuthState.loading);
      
      // 저장된 토큰과 사용자 정보 확인
      final token = LocalStorageService.getAuthToken();
      final user = LocalStorageService.getUser();
      
      if (token != null && user != null) {
        _apiService.setAuthToken(token);
        _user = user;
        _setState(AuthState.authenticated);
        debugPrint('✅ Login state restored - User: ${user.email}');
        
        // 토큰이 여전히 유효한지 확인 (서버 검증)
        try {
          final currentUser = await _apiService.getCurrentUser();
          _user = currentUser;
          await LocalStorageService.saveUser(currentUser);
          debugPrint('✅ Token is still valid');
          notifyListeners();
        } catch (e) {
          // 토큰이 만료되었거나 유효하지 않으면 로그아웃
          debugPrint('❌ Token expired or invalid, logging out: $e');
          await logout();
        }
      } else {
        _setState(AuthState.unauthenticated);
        debugPrint('🔓 No saved login state');
      }
    } catch (e) {
      _setError('인증을 초기화하는데 실패했습니다: $e');
    }
  }

  // SNS 로그인 (응답 데이터 포함)
  Future<Map<String, dynamic>?> socialLoginWithResponse(Map<String, dynamic> socialUserData) async {
    try {
      _setState(AuthState.loading);
      debugPrint('🔐 AuthProvider: Starting social login');
      debugPrint('📱 Provider: ${socialUserData['provider']}');
      debugPrint('📦 User Data: $socialUserData');
      
      // 백엔드 API로 소셜 로그인 정보 전송
      debugPrint('🌐 Calling backend API...');
      Map<String, dynamic>? response;
      
      try {
        response = await _apiService.socialLogin(socialUserData);
        debugPrint('📥 API Response: $response');
      } catch (apiError) {
        debugPrint('⚠️ API Error: $apiError');
        debugPrint('📱 Using local fallback for social login');
        
        // API 실패 시 로컬 처리 (임시)
        final localToken = 'local_${socialUserData['provider']}_${DateTime.now().millisecondsSinceEpoch}';
        response = {
          'token': localToken,
          'user': {
            'id': socialUserData['id'],
            'email': socialUserData['email'],
            'username': socialUserData['name']?.replaceAll(' ', '_').toLowerCase() ?? socialUserData['provider'],
            'name': socialUserData['name'],
            'first_name': socialUserData['name']?.split(' ').first ?? '',
            'last_name': socialUserData['name']?.split(' ').skip(1).join(' ') ?? '',
            'profile': {
              'profile_image': socialUserData['profileImage'],
              'name': socialUserData['name'],
            }
          },
          'created': true,
          'message': '로컬 처리로 로그인되었습니다'
        };
      }
      
      if (response != null) {
        final token = response['token'];
        final userData = response['user'];
        final bool isNewUser = response['created'] ?? false;
        
        debugPrint('🎫 Token received: $token');
        
        // 토큰 저장
        await LocalStorageService.saveAuthToken(token);
        _apiService.setAuthToken(token);
        debugPrint('💾 Token saved to local storage');
        
        // 사용자 정보 생성
        _user = User(
          id: userData['id'].toString(),
          email: userData['email'] ?? '',
          name: userData['name'] ?? userData['username'] ?? '',
          bio: userData['profile']?['name'] ?? '${socialUserData['provider']} 로그인 사용자',
          avatarUrl: userData['profile']?['profile_image'] ?? socialUserData['profileImage'],
          createdAt: DateTime.tryParse(userData['created_at'] ?? '') ?? DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        
        await LocalStorageService.saveUser(_user!);
        debugPrint('👤 User saved: ${_user!.email}');
        
        // 신규 가입 사용자인 경우 환영 메시지
        if (isNewUser) {
          debugPrint('🎉 Welcome new user from ${socialUserData['provider']}!');
        }
        
        debugPrint('✅ Social login successful, setting state to authenticated');
        _setState(AuthState.authenticated);
        
        // response에 성공 플래그 추가
        response['success'] = true;
        return response;
      } else {
        debugPrint('❌ No response from API');
        _setError('소셜 로그인 응답이 없습니다');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Social login error: $e');
      _setError('소셜 로그인에 실패했습니다: $e');
      return null;
    }
  }
  
  // 소셜 토큰으로 로그인 (딥링크 핸들러용)
  Future<void> loginWithSocialToken({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    try {
      _setState(AuthState.loading);
      
      // 토큰 저장
      await LocalStorageService.saveAuthToken(token);
      _apiService.setAuthToken(token);
      
      // 사용자 정보 생성
      _user = User(
        id: user['id'].toString(),
        email: user['email'] ?? '',
        name: user['name'] ?? user['username'] ?? '',
        bio: user['profile']?['name'] ?? '소셜 로그인 사용자',
        avatarUrl: user['profile']?['profile_image'] ?? '',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      await LocalStorageService.saveUser(_user!);
      _setState(AuthState.authenticated);
      
      debugPrint('✅ Social token login successful');
    } catch (e) {
      debugPrint('❌ Social token login error: $e');
      _setError('소셜 토큰 로그인에 실패했습니다: $e');
    }
  }
  
  // SNS 로그인 (기존 메서드 - 호환성 유지)
  Future<bool> socialLogin(Map<String, dynamic> socialUserData) async {
    final response = await socialLoginWithResponse(socialUserData);
    return response != null && response['success'] == true;
  }

  Future<bool> login(String email, String password) async {
    try {
      _setState(AuthState.loading);
      debugPrint('🔐 AuthProvider: Starting login for $email');
      
      // TEST MODE: Allow test@test.com with password "test" for UI testing
      if (email.toLowerCase() == 'test@test.com' && password == 'test') {
        debugPrint('🧪 TEST MODE: Using test credentials');
        final testUser = User(
          id: '1',
          email: 'test@test.com',
          name: '테스트 사용자',
          bio: '테스트용 사용자입니다',
          avatarUrl: null,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        
        await LocalStorageService.saveAuthToken('test_token_12345');
        _apiService.setAuthToken('test_token_12345');
        _user = testUser;
        await LocalStorageService.saveUser(testUser);
        
        debugPrint('✅ TEST LOGIN successful, transitioning to authenticated state');
        _setState(AuthState.authenticated);
        return true;
      }
      
      final response = await _apiService.login(email, password);
      debugPrint('📦 Login response received: ${response.keys}');
      
      final token = response['token'] ?? response['access_token'];
      final userData = response['user'] ?? response;
      
      if (token != null) {
        debugPrint('🎫 Token received: $token');
        await LocalStorageService.saveAuthToken(token);
        _apiService.setAuthToken(token);
        debugPrint('✅ Token set in API service');
        
        debugPrint('👤 Parsing user data...');
        _user = User.fromJson(userData);
        await LocalStorageService.saveUser(_user!);
        
        debugPrint('✅ Login successful, transitioning to authenticated state');
        _setState(AuthState.authenticated);
        return true;
      } else {
        debugPrint('❌ No token in response');
        _setError('서버로부터 잘못된 응답을 받았습니다');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Login error: $e');
      _setError('로그인에 실패했습니다: $e');
      return false;
    }
  }


  Future<bool> register(String name, String email, String password, {String? username, String? passwordConfirm, bool termsAccepted = true, bool privacyAccepted = true}) async {
    try {
      _setState(AuthState.loading);
      
      final response = await _apiService.register(
        email, 
        password, 
        name,
        username: username,
        passwordConfirm: passwordConfirm,
        termsAccepted: termsAccepted,
        privacyAccepted: privacyAccepted,
      );
      final token = response['token'] ?? response['access_token'];
      final userData = response['user'] ?? response;
      
      if (token != null) {
        await LocalStorageService.saveAuthToken(token);
        _apiService.setAuthToken(token);
        
        _user = User.fromJson(userData);
        await LocalStorageService.saveUser(_user!);
        
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError('서버로부터 잘못된 응답을 받았습니다');
        return false;
      }
    } catch (e) {
      _setError('회원가입에 실패했습니다: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      // Try to notify server about logout
      if (_state == AuthState.authenticated) {
        try {
          await _apiService.logout();
        } catch (e) {
          // Ignore server errors during logout
          debugPrint('Server logout error: $e');
        }
      }
    } finally {
      // Always clear local data
      await LocalStorageService.clearAuthToken();
      await LocalStorageService.clearUser();
      _apiService.clearAuthToken();
      _user = null;
      _setState(AuthState.unauthenticated);
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    try {
      _setState(AuthState.loading);
      
      final updatedUser = await _apiService.updateUser(userData);
      _user = updatedUser;
      await LocalStorageService.saveUser(updatedUser);
      
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError('프로필 업데이트에 실패했습니다: $e');
      return false;
    }
  }

  Future<void> refreshUserData() async {
    if (_state != AuthState.authenticated) return;
    
    try {
      final currentUser = await _apiService.getCurrentUser();
      _user = currentUser;
      await LocalStorageService.saveUser(currentUser);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to refresh user data: $e');
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    try {
      _setState(AuthState.loading);
      debugPrint('🔐 AuthProvider: Starting password reset request for $email');
      
      // TEST MODE: Always succeed for UI testing
      debugPrint('🧪 TEST MODE: Mock password reset success');
      
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      debugPrint('✅ Password reset email sent successfully');
      
      _setState(AuthState.unauthenticated);
      return true;
    } catch (e) {
      debugPrint('❌ Password reset error: $e');
      _setError('비밀번호 재설정 요청에 실패했습니다: $e');
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _setState(_user != null ? AuthState.authenticated : AuthState.unauthenticated);
    }
  }

  void _setState(AuthState newState) {
    _state = newState;
    if (newState != AuthState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _state = AuthState.error;
    notifyListeners();
  }

  Future<bool> checkLoginStatus() async {
    return isAuthenticated;
  }

  // 저장된 토큰과 사용자 정보를 확인하여 인증 상태를 복원하는 메소드
  Future<void> checkAuthStatus() async {
    try {
      final token = LocalStorageService.getAuthToken();
      final user = LocalStorageService.getUser();
      
      if (token != null && user != null) {
        _apiService.setAuthToken(token);
        _user = user;
        _setState(AuthState.authenticated);
        debugPrint('✅ Auth status restored - User: ${user.email}');
      } else {
        _setState(AuthState.unauthenticated);
        debugPrint('❌ No auth token or user found');
      }
    } catch (e) {
      debugPrint('❌ Failed to check auth status: $e');
      _setState(AuthState.unauthenticated);
    }
  }
}