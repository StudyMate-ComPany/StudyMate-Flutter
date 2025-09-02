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
      
      final token = LocalStorageService.getAuthToken();
      final user = LocalStorageService.getUser();
      
      if (token != null && user != null) {
        _apiService.setAuthToken(token);
        _user = user;
        _setState(AuthState.authenticated);
        
        // Verify token is still valid by fetching current user
        try {
          final currentUser = await _apiService.getCurrentUser();
          _user = currentUser;
          await LocalStorageService.saveUser(currentUser);
          notifyListeners();
        } catch (e) {
          // Token is invalid, clear auth data
          await logout();
        }
      } else {
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      _setError('인증을 초기화하는데 실패했습니다: $e');
    }
  }

  // SNS 로그인
  Future<bool> socialLogin(Map<String, dynamic> socialUserData) async {
    try {
      _setState(AuthState.loading);
      debugPrint('🔐 AuthProvider: Starting social login');
      debugPrint('📱 Provider: ${socialUserData['provider']}');
      
      // 백엔드 API로 소셜 로그인 정보 전송
      // 실제 백엔드 연동 시 아래 주석 해제
      // final response = await _apiService.socialLogin(socialUserData);
      
      // 임시 로컬 처리 (백엔드 연동 전)
      final testUser = User(
        id: socialUserData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        email: socialUserData['email'] ?? '${socialUserData['provider']}@studymate.com',
        name: socialUserData['name'] ?? '${socialUserData['provider']} 사용자',
        bio: '${socialUserData['provider']} 로그인 사용자',
        avatarUrl: socialUserData['profileImage'],
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      // 임시 토큰 생성
      final token = 'social_${socialUserData['provider']}_${DateTime.now().millisecondsSinceEpoch}';
      
      await LocalStorageService.saveAuthToken(token);
      _apiService.setAuthToken(token);
      _user = testUser;
      await LocalStorageService.saveUser(testUser);
      
      debugPrint('✅ Social login successful');
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      _setError('소셜 로그인에 실패했습니다: $e');
      return false;
    }
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

  Future<bool> socialLogin(String provider) async {
    try {
      _setState(AuthState.loading);
      debugPrint('🔐 AuthProvider: Starting social login with $provider');
      
      // TEST MODE: Mock social login for UI testing
      debugPrint('🧪 TEST MODE: Using mock social login');
      final testUser = User(
        id: '1',
        email: '$provider@user.com',
        name: '$provider 사용자',
        bio: '$provider로 로그인한 사용자입니다',
        avatarUrl: null,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      await LocalStorageService.saveAuthToken('${provider}_token_12345');
      _apiService.setAuthToken('${provider}_token_12345');
      _user = testUser;
      await LocalStorageService.saveUser(testUser);
      
      debugPrint('✅ SOCIAL LOGIN successful, transitioning to authenticated state');
      _setState(AuthState.authenticated);
      return true;
    } catch (e) {
      debugPrint('❌ Social login error: $e');
      _setError('소셜 로그인에 실패했습니다: $e');
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
}