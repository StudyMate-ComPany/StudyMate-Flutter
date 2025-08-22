import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class ApiService {
  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
    
    // Request interceptor to add auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Handle token expiration
          _handleTokenExpiration();
        }
        handler.next(error);
      },
    ));
  }
  
  void _handleTokenExpiration() async {
    await _storage.delete(key: 'auth_token');
    // Navigate to login screen - implement navigation logic
  }
  
  // Auth methods
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(ApiConstants.register, data: {
        'email': email,
        'username': username,
        'password': password,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(ApiConstants.login, data: {
        'email': email,
        'password': password,
      });
      
      // Save token if present
      if (response.data['access'] != null) {
        await _storage.write(key: 'auth_token', value: response.data['access']);
      }
      
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
      await _storage.delete(key: 'auth_token');
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Dashboard methods
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await _dio.get(ApiConstants.dashboard);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getDashboardStats({String period = '7'}) async {
    try {
      final response = await _dio.get(
        ApiConstants.dashboardStats,
        queryParameters: {'period': period},
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> updateGoal({
    required int targetMinutes,
    required int targetQuizzes,
  }) async {
    try {
      final response = await _dio.post(ApiConstants.updateGoal, data: {
        'target_minutes': targetMinutes,
        'target_quizzes': targetQuizzes,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> logActivity({
    required String type,
    int? minutes,
    double? quizScore,
  }) async {
    try {
      final response = await _dio.post(ApiConstants.logActivity, data: {
        'type': type,
        if (minutes != null) 'minutes': minutes,
        if (quizScore != null) 'quiz_score': quizScore,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Study methods
  Future<List<dynamic>> getSubjects() async {
    try {
      final response = await _dio.get(ApiConstants.subjects);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> generateSummary({
    required String input,
    required String inputType,
  }) async {
    try {
      final response = await _dio.post(ApiConstants.generateSummary, data: {
        'input': input,
        'input_type': inputType,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getTodaySummary() async {
    try {
      final response = await _dio.get(ApiConstants.todaySummary);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Quiz methods
  Future<Map<String, dynamic>> generateQuiz({
    required String subject,
    required String difficulty,
    required int count,
  }) async {
    try {
      final response = await _dio.post(ApiConstants.generateQuiz, data: {
        'subject': subject,
        'difficulty': difficulty,
        'count': count,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<List<dynamic>> getQuizList() async {
    try {
      final response = await _dio.get(ApiConstants.quizList);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> startQuiz(String quizId) async {
    try {
      final url = ApiConstants.startQuiz.replaceAll('{id}', quizId);
      final response = await _dio.post(url);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> submitAnswer({
    required String quizId,
    required String answer,
  }) async {
    try {
      final url = ApiConstants.submitAnswer.replaceAll('{id}', quizId);
      final response = await _dio.post(url, data: {
        'answer': answer,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Collaboration methods
  Future<List<dynamic>> getRooms() async {
    try {
      final response = await _dio.get(ApiConstants.rooms);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> createRoom({
    required String title,
    required int subjectId,
    int maxParticipants = 10,
    String? password,
    int timerSeconds = 30,
    int quizCount = 10,
  }) async {
    try {
      final response = await _dio.post(ApiConstants.createRoom, data: {
        'title': title,
        'subject_id': subjectId,
        'max_participants': maxParticipants,
        if (password != null) 'password': password,
        'timer_seconds': timerSeconds,
        'quiz_count': quizCount,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> joinRoom({
    required String roomId,
    String? password,
  }) async {
    try {
      final response = await _dio.post(ApiConstants.joinRoom, data: {
        'room_id': roomId,
        if (password != null) 'password': password,
      });
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  // Stats methods
  Future<Map<String, dynamic>> getStatsOverview() async {
    try {
      final response = await _dio.get(ApiConstants.statsOverview);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getStatsPeriod({String period = '7'}) async {
    try {
      final response = await _dio.get(
        ApiConstants.statsPeriod,
        queryParameters: {'period': period},
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getStatsStrengths() async {
    try {
      final response = await _dio.get(ApiConstants.statsStrengths);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> getStatsPeerComparison() async {
    try {
      final response = await _dio.get(ApiConstants.statsPeerComparison);
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response!.data;
        if (data is Map && data.containsKey('error')) {
          return data['error'];
        }
        if (data is Map && data.containsKey('detail')) {
          return data['detail'];
        }
        return 'Server error: ${error.response!.statusCode}';
      }
      if (error.type == DioExceptionType.connectionTimeout) {
        return 'Connection timeout';
      }
      if (error.type == DioExceptionType.receiveTimeout) {
        return 'Receive timeout';
      }
      if (error.type == DioExceptionType.unknown) {
        return 'Network error: Please check your connection';
      }
    }
    return error.toString();
  }
}