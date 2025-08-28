import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../models/user.dart';
import '../models/study_goal.dart';
import '../models/study_session.dart';
import '../models/ai_response.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiService {
  static const String baseUrl = 'https://54.161.77.144';
  static const Duration timeout = Duration(seconds: 30);
  
  late Dio _dio;
  String? _authToken;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // HTTPS 인증서 검증 우회 (개발용)
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };

    // 인터셉터 추가
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }
        print('REQUEST[${options.method}] => PATH: ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (DioException e, handler) {
        print('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
        handler.next(e);
      },
    ));
  }

  void setAuthToken(String token) {
    _authToken = token;
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
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    return _makeRequest('POST', '/api/auth/register/', data: {
      'username': username,
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    return _makeRequest('POST', '/api/auth/login/', data: {
      'username': username,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> logout() async {
    return _makeRequest('POST', '/api/auth/logout/');
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    return _makeRequest('POST', '/api/auth/refresh/', data: {
      'refresh': refreshToken,
    });
  }

  // User endpoints
  Future<User> getCurrentUser() async {
    final response = await _makeRequest('GET', '/api/user/profile/');
    return User.fromJson(response);
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await _makeRequest('PUT', '/api/user/profile/', data: data);
    return User.fromJson(response);
  }

  // Study Goals endpoints
  Future<List<StudyGoal>> getGoals() async {
    final response = await _makeRequest('GET', '/api/study/goals/');
    return (response['results'] as List)
        .map((json) => StudyGoal.fromJson(json))
        .toList();
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
    final response = await _makeRequest('GET', '/api/study/sessions/');
    return (response['results'] as List)
        .map((json) => StudySession.fromJson(json))
        .toList();
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
  Future<AIResponse> chatWithAI(String message, {String? context}) async {
    final response = await _makeRequest('POST', '/api/ai/chat/', data: {
      'message': message,
      'context': context,
    });
    return AIResponse.fromJson(response);
  }

  Future<Map<String, dynamic>> generateQuiz(String topic, int questionCount) async {
    return _makeRequest('POST', '/api/ai/generate-quiz/', data: {
      'topic': topic,
      'question_count': questionCount,
    });
  }

  Future<Map<String, dynamic>> generateStudyPlan(String goal, int days) async {
    return _makeRequest('POST', '/api/ai/generate-plan/', data: {
      'goal': goal,
      'days': days,
    });
  }

  // Statistics endpoints
  Future<Map<String, dynamic>> getStatistics({String? period}) async {
    return _makeRequest('GET', '/api/stats/overview/', queryParams: {
      if (period != null) 'period': period,
    });
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
}