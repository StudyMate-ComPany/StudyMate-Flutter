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
당신은 ${planDetails['subject'] ?? '학습'} 전문 교육 AI입니다.

학습자 프로필:
- 학습 목표: ${planDetails['goal'] ?? '학습 목표 달성'}
- 과목: ${planDetails['subject'] ?? '일반 학습'}
- 수준: ${planDetails['level'] ?? '중급'}
- 학습 기간: ${planDetails['duration_days'] ?? planDetails['duration'] ?? '30'}일
- 학습 유형: ${planDetails['studyType'] ?? '개인 학습'}

커리큘럼 정보:
${_formatCurriculumForPrompt(planDetails['curriculum'])}

당신의 역할:
1. 매일 오전, 오후, 저녁에 맞춤형 학습 콘텐츠 제공
2. 학습자의 목표와 수준을 고려한 체계적인 내용 구성
3. 커리큘럼에 따른 순차적이고 연계성 있는 학습 진행
4. 핵심 내용을 간결하면서도 포괄적으로 요약
5. 이해도를 확인하는 실제적이고 유용한 문제 출제
6. 학생의 진도와 수준에 맞춘 점진적 난이도 조정
7. 구체적이고 실용적인 격려와 동기부여 메시지 제공

응답 형식은 항상 JSON으로 다음 구조를 따라주세요:
{
  "type": "summary" or "quiz",
  "title": "구체적이고 명확한 콘텐츠 제목",
  "content": "상세하고 실용적인 요약 내용 또는 설명",
  "questions": [퀴즈 문제 배열 - quiz 타입인 경우만],
  "encouragement": "개인화된 격려 메시지"
}

quiz 타입의 경우 questions 배열의 각 문제는 다음 형식을 따라주세요:
{
  "question": "명확하고 구체적인 문제",
  "options": ["선택지1", "선택지2", "선택지3", "선택지4"],
  "correct_answer": 정답_인덱스(0-3),
  "explanation": "정답에 대한 자세한 설명과 학습 포인트"
}
''';
  }

  // 커리큘럼 정보를 프롬프트에 맞게 포맷팅
  String _formatCurriculumForPrompt(Map<String, dynamic>? curriculum) {
    if (curriculum == null) return '기본 학습 과정을 따릅니다.';
    
    String formatted = '';
    
    if (curriculum['overview'] != null) {
      formatted += '- 과정 개요: ${curriculum['overview']}\n';
    }
    
    if (curriculum['weekly_breakdown'] != null) {
      formatted += '- 주차별 계획:\n';
      List<dynamic> weeks = curriculum['weekly_breakdown'];
      for (var week in weeks) {
        if (week is Map) {
          formatted += '  ${week['week']}주차: ${week['focus']} (${(week['topics'] as List?)?.join(', ') ?? ''})\n';
        }
      }
    }
    
    if (curriculum['daily_schedule'] != null) {
      Map<String, dynamic> schedule = curriculum['daily_schedule'];
      formatted += '- 일일 스케줄:\n';
      formatted += '  오전: ${schedule['morning'] ?? ''}\n';
      formatted += '  오후: ${schedule['afternoon'] ?? ''}\n';
      formatted += '  저녁: ${schedule['evening'] ?? ''}\n';
    }
    
    return formatted.isEmpty ? '맞춤형 학습 계획을 진행합니다.' : formatted;
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
${_getTimeKorean(timeOfDay)} 학습 콘텐츠를 생성해주세요.

요청 내용:
- 시간대: $timeOfDay (${_getTimeKorean(timeOfDay)})
- 오늘의 주제: $topic
- 콘텐츠 타입: summary (핵심 내용 요약)
- 예상 학습 시간: 10-15분
- 요구사항: 
  * 학습자의 목표와 수준에 맞춘 내용
  * 실제 시험이나 평가에 도움이 되는 핵심 포인트
  * 이해하기 쉬운 설명과 예시
  * 다음 학습으로 연결되는 내용

학습자가 집중할 수 있도록 명확하고 구조화된 내용으로 작성해주세요.
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
${_getTimeKorean(timeOfDay)} 학습 문제를 생성해주세요.

요청 내용:
- 시간대: $timeOfDay (${_getTimeKorean(timeOfDay)})
- 오늘의 주제: $topic
- 콘텐츠 타입: quiz (문제 풀이)
- 문제 개수: $questionCount개
- 문제 형태: 4지선다형
- 난이도: 학습자의 현재 수준(${_getTimeKorean(timeOfDay)} 시간대에 적합)
- 요구사항:
  * 실제 시험이나 평가에서 나올 수 있는 실용적인 문제
  * 오늘 학습한 내용과 연관성 있는 문제
  * 각 문제마다 상세한 해설과 학습 포인트 제공
  * 오답 선택지도 교육적 가치가 있도록 구성
  * 난이도는 점진적으로 증가

학습자가 실력을 확실히 점검할 수 있는 양질의 문제를 만들어주세요.
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
        'model': 'gpt-4',
        'messages': messages,
        'temperature': 0.7,
        'max_completion_tokens': 1000,
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