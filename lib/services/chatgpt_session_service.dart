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
  
  // 요약본 생성 요청 (재시도 로직 포함)
  Future<Map<String, dynamic>> generateSummary(
    String planId,
    String topic,
    String timeOfDay,
  ) async {
    print('📖 요약본 생성 중: $topic ($timeOfDay)');
    
    // 세션에 사용자 요청 추가
    final session = _sessions[planId] ?? [];
    session.add({
      'role': 'user',
      'content': '${_getTimeKorean(timeOfDay)} $topic 학습 콘텐츠 요청',
    });
    
    try {
      // API 호출 (재시도 로직 포함)
      final response = await _sendChatGPTRequest(session);
      final responseData = json.decode(response);
      
      // 세션에 응답 추가
      session.add({
        'role': 'assistant',
        'content': response,
      });
      
      await _saveSession(planId);
      
      print('✅ 요약본 생성 완료');
      return responseData;
    } catch (e) {
      print('❌ 요약본 생성 실패: $e');
      // 세션에서 실패한 사용자 요청 제거
      if (session.isNotEmpty && session.last['role'] == 'user') {
        session.removeLast();
      }
      throw Exception('요약본 생성에 실패했습니다: $e');
    }
  }
  
  // 문제 생성 요청 (재시도 로직 포함)
  Future<Map<String, dynamic>> generateQuiz(
    String planId,
    String topic,
    String timeOfDay,
    int questionCount,
  ) async {
    print('❓ 퀴즈 생성 중: $topic ($timeOfDay, ${questionCount}문제)');
    
    // 세션에 사용자 요청 추가
    final session = _sessions[planId] ?? [];
    session.add({
      'role': 'user',
      'content': '${_getTimeKorean(timeOfDay)} $topic 퀴즈 ${questionCount}문제 요청',
    });
    
    try {
      // API 호출 (재시도 로직 포함)
      final response = await _sendChatGPTRequest(session);
      final responseData = json.decode(response);
      
      // 세션에 응답 추가
      session.add({
        'role': 'assistant',
        'content': response,
      });
      
      await _saveSession(planId);
      
      print('✅ 퀴즈 생성 완료');
      return responseData;
    } catch (e) {
      print('❌ 퀴즈 생성 실패: $e');
      // 세션에서 실패한 사용자 요청 제거
      if (session.isNotEmpty && session.last['role'] == 'user') {
        session.removeLast();
      }
      throw Exception('퀴즈 생성에 실패했습니다: $e');
    }
  }
  
  // ChatGPT API 호출 (재시도 로직 포함)
  Future<String> _sendChatGPTRequest(List<Map<String, dynamic>> messages) async {
    // API 키 유효성 검사
    if (apiKey.isEmpty || apiKey == 'YOUR_OPENAI_API_KEY') {
      throw Exception('유효하지 않은 API 키입니다. API 키를 확인해주세요.');
    }
    
    const maxRetries = 3;
    const baseDelay = 1000; // 1초
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('🔄 ChatGPT API 호출 시도 $attempt/$maxRetries');
        
        final response = await http.post(
          Uri.parse('$_baseUrl/chat/completions'),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'model': 'gpt-5-nano',
            'messages': messages,
            'temperature': 1,
            'max_completion_tokens': 1000,
            'response_format': {'type': 'json_object'},
          }),
        );
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final content = data['choices'][0]['message']['content'];
          print('✅ ChatGPT API 호출 성공! (시도 $attempt/$maxRetries)');
          return content;
        }
        
        // HTTP 에러 처리
        final shouldRetry = _shouldRetryHttpError(response.statusCode);
        if (!shouldRetry) {
          throw Exception('ChatGPT API 오류 (재시도 불가): ${response.statusCode} - ${response.body}');
        }
        
        if (attempt == maxRetries) {
          throw Exception('ChatGPT API 오류 (최대 재시도 횟수 초과): ${response.statusCode} - ${response.body}');
        }
        
        // Exponential backoff: 1초, 2초, 3초
        final delay = baseDelay * attempt;
        print('🔄 ${delay}ms 후 재시도합니다... (${attempt + 1}/$maxRetries)');
        await Future.delayed(Duration(milliseconds: delay));
        
      } catch (e) {
        print('❌ ChatGPT API 호출 실패 (시도 $attempt/$maxRetries): $e');
        
        if (attempt == maxRetries) {
          throw Exception('ChatGPT API 호출 실패 (최대 재시도 횟수 초과): $e');
        }
        
        // 네트워크 오류인 경우 재시도
        final delay = baseDelay * attempt;
        print('🔄 ${delay}ms 후 재시도합니다... (${attempt + 1}/$maxRetries)');
        await Future.delayed(Duration(milliseconds: delay));
      }
    }
    
    throw Exception('예상치 못한 오류가 발생했습니다.');
  }
  
  /// HTTP 에러 코드에 따른 재시도 여부 결정
  bool _shouldRetryHttpError(int statusCode) {
    switch (statusCode) {
      case 429: // Too Many Requests
      case 500: // Internal Server Error
      case 502: // Bad Gateway
      case 503: // Service Unavailable
      case 504: // Gateway Timeout
        return true;
      case 400: // Bad Request
      case 401: // Unauthorized
      case 403: // Forbidden
      case 404: // Not Found
        return false;
      default:
        return statusCode >= 500; // 5xx 에러는 재시도 가능
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