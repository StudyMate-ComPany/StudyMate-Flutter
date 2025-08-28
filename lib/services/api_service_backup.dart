import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
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
  static const String baseUrl = 'http://54.161.77.144';
  static const Duration timeout = Duration(seconds: 30);
  
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }

  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? queryParams,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: _headers).timeout(timeout);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: _headers,
            body: data != null ? json.encode(data) : null,
          ).timeout(timeout);
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: _headers,
            body: data != null ? json.encode(data) : null,
          ).timeout(timeout);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: _headers).timeout(timeout);
          break;
        default:
          throw ApiException('지원하지 않는 HTTP 메소드입니다: $method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {'success': true};
        }
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        String errorMessage = 'Request failed';
        try {
          final errorBody = json.decode(response.body);
          errorMessage = errorBody['message'] ?? errorBody['error'] ?? errorMessage;
        } catch (_) {
          errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
        }
        throw ApiException(errorMessage, response.statusCode);
      }
    } on SocketException {
      throw ApiException('네트워크 연결에 실패했습니다. 인터넷 연결을 확인해주세요.');
    } on FormatException {
      throw ApiException('서버로부터 잘못된 응답 형식을 받았습니다.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('예기치 않은 오류가 발생했습니다: $e');
    }
  }

  // Test Endpoints
  Future<Map<String, dynamic>> testConnection() async {
    return await _makeRequest('GET', '/');
  }

  Future<Map<String, dynamic>> testPost(Map<String, dynamic> data) async {
    return await _makeRequest('POST', '/test', data: data);
  }

  // Authentication Endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await _makeRequest('POST', '/auth/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> register(String email, String password, String name) async {
    return await _makeRequest('POST', '/auth/register', data: {
      'email': email,
      'password': password,
      'name': name,
    });
  }

  Future<Map<String, dynamic>> logout() async {
    return await _makeRequest('POST', '/auth/logout');
  }

  Future<Map<String, dynamic>> refreshToken() async {
    return await _makeRequest('POST', '/auth/refresh');
  }

  // User Endpoints
  Future<User> getCurrentUser() async {
    final response = await _makeRequest('GET', '/user/me');
    return User.fromJson(response['user'] ?? response);
  }

  Future<User> updateUser(Map<String, dynamic> userData) async {
    final response = await _makeRequest('PUT', '/user/me', data: userData);
    return User.fromJson(response['user'] ?? response);
  }

  // Study Goals Endpoints
  Future<List<StudyGoal>> getStudyGoals() async {
    final response = await _makeRequest('GET', '/goals');
    final goals = response['goals'] ?? response['data'] ?? [];
    return (goals as List).map((goal) => StudyGoal.fromJson(goal)).toList();
  }

  Future<StudyGoal> createStudyGoal(Map<String, dynamic> goalData) async {
    final response = await _makeRequest('POST', '/goals', data: goalData);
    return StudyGoal.fromJson(response['goal'] ?? response);
  }

  Future<StudyGoal> updateStudyGoal(String goalId, Map<String, dynamic> goalData) async {
    final response = await _makeRequest('PUT', '/goals/$goalId', data: goalData);
    return StudyGoal.fromJson(response['goal'] ?? response);
  }

  Future<void> deleteStudyGoal(String goalId) async {
    await _makeRequest('DELETE', '/goals/$goalId');
  }

  // Study Sessions Endpoints
  Future<List<StudySession>> getStudySessions({String? goalId, DateTime? startDate, DateTime? endDate}) async {
    final queryParams = <String, String>{};
    if (goalId != null) queryParams['goal_id'] = goalId;
    if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
    if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

    final response = await _makeRequest('GET', '/sessions', queryParams: queryParams);
    final sessions = response['sessions'] ?? response['data'] ?? [];
    return (sessions as List).map((session) => StudySession.fromJson(session)).toList();
  }

  Future<StudySession> createStudySession(Map<String, dynamic> sessionData) async {
    final response = await _makeRequest('POST', '/sessions', data: sessionData);
    return StudySession.fromJson(response['session'] ?? response);
  }

  Future<StudySession> updateStudySession(String sessionId, Map<String, dynamic> sessionData) async {
    final response = await _makeRequest('PUT', '/sessions/$sessionId', data: sessionData);
    return StudySession.fromJson(response['session'] ?? response);
  }

  Future<void> deleteStudySession(String sessionId) async {
    await _makeRequest('DELETE', '/sessions/$sessionId');
  }

  // AI Assistant Endpoints
  Future<AIResponse> askAI(String query, {AIResponseType? type, Map<String, dynamic>? context}) async {
    final response = await _makeRequest('POST', '/ai/ask', data: {
      'query': query,
      'type': type?.name,
      'context': context,
    });
    return AIResponse.fromJson(response['response'] ?? response);
  }

  Future<List<AIResponse>> getAIHistory({int? limit}) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();

    final response = await _makeRequest('GET', '/ai/history', queryParams: queryParams);
    final history = response['history'] ?? response['data'] ?? [];
    return (history as List).map((item) => AIResponse.fromJson(item)).toList();
  }

  // Statistics Endpoints
  Future<Map<String, dynamic>> getStudyStatistics({DateTime? startDate, DateTime? endDate}) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['start_date'] = startDate.toIso8601String();
    if (endDate != null) queryParams['end_date'] = endDate.toIso8601String();

    return await _makeRequest('GET', '/stats', queryParams: queryParams);
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    return await _makeRequest('GET', '/dashboard');
  }
}