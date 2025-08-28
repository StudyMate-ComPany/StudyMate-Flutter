import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatGPTSessionService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _sessionKeyPrefix = 'chatgpt_session_';
  
  final String apiKey;
  final Map<String, List<Map<String, dynamic>>> _sessions = {};
  
  ChatGPTSessionService({required this.apiKey});
  
  // 학습 플랜별 세션 초기화
  Future<void> initializeSession(String planId, Map<String, dynamic> planDetails) async {
    final systemPrompt = _generateSystemPrompt(planDetails);
    
    _sessions[planId] = [
      {
        'role': 'system',
        'content': systemPrompt,
      }
    ];
    
    // 로컬 스토리지에 저장
    await _saveSession(planId);
  }
  
  // 시스템 프롬프트 생성
  String _generateSystemPrompt(Map<String, dynamic> planDetails) {
    return '''
당신은 ${planDetails['subject']} 전문 교육 AI입니다.
학생의 목표: ${planDetails['goal']}
현재 수준: ${planDetails['level']}
학습 기간: ${planDetails['duration']}일
학습 유형: ${planDetails['studyType']}

당신의 역할:
1. 매일 오전, 오후, 저녁에 맞춤형 학습 콘텐츠 제공
2. 핵심 내용을 간결하게 요약
3. 이해도를 확인하는 문제 출제
4. 학생의 진도와 수준에 맞춘 점진적 난이도 조정
5. 격려와 동기부여 메시지 포함

응답 형식은 항상 JSON으로 다음 구조를 따라주세요:
{
  "type": "summary" or "quiz",
  "title": "콘텐츠 제목",
  "content": "요약 내용 또는 설명",
  "questions": [퀴즈 문제 배열 - quiz 타입인 경우],
  "encouragement": "격려 메시지"
}
''';
  }
  
  // 요약본 생성 요청
  Future<Map<String, dynamic>> generateSummary(
    String planId,
    String topic,
    String timeOfDay,
  ) async {
    final session = _sessions[planId] ?? [];
    
    final userMessage = {
      'role': 'user',
      'content': '''
$timeOfDay 학습 콘텐츠를 생성해주세요.
오늘의 주제: $topic
타입: summary (핵심 내용 요약)
분량: 5-10분 분량으로 읽을 수 있는 내용
'''
    };
    
    session.add(userMessage);
    
    try {
      final response = await _sendChatGPTRequest(session);
      
      // 세션에 응답 추가
      session.add({
        'role': 'assistant',
        'content': response,
      });
      
      await _saveSession(planId);
      
      return json.decode(response);
    } catch (e) {
      print('요약본 생성 실패: $e');
      return _generateMockSummary(topic, timeOfDay);
    }
  }
  
  // 문제 생성 요청
  Future<Map<String, dynamic>> generateQuiz(
    String planId,
    String topic,
    String timeOfDay,
    int questionCount,
  ) async {
    final session = _sessions[planId] ?? [];
    
    final userMessage = {
      'role': 'user',
      'content': '''
$timeOfDay 학습 문제를 생성해주세요.
오늘의 주제: $topic
타입: quiz
문제 개수: $questionCount개
난이도: 학생의 현재 수준에 맞춰서
각 문제는 4지선다형으로, 정답과 해설을 포함해주세요.
'''
    };
    
    session.add(userMessage);
    
    try {
      final response = await _sendChatGPTRequest(session);
      
      session.add({
        'role': 'assistant',
        'content': response,
      });
      
      await _saveSession(planId);
      
      return json.decode(response);
    } catch (e) {
      print('문제 생성 실패: $e');
      return _generateMockQuiz(topic, timeOfDay, questionCount);
    }
  }
  
  // ChatGPT API 호출
  Future<String> _sendChatGPTRequest(List<Map<String, dynamic>> messages) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'model': 'gpt-4-turbo-preview',
        'messages': messages,
        'temperature': 0.7,
        'max_tokens': 1000,
        'response_format': {'type': 'json_object'},
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('ChatGPT API 오류: ${response.statusCode}');
    }
  }
  
  // 세션 저장
  Future<void> _saveSession(String planId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = json.encode(_sessions[planId]);
    await prefs.setString('$_sessionKeyPrefix$planId', sessionData);
  }
  
  // 세션 로드
  Future<void> loadSession(String planId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionData = prefs.getString('$_sessionKeyPrefix$planId');
    
    if (sessionData != null) {
      _sessions[planId] = List<Map<String, dynamic>>.from(
        json.decode(sessionData),
      );
    }
  }
  
  // 세션 초기화
  void clearSession(String planId) {
    _sessions.remove(planId);
  }
  
  // Mock 데이터 생성 (API 실패 시 대체)
  Map<String, dynamic> _generateMockSummary(String topic, String timeOfDay) {
    final timeKorean = _getTimeKorean(timeOfDay);
    
    return {
      'type': 'summary',
      'title': '$topic - $timeKorean 핵심 요약',
      'content': '''
📚 오늘의 학습 포인트

1. 핵심 개념 정리
   - $topic의 기본 원리를 이해합니다
   - 관련 용어와 정의를 숙지합니다
   
2. 주요 내용
   - 기본 개념과 응용 방법
   - 실제 문제에서의 적용 사례
   - 자주 출제되는 유형 파악
   
3. 학습 팁
   - 반복 학습을 통한 암기
   - 문제 풀이를 통한 응용력 향상
   - 오답 노트 정리의 중요성

💡 기억할 점: 꾸준한 학습이 가장 중요합니다!
''',
      'encouragement': '오늘도 열심히 공부하는 당신, 정말 대단해요! 🎯',
    };
  }
  
  Map<String, dynamic> _generateMockQuiz(String topic, String timeOfDay, int count) {
    final timeKorean = _getTimeKorean(timeOfDay);
    
    final questions = List.generate(count, (index) => {
      'id': 'q_${index + 1}',
      'question': '$topic 관련 문제 ${index + 1}: 다음 중 옳은 것은?',
      'options': [
        '첫 번째 선택지',
        '두 번째 선택지',
        '세 번째 선택지',
        '네 번째 선택지',
      ],
      'correct_answer': index % 4,
      'explanation': '이 문제의 정답은 ${(index % 4) + 1}번입니다. 핵심 개념을 이해하면 쉽게 풀 수 있습니다.',
    });
    
    return {
      'type': 'quiz',
      'title': '$topic - $timeKorean 확인 문제',
      'content': '오늘 학습한 내용을 확인해보세요!',
      'questions': questions,
      'encouragement': '문제를 풀면서 실력이 향상되고 있어요! 💪',
    };
  }
  
  String _getTimeKorean(String timeOfDay) {
    switch (timeOfDay.toLowerCase()) {
      case 'morning':
        return '오전';
      case 'afternoon':
        return '오후';
      case 'evening':
        return '저녁';
      default:
        return timeOfDay;
    }
  }
}