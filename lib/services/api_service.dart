import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../models/user.dart';
import '../models/study_goal.dart';
import '../models/study_session.dart';
import '../models/ai_response.dart' as ai_model;
import 'mock_data_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiService {
  // EC2 프로덕션 서버 사용
  static const String baseUrl = 'http://54.161.77.144';
  static const Duration timeout = Duration(seconds: 30);
  
  // Singleton instance
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  late Dio _dio;
  String? _authToken;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'StudyMate Flutter App/1.0.0',
      },
    ));

    // HTTPS 인증서 검증 설정
    if (!kIsWeb) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        // 개발 환경에서만 인증서 검증 우회
        if (kDebugMode) {
          client.badCertificateCallback = (cert, host, port) => true;
        }
        return client;
      };
    }

    // 인터셉터 추가
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 회원가입과 로그인 엔드포인트에서는 Authorization 헤더를 보내지 않음
        final publicEndpoints = ['/api/auth/register/', '/api/auth/login/', '/api/auth/refresh/', '/api/auth/social/login/'];
        final isPublicEndpoint = publicEndpoints.any((endpoint) => options.path.contains(endpoint));
        
        if (_authToken != null && !isPublicEndpoint) {
          options.headers['Authorization'] = 'Token $_authToken';
          debugPrint('🔑 Auth token added to request: Token $_authToken');
        } else if (!isPublicEndpoint) {
          debugPrint('⚠️ No auth token available for protected endpoint: ${options.path}');
        }
        
        debugPrint('🔵 REQUEST[${options.method}] => PATH: ${options.path}');
        debugPrint('📋 Headers: ${options.headers}');
        if (options.data != null) {
          debugPrint('📤 DATA: ${options.data}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('🟢 RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        debugPrint('📥 DATA: ${response.data}');
        handler.next(response);
      },
      onError: (DioException e, handler) {
        debugPrint('🔴 ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
        debugPrint('❌ ERROR TYPE: ${e.type}');
        debugPrint('❌ ERROR MESSAGE: ${e.message}');
        if (e.response?.data != null) {
          debugPrint('❌ ERROR DATA: ${e.response?.data}');
        }
        if (e.error != null) {
          debugPrint('❌ ORIGINAL ERROR: ${e.error}');
        }
        handler.next(e);
      },
    ));
  }

  void setAuthToken(String token) {
    _authToken = token;
    debugPrint('✅ [ApiService] Auth token set: $token');
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? queryParams,
  }) async {
    try {
      Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _dio.get(endpoint, queryParameters: queryParams);
          break;
        case 'POST':
          response = await _dio.post(endpoint, data: data, queryParameters: queryParams);
          break;
        case 'PUT':
          response = await _dio.put(endpoint, data: data, queryParameters: queryParams);
          break;
        case 'DELETE':
          response = await _dio.delete(endpoint, queryParameters: queryParams);
          break;
        default:
          throw ApiException('지원하지 않는 HTTP 메소드입니다: $method');
      }

      if (response.data == null || response.data.toString().isEmpty) {
        return {'success': true};
      }
      
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
      
      return {'data': response.data};
      
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ApiException('연결 시간이 초과되었습니다');
      }
      
      if (e.type == DioExceptionType.connectionError) {
        throw ApiException('인터넷 연결이 없습니다');
      }
      
      if (e.response != null) {
        String errorMessage = 'Request failed';
        try {
          if (e.response!.data is Map) {
            errorMessage = e.response!.data['message'] ?? 
                          e.response!.data['error'] ?? 
                          errorMessage;
          } else {
            errorMessage = e.response!.data.toString();
          }
        } catch (_) {
          errorMessage = e.message ?? errorMessage;
        }
        throw ApiException(errorMessage, e.response?.statusCode);
      }
      
      throw ApiException(e.message ?? 'Unknown error occurred');
    } catch (e) {
      throw ApiException('예기치 않은 오류가 발생했습니다: $e');
    }
  }

  // Auth endpoints
  Future<Map<String, dynamic>> register(String email, String password, String name, {String? username, String? passwordConfirm, bool termsAccepted = true, bool privacyAccepted = true}) async {
    // Create username from name if not provided
    String finalUsername;
    if (username != null && username.isNotEmpty) {
      finalUsername = username;
    } else {
      final nameParts = name.toLowerCase().split(' ');
      final timestamp = DateTime.now().millisecondsSinceEpoch % 10000;
      finalUsername = '${nameParts.join('')}$timestamp'.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
    }
    
    try {
      final response = await _makeRequest('POST', '/api/auth/register/', data: {
        'email': email,
        'username': finalUsername,
        'password': password,
        'password_confirm': passwordConfirm ?? password,
        'profile_name': name,  // Add profile_name field for server compatibility
        'terms_accepted': termsAccepted,
        'privacy_accepted': privacyAccepted,
      });
      
      // Store token if provided
      if (response['token'] != null) {
        setAuthToken(response['token']);
      }
      
      return response;
    } catch (e) {
      debugPrint('❌ Error registering: $e');
      // Don't fall back to mock data in production
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    debugPrint('🔐 Attempting login for: $email');
    try {
      final response = await _makeRequest('POST', '/api/auth/login/', data: {
        'email': email,
        'password': password,
      });
      
      // Store token if provided
      if (response['token'] != null) {
        setAuthToken(response['token']);
        debugPrint('✅ Login successful, token stored');
      }
      
      return response;
    } catch (e) {
      debugPrint('❌ Login failed: $e');
      // Don't fall back to mock data in production
      rethrow;
    }
  }

  Future<Map<String, dynamic>> socialLogin(Map<String, dynamic> socialData) async {
    debugPrint('🔐 Attempting social login with: ${socialData['provider']}');
    
    // Django 서버가 기대하는 형식으로 데이터 변환
    Map<String, dynamic> requestData;
    
    if (socialData['provider'] == 'kakao') {
      // 카카오 로그인용 데이터
      requestData = {
        'provider': 'kakao',
        'access_token': socialData['access_token'] ?? '',
        'kakao_id': socialData['id'],
        'email': socialData['email'] ?? '',
        'nickname': socialData['name'] ?? '',
        'profile_image': socialData['profileImage'] ?? '',
      };
    } else if (socialData['provider'] == 'naver') {
      // 네이버 로그인용 데이터
      requestData = {
        'provider': 'naver',
        'access_token': socialData['access_token'] ?? '',
        'id': socialData['id'],
        'email': socialData['email'] ?? '',
        'name': socialData['name'] ?? '',
        'profileImage': socialData['profileImage'] ?? '',
      };
    } else {
      // 다른 소셜 로그인 제공자
      requestData = {
        'provider': socialData['provider'],
        'access_token': socialData['access_token'] ?? '',
        'id_token': socialData['idToken'] ?? '',
        'email': socialData['email'] ?? '',
        'name': socialData['name'] ?? '',
        'profile_image': socialData['profileImage'] ?? '',
      };
    }
    
    debugPrint('📤 Sending social login data: $requestData');
    
    try {
      final response = await _makeRequest('POST', '/api/auth/social/login/', data: requestData);
      
      // Store token if provided
      if (response['token'] != null) {
        setAuthToken(response['token']);
        debugPrint('✅ Social login successful, token stored');
      }
      
      return response;
    } catch (e) {
      debugPrint('❌ Social login failed: $e');
      debugPrint('💡 서버 응답 형식 문제일 수 있습니다. Django REST Framework 설정을 확인해주세요.');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> logout() async {
    return _makeRequest('POST', '/api/auth/logout/');
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    return _makeRequest('POST', '/api/auth/refresh/', data: {
      'refresh': refreshToken,
    });
  }

  Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    return _makeRequest('POST', '/api/auth/password-reset/', data: {
      'email': email,
    });
  }

  Future<Map<String, dynamic>> confirmPasswordReset({
    required String token,
    required String password,
    required String passwordConfirm,
  }) async {
    return _makeRequest('POST', '/api/auth/password-reset/confirm/', data: {
      'token': token,
      'password': password,
      'password_confirm': passwordConfirm,
    });
  }

  // User endpoints
  Future<User> getCurrentUser() async {
    try {
      // Try multiple possible endpoints
      try {
        final response = await _makeRequest('GET', '/api/users/me/');
        return User.fromJson(response);
      } catch (_) {
        // Fallback to alternative endpoint
        final response = await _makeRequest('GET', '/api/users/');
        return User.fromJson(response);
      }
    } catch (e) {
      debugPrint('❌ Error getting current user: $e');
      // Return a default user if not authenticated
      return User(
        id: '0',
        email: 'guest@studymate.com',
        name: 'Guest User',
        avatarUrl: null,
        bio: null,
        createdAt: DateTime.now(),
      );
    }
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await _makeRequest('PUT', '/api/users/profile/', data: data);
    return User.fromJson(response);
  }

  // Study Goals endpoints
  Future<List<StudyGoal>> getGoals() async {
    try {
      final response = await _makeRequest('GET', '/api/study/goals/');
      debugPrint('📊 Goals response: $response');
      
      // Handle different response formats
      List<dynamic> goalsList;
      if (response is List) {
        goalsList = response as List;
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey('results')) {
          goalsList = response['results'] as List;
        } else if (response.containsKey('data')) {
          goalsList = response['data'] as List;
        } else if (response.containsKey('goals')) {
          goalsList = response['goals'] as List;
        } else {
          goalsList = [];
        }
      } else {
        goalsList = [];
      }
      
      return goalsList.map((json) => StudyGoal.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error getting goals: $e');
      // Return empty list instead of mock data
      return [];
    }
  }

  Future<StudyGoal> createGoal(Map<String, dynamic> data) async {
    final response = await _makeRequest('POST', '/api/study/goals/', data: data);
    return StudyGoal.fromJson(response);
  }

  Future<StudyGoal> updateGoal(String id, Map<String, dynamic> data) async {
    final response = await _makeRequest('PUT', '/api/study/goals/$id/', data: data);
    return StudyGoal.fromJson(response);
  }

  Future<void> deleteGoal(String id) async {
    await _makeRequest('DELETE', '/api/study/goals/$id/');
  }

  // Study Sessions endpoints
  Future<List<StudySession>> getSessions() async {
    try {
      final response = await _makeRequest('GET', '/api/study/sessions/');
      debugPrint('📊 Sessions response: $response');
      
      // Handle different response formats
      List<dynamic> sessionsList;
      if (response is List) {
        sessionsList = response as List;
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey('results')) {
          sessionsList = response['results'] as List;
        } else if (response.containsKey('data')) {
          sessionsList = response['data'] as List;
        } else if (response.containsKey('sessions')) {
          sessionsList = response['sessions'] as List;
        } else {
          sessionsList = [];
        }
      } else {
        sessionsList = [];
      }
      
      return sessionsList.map((json) => StudySession.fromJson(json)).toList();
    } catch (e) {
      debugPrint('❌ Error getting sessions: $e');
      // Return empty list instead of mock data
      return [];
    }
  }

  Future<StudySession> startSession(String goalId) async {
    final response = await _makeRequest('POST', '/api/study/sessions/start/', data: {
      'goal_id': goalId,
    });
    return StudySession.fromJson(response);
  }

  Future<StudySession> endSession(String sessionId) async {
    final response = await _makeRequest('POST', '/api/study/sessions/$sessionId/end/');
    return StudySession.fromJson(response);
  }

  // AI endpoints
  Future<ai_model.AIResponse> chatWithAI(String message, {String? context}) async {
    try {
      final response = await _makeRequest('POST', '/api/study/ai/chat/', data: {
        'message': message,
        'context': context,
      });
      return ai_model.AIResponse.fromJson(response);
    } catch (e) {
      debugPrint('❌ Error chatting with AI: $e');
      // Return a simple default response
      return ai_model.AIResponse(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'system',
        type: ai_model.AIResponseType.explanation,
        query: message,
        response: 'AI 서비스가 현재 사용할 수 없습니다. 잠시 후 다시 시도해주세요.',
        createdAt: DateTime.now(),
      );
    }
  }

  Future<Map<String, dynamic>> generateQuiz(String topic, int questionCount) async {
    try {
      return await _makeRequest('POST', '/api/study/ai/generate-quiz/', data: {
        'topic': topic,
        'question_count': questionCount,
      });
    } catch (e) {
      debugPrint('❌ Error generating quiz: $e');
      // Return empty quiz response
      return {
        'error': true,
        'message': '퀴즈 생성 서비스를 사용할 수 없습니다.'
      };
    }
  }

  Future<Map<String, dynamic>> generateStudyPlan(String goal, int days) async {
    try {
      return await _makeRequest('POST', '/api/study/ai/generate-plan/', data: {
        'goal': goal,
        'days': days,
      });
    } catch (e) {
      debugPrint('❌ Error generating study plan: $e');
      // Return empty plan response
      return {
        'error': true,
        'message': '학습 계획 생성 서비스를 사용할 수 없습니다.'
      };
    }
  }

  // Statistics endpoints
  Future<Map<String, dynamic>> getStatistics({String? period}) async {
    try {
      return await _makeRequest('GET', '/api/study/stats/overview/', queryParams: {
        if (period != null) 'period': period,
      });
    } catch (e) {
      debugPrint('❌ Error getting statistics: $e');
      // Return empty statistics
      return {
        'total_study_time': 0,
        'total_sessions': 0,
        'active_goals': 0,
        'completed_goals': 0,
        'weekly_data': [],
        'monthly_data': []
      };
    }
  }

  Future<Map<String, dynamic>> getProgressReport(String goalId) async {
    return _makeRequest('GET', '/api/stats/progress/$goalId/');
  }

  // Test endpoints
  Future<Map<String, dynamic>> testConnection() async {
    return _makeRequest('GET', '/');
  }

  Future<Map<String, dynamic>> testHealth() async {
    return _makeRequest('GET', '/api/health/');
  }

  // Legacy method names for compatibility
  Future<Map<String, dynamic>> testPost(Map<String, dynamic> data) async {
    return _makeRequest('POST', '/test', data: data);
  }

  Future<User> updateUser(Map<String, dynamic> userData) async {
    return updateProfile(userData);
  }

  Future<List<StudyGoal>> getStudyGoals() async {
    return getGoals();
  }

  Future<List<StudySession>> getStudySessions({String? goalId, DateTime? startDate, DateTime? endDate}) async {
    return getSessions();
  }

  Future<StudyGoal> createStudyGoal(Map<String, dynamic> goalData) async {
    return createGoal(goalData);
  }

  Future<StudyGoal> updateStudyGoal(String goalId, Map<String, dynamic> goalData) async {
    return updateGoal(goalId, goalData);
  }

  Future<void> deleteStudyGoal(String goalId) async {
    return deleteGoal(goalId);
  }

  Future<StudySession> createStudySession(Map<String, dynamic> sessionData) async {
    final response = await _makeRequest('POST', '/api/study/sessions/', data: sessionData);
    return StudySession.fromJson(response);
  }

  Future<StudySession> updateStudySession(String sessionId, Map<String, dynamic> sessionData) async {
    final response = await _makeRequest('PUT', '/api/study/sessions/$sessionId/', data: sessionData);
    return StudySession.fromJson(response);
  }

  Future<ai_model.AIResponse> askAI(String query, {ai_model.AIResponseType? type, Map<String, dynamic>? context}) async {
    final response = await _makeRequest('POST', '/api/study/ai/chat/', data: {
      'message': query,
      'context': context,
    });
    return ai_model.AIResponse.fromJson(response);
  }

  Future<List<ai_model.AIResponse>> getAIHistory({int? limit}) async {
    try {
      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();

      final response = await _makeRequest('GET', '/api/study/ai/history/', queryParams: queryParams);
      final history = response['history'] ?? response['data'] ?? [];
      return (history as List).map((item) => ai_model.AIResponse.fromJson(item)).toList();
    } catch (e) {
      debugPrint('❌ Error getting AI history: $e');
      // Return empty history
      return [];
    }
  }

  Future<Map<String, dynamic>> getStudyStatistics({DateTime? startDate, DateTime? endDate}) async {
    return getStatistics();
  }
  
}