import 'package:flutter/foundation.dart';
import '../models/ai_response.dart';
import '../services/api_service.dart';
import '../services/chatgpt_service.dart';

enum AIState { idle, loading, loaded, error }

class AIProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final ChatGPTService _chatGPTService = ChatGPTService();
  
  AIState _state = AIState.idle;
  List<AIResponse> _history = [];
  AIResponse? _currentResponse;
  String? _errorMessage;

  AIState get state => _state;
  List<AIResponse> get history => _history;
  AIResponse? get currentResponse => _currentResponse;
  String? get errorMessage => _errorMessage;

  Future<void> loadHistory({int limit = 50}) async {
    try {
      _setState(AIState.loading);
      _history = await _apiService.getAIHistory(limit: limit);
      _setState(AIState.loaded);
    } catch (e) {
      _setError('AI 기록을 불러오는데 실패했습니다: $e');
    }
  }

  Future<AIResponse?> askQuestion(
    String question, {
    AIResponseType type = AIResponseType.explanation,
    Map<String, dynamic>? context,
  }) async {
    try {
      _setState(AIState.loading);
      
      print('\n' + '🌟' * 30);
      print('🤖 AIProvider.askQuestion 호출됨!');
      print('질문: "$question"');
      print('타입: $type');
      print('컨텍스트: $context');
      print('🌟' * 30);
      
      // ChatGPT 직접 호출로 변경 - 타입에 따라 다른 메서드 호출
      Map<String, dynamic> result;
      String responseText = '';
      
      if (type == AIResponseType.quiz) {
        // 퀴즈 생성
        result = await _chatGPTService.generateQuizQuestions(
          subject: context?['subject'] ?? '일반',
          topic: context?['topic'] ?? question,
          count: context?['count'] ?? 5,
        );
        responseText = '퀴즈가 생성되었습니다.';
      } else if (type == AIResponseType.studyPlan) {
        // 학습 계획 생성
        result = await _chatGPTService.generateStudyPlan(
          subject: context?['subject'] ?? question,
          goal: context?['goal'] ?? '$question 마스터',
          daysAvailable: context?['days'] ?? 30,
        );
        responseText = '학습 계획이 생성되었습니다.';
      } else if (type == AIResponseType.explanation) {
        // 개념 설명
        result = await _chatGPTService.explainTopic(
          subject: context?['subject'] ?? question,
          topic: question,
          level: context?['level'] ?? 'intermediate',
        );
        if (result['success'] == true) {
          responseText = result['explanation'] ?? '설명을 생성했습니다.';
        }
      } else {
        // 일반 질문 - 사용자 입력 분석 또는 일반 대화
        result = await _chatGPTService.analyzeUserInput(question);
        if (result['success'] == true) {
          final analysis = result['analysis'] ?? {};
          responseText = '분석 결과:\n'
              '📚 과목: ${analysis['subject'] ?? '일반'}\n'
              '🎯 목표: ${analysis['goal'] ?? question}\n'
              '📅 기간: ${analysis['daysAvailable'] ?? 30}일\n'
              '📊 수준: ${analysis['currentLevel'] ?? 'beginner'}';
        }
      }
      
      AIResponse response;
      if (result['success'] == true) {
        // ChatGPT 응답을 AIResponse 형태로 변환
        response = AIResponse(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'user',
          type: type,
          query: question,
          response: responseText,
          confidence: result['usingMock'] == true ? 0.7 : 0.95,
          metadata: result['analysis'] ?? result,
          createdAt: DateTime.now(),
        );
        
        debugPrint('✅ ChatGPT 응답 성공 (모의: ${result['usingMock'] == true})');
      } else {
        // 에러 발생 시 기본 응답
        response = AIResponse(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'user',
          type: type,
          query: question,
          response: '죄송합니다. 응답을 생성할 수 없습니다: ${result['error']}',
          confidence: 0.0,
          createdAt: DateTime.now(),
        );
        
        debugPrint('❌ ChatGPT 응답 실패: ${result['error']}');
      }
      
      _currentResponse = response;
      _history.insert(0, response);
      
      _setState(AIState.loaded);
      return response;
    } catch (e) {
      _setError('AI 응답을 받는데 실패했습니다: $e');
      return null;
    }
  }

  Future<AIResponse?> getStudyPlan({
    required String subject,
    String? currentLevel,
    String? timeAvailable,
    List<String>? specificTopics,
    String? learningStyle,
  }) async {
    try {
      _setState(AIState.loading);
      
      debugPrint('🚀 ChatGPT로 학습 계획 생성: $subject');
      
      // ChatGPT 직접 호출로 학습 계획 생성
      final days = _parseDaysFromTimeAvailable(timeAvailable);
      final result = await _chatGPTService.generateStudyPlan(
        subject: subject,
        goal: '${subject} 마스터',
        daysAvailable: days,
        currentLevel: currentLevel ?? 'beginner',
        hoursPerDay: 2,
      );
      
      AIResponse response;
      if (result['success'] == true) {
        final plan = result['studyPlan'] ?? {};
        
        response = AIResponse(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'user',
          type: AIResponseType.studyPlan,
          query: 'Create a study plan for $subject',
          response: '학습 계획이 생성되었습니다.',
          confidence: 0.95,
          metadata: plan,
          createdAt: DateTime.now(),
        );
        
        debugPrint('✅ 학습 계획 생성 성공');
      } else {
        response = AIResponse(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'user',
          type: AIResponseType.studyPlan,
          query: 'Create a study plan for $subject',
          response: '학습 계획 생성 실패: ${result['error']}',
          confidence: 0.0,
          createdAt: DateTime.now(),
        );
        
        debugPrint('❌ 학습 계획 생성 실패');
      }
      
      _currentResponse = response;
      _history.insert(0, response);
      _setState(AIState.loaded);
      return response;
    } catch (e) {
      _setError('학습 계획 생성 실패: $e');
      return null;
    }
  }
  
  int _parseDaysFromTimeAvailable(String? timeAvailable) {
    if (timeAvailable == null) return 30;
    
    final lower = timeAvailable.toLowerCase();
    if (lower.contains('week')) {
      final match = RegExp(r'(\d+)').firstMatch(lower);
      if (match != null) return int.parse(match.group(1)!) * 7;
    } else if (lower.contains('month')) {
      final match = RegExp(r'(\d+)').firstMatch(lower);
      if (match != null) return int.parse(match.group(1)!) * 30;
    } else if (lower.contains('year')) {
      final match = RegExp(r'(\d+)').firstMatch(lower);
      if (match != null) return int.parse(match.group(1)!) * 365;
    } else if (lower.contains('day')) {
      final match = RegExp(r'(\d+)').firstMatch(lower);
      if (match != null) return int.parse(match.group(1)!);
    }
    
    return 30; // 기본값 30일
  }

  Future<AIResponse?> generateQuiz({
    required String subject,
    String? topic,
    int questionCount = 5,
    String? difficulty,
  }) async {
    try {
      _setState(AIState.loading);
      
      // ChatGPT를 사용하여 문제 생성
      final result = await _chatGPTService.generateQuizQuestions(
        subject: subject,
        topic: topic ?? subject,
        count: questionCount,
        difficulty: difficulty ?? 'medium',
      );
      
      if (result['success'] == true) {
        // AIResponse 형식으로 변환
        final response = AIResponse(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'current_user', // TODO: Get actual user ID from auth provider
          query: 'Generate a $questionCount-question quiz about $subject'
              '${topic != null ? ' focusing on $topic' : ''}'
              '${difficulty != null ? ' at $difficulty difficulty' : ''}.',
          response: 'Quiz generated successfully',
          type: AIResponseType.quiz,
          createdAt: DateTime.now(),
          metadata: {
            'questions': result['questions'],
            'metadata': result['metadata'],
          },
          tags: [subject, topic ?? '', 'quiz', difficulty ?? 'medium'].where((s) => s.isNotEmpty).toList(),
        );
        
        _currentResponse = response;
        _history.insert(0, response);
        _setState(AIState.loaded);
        return response;
      } else {
        _setError(result['error'] ?? 'Failed to generate quiz');
        return null;
      }
    } catch (e) {
      _setError('AI 응답을 받는데 실패했습니다: $e');
      return null;
    }
  }

  Future<AIResponse?> explainConcept({
    required String concept,
    String? subject,
    String? level,
  }) async {
    try {
      _setState(AIState.loading);
      
      debugPrint('🚀 ChatGPT로 개념 설명: $concept');
      
      // ChatGPT 직접 호출로 개념 설명 생성
      final result = await _chatGPTService.explainTopic(
        subject: subject ?? concept,
        topic: concept,
        level: level ?? 'intermediate',
      );
      
      AIResponse response;
      if (result['success'] == true) {
        final explanation = result['explanation'] ?? '';
        final examples = result['examples'] ?? [];
        final keyPoints = result['keyPoints'] ?? [];
        
        String fullExplanation = explanation;
        if (examples.isNotEmpty) {
          fullExplanation += '\n\n📌 예시:\n';
          for (var example in examples) {
            fullExplanation += '• $example\n';
          }
        }
        if (keyPoints.isNotEmpty) {
          fullExplanation += '\n\n🔑 핵심 포인트:\n';
          for (var point in keyPoints) {
            fullExplanation += '• $point\n';
          }
        }
        
        response = AIResponse(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'user',
          type: AIResponseType.explanation,
          query: 'Explain $concept',
          response: fullExplanation,
          confidence: 0.95,
          metadata: result,
          createdAt: DateTime.now(),
        );
        
        debugPrint('✅ 개념 설명 생성 성공');
      } else {
        response = AIResponse(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'user',
          type: AIResponseType.explanation,
          query: 'Explain $concept',
          response: '개념 설명 생성 실패: ${result['error']}',
          confidence: 0.0,
          createdAt: DateTime.now(),
        );
        
        debugPrint('❌ 개념 설명 생성 실패');
      }
      
      _currentResponse = response;
      _history.insert(0, response);
      _setState(AIState.loaded);
      return response;
    } catch (e) {
      _setError('개념 설명 생성 실패: $e');
      return null;
    }
  }

  Future<AIResponse?> getStudyRecommendations({
    required Map<String, dynamic> studyHistory,
    List<String>? weakAreas,
    String? goals,
  }) async {
    final context = {
      'study_history': studyHistory,
      'weak_areas': weakAreas,
      'goals': goals,
    };

    final query = 'Based on my study history and performance, '
        'provide personalized study recommendations'
        '${weakAreas != null && weakAreas.isNotEmpty ? ' focusing on ${weakAreas.join(", ")}' : ''}'
        '${goals != null ? ' to achieve: $goals' : ''}.';

    return await askQuestion(
      query,
      type: AIResponseType.recommendation,
      context: context,
    );
  }

  Future<AIResponse?> getStudyFeedback({
    required Map<String, dynamic> sessionData,
    String? specificFeedback,
  }) async {
    final context = {
      'session_data': sessionData,
      'specific_feedback': specificFeedback,
    };

    final query = 'Analyze my study session and provide feedback on my performance'
        '${specificFeedback != null ? ' with focus on: $specificFeedback' : ''}.';

    return await askQuestion(
      query,
      type: AIResponseType.feedback,
      context: context,
    );
  }

  List<AIResponse> getResponsesByType(AIResponseType type) {
    return _history.where((response) => response.type == type).toList();
  }

  List<AIResponse> searchHistory(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _history.where((response) {
      return response.query.toLowerCase().contains(lowercaseQuery) ||
             response.response.toLowerCase().contains(lowercaseQuery) ||
             (response.tags?.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) ?? false);
    }).toList();
  }

  void clearCurrentResponse() {
    _currentResponse = null;
    _setState(AIState.idle);
  }

  void clearHistory() {
    _history.clear();
    _currentResponse = null;
    _setState(AIState.idle);
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AIState.error) {
      _setState(_history.isNotEmpty ? AIState.loaded : AIState.idle);
    }
  }

  void _setState(AIState newState) {
    _state = newState;
    if (newState != AIState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _state = AIState.error;
    notifyListeners();
  }

  // Convenience getters for quick access to different types of responses
  List<AIResponse> get studyPlans => getResponsesByType(AIResponseType.studyPlan);
  List<AIResponse> get quizzes => getResponsesByType(AIResponseType.quiz);
  List<AIResponse> get explanations => getResponsesByType(AIResponseType.explanation);
  List<AIResponse> get recommendations => getResponsesByType(AIResponseType.recommendation);
  List<AIResponse> get feedback => getResponsesByType(AIResponseType.feedback);
}