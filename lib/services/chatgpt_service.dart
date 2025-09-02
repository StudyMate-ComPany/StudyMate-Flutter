import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatGPTService {
  static final ChatGPTService _instance = ChatGPTService._internal();
  factory ChatGPTService() => _instance;
  ChatGPTService._internal();

  final Dio _dio = Dio();
  
  // EC2 서버를 통한 API 호출 설정
  static const String _apiUrl = 'http://54.161.77.144/api/ai/chat';
  static String get _apiKey => 'not_needed_for_server';
  
  /// 학습 문제 생성
  Future<Map<String, dynamic>> generateQuizQuestions({
    required String subject,
    required String topic,
    required int count,
    String difficulty = 'medium',
    String language = 'korean',
  }) async {
    try {
      final prompt = '''
다음 조건에 맞는 학습 문제를 생성해주세요:
- 과목: $subject
- 주제: $topic
- 문제 수: $count
- 난이도: $difficulty
- 언어: 한국어

각 문제는 다음 형식으로 JSON 배열로 반환해주세요:
[
  {
    "question": "문제 내용",
    "type": "multiple_choice" 또는 "short_answer" 또는 "true_false",
    "options": ["선택지1", "선택지2", "선택지3", "선택지4"] (객관식인 경우),
    "answer": "정답",
    "explanation": "해설",
    "difficulty": "$difficulty",
    "points": 10
  }
]

다양한 유형의 문제를 섞어서 만들어주세요.
''';

      final response = await _sendRequest(prompt);
      
      // JSON 파싱
      try {
        final jsonString = _extractJsonFromResponse(response);
        final questions = json.decode(jsonString) as List;
        
        return {
          'success': true,
          'questions': questions,
          'metadata': {
            'subject': subject,
            'topic': topic,
            'count': questions.length,
            'difficulty': difficulty,
            'generatedAt': DateTime.now().toIso8601String(),
          }
        };
      } catch (e) {
        debugPrint('JSON 파싱 에러: $e');
        return {
          'success': false,
          'error': 'Failed to parse quiz questions',
          'raw_response': response,
        };
      }
    } catch (e) {
      debugPrint('ChatGPT 에러: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// 사용자 입력 분석 (과목, 수준, 기간 등 추출)
  Future<Map<String, dynamic>> analyzeUserInput(String userInput) async {
    try {
      print('\n' + '=' * 60);
      print('🔍 ChatGPTService.analyzeUserInput 호출됨!');
      print('입력값: "$userInput"');
      
      // API 키 상태 확인
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      print('🔑 API 키 체크:');
      print('  - 키 존재: ${apiKey != null}');
      print('  - 키 길이: ${apiKey?.length ?? 0}');
      print('  - 키 시작: ${apiKey != null && apiKey.length > 20 ? apiKey.substring(0, 20) : "없음"}');
      
      print('=' * 60);
      
      // 입력 유효성 검사
      if (!_isValidStudyRequest(userInput)) {
        print('❌ 유효성 검사 실패 - 학습과 무관한 입력');
        return {
          'success': false,
          'error': 'Invalid study request',
          'message': '학습과 관련된 요청을 입력해주세요.',
        };
      }
      
      final prompt = '''
You are an AI that analyzes user input for creating personalized study plans.
Be VERY flexible and understand various expressions in Korean, English, and mixed languages.

User input: "$userInput"

CRITICAL PARSING RULES:

1. Subject Recognition (과목 인식):
   - "koreahistory", "korean history", "한국사" → subject: "한국사"
   - "toeic", "토익" → subject: "TOEIC"
   - "english", "영어" → subject: "영어"
   - "math", "수학" → subject: "수학"
   - Extract ONLY the subject name, not the entire phrase

2. Level/Grade Recognition (수준 인식):
   - "first grade", "1급" → level 1 certification
   - "beginner", "초급" → beginner level
   - "intermediate", "중급" → intermediate level
   - "advanced", "고급" → advanced level
   - "900 point", "900점" → target score

3. Duration Recognition (기간 인식):
   - "three year", "3년" → 1095 days
   - "two month", "2개월" → 60 days
   - "six month", "6개월" → 180 days
   - Convert all time periods to days

Examples:
- "koreahistory first grade three year" → 
  subject: "한국사", goal: "한국사 1급 합격", daysAvailable: 1095
- "toeic 900 point two month" → 
  subject: "TOEIC", goal: "TOEIC 900점 달성", daysAvailable: 60
- "아니다 토익 900점 3년안에" → 
  subject: "TOEIC", goal: "TOEIC 900점 달성", daysAvailable: 1095

IMPORTANT: Extract subjects, goals, and durations separately. Do NOT use the entire input string as the subject!

5. Study types:
   - Test/exam related → "exam_prep"
   - Certificate/license → "certification"
   - Hobby/casual → "hobby"
   - Professional/career → "professional"
   - Default → "general"

Return as JSON:
{
  "subject": "extracted subject name",
  "topic": "specific topic or same as subject",
  "goal": "specific extracted goal, NOT the entire input",
  "currentLevel": "beginner/intermediate/advanced",
  "daysAvailable": number (converted to days),
  "hoursPerDay": number (default 2),
  "studyType": "type of study",
  "additionalInfo": "any other relevant info"
}
''';

      print('\n📤 OpenAI API 호출 시도...');
      print('프롬프트 길이: ${prompt.length}자');
      final response = await _sendRequest(prompt);
      print('📥 응답 받음: ${response.substring(0, 100 < response.length ? 100 : response.length)}...');
      
      try {
        final jsonString = _extractJsonFromResponse(response);
        final analysis = json.decode(jsonString);
        debugPrint('✅ 분석 결과: $analysis');
        
        return {
          'success': true,
          'analysis': analysis,
        };
      } catch (e) {
        debugPrint('❌ JSON 파싱 실패: $e');
        return {
          'success': false,
          'error': 'Failed to parse analysis',
          'raw_response': response,
        };
      }
    } catch (e) {
      print('\n⚠️ ChatGPT API 호출 중 예외 발생!');
      print('에러: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// 학습 계획 생성
  Future<Map<String, dynamic>> generateStudyPlan({
    required String subject,
    required String goal,
    required int daysAvailable,
    String currentLevel = 'beginner',
    int hoursPerDay = 2,
  }) async {
    try {
      final prompt = '''
다음 조건에 맞는 맞춤형 학습 계획을 생성해주세요:
- 과목: $subject
- 목표: $goal
- 기간: $daysAvailable일
- 현재 수준: $currentLevel
- 하루 학습 시간: $hoursPerDay시간

다음 형식의 JSON으로 반환해주세요:
{
  "title": "학습 계획 제목",
  "overview": "계획 개요",
  "totalDays": $daysAvailable,
  "hoursPerDay": $hoursPerDay,
  "schedule": [
    {
      "day": 1,
      "date": "2024-01-01",
      "topics": ["주제1", "주제2"],
      "activities": [
        {
          "time": "09:00-10:00",
          "activity": "활동 내용",
          "type": "lecture/practice/quiz/review"
        }
      ],
      "goals": ["목표1", "목표2"],
      "resources": ["자료1", "자료2"]
    }
  ],
  "milestones": [
    {
      "day": 7,
      "title": "첫 주 마일스톤",
      "description": "달성해야 할 목표"
    }
  ],
  "tips": ["학습 팁1", "학습 팁2"]
}
''';

      final response = await _sendRequest(prompt);
      
      try {
        final jsonString = _extractJsonFromResponse(response);
        final studyPlan = json.decode(jsonString);
        
        return {
          'success': true,
          'studyPlan': studyPlan,
          'metadata': {
            'subject': subject,
            'goal': goal,
            'generatedAt': DateTime.now().toIso8601String(),
          }
        };
      } catch (e) {
        debugPrint('JSON 파싱 에러: $e');
        return {
          'success': false,
          'error': 'Failed to parse study plan',
          'raw_response': response,
        };
      }
    } catch (e) {
      debugPrint('ChatGPT 에러: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// 학습 내용 설명 생성
  Future<Map<String, dynamic>> explainTopic({
    required String subject,
    required String topic,
    String level = 'intermediate',
    bool includeExamples = true,
  }) async {
    try {
      final prompt = '''
$subject 과목의 "$topic"에 대해 $level 수준으로 설명해주세요.

다음 형식의 JSON으로 반환해주세요:
{
  "topic": "$topic",
  "summary": "한 문장 요약",
  "explanation": "상세 설명 (단락 구분)",
  "keyPoints": ["핵심 포인트1", "핵심 포인트2"],
  "examples": ${includeExamples ? '[{"title": "예제 제목", "content": "예제 내용", "solution": "해답"}]' : 'null'},
  "commonMistakes": ["흔한 실수1", "흔한 실수2"],
  "relatedTopics": ["관련 주제1", "관련 주제2"],
  "practiceQuestions": [
    {
      "question": "연습 문제",
      "hint": "힌트",
      "answer": "답"
    }
  ]
}

한국어로 작성하고, 이해하기 쉽게 설명해주세요.
''';

      final response = await _sendRequest(prompt);
      
      try {
        final jsonString = _extractJsonFromResponse(response);
        final explanation = json.decode(jsonString);
        
        return {
          'success': true,
          'explanation': explanation,
          'metadata': {
            'subject': subject,
            'topic': topic,
            'level': level,
            'generatedAt': DateTime.now().toIso8601String(),
          }
        };
      } catch (e) {
        debugPrint('JSON 파싱 에러: $e');
        return {
          'success': false,
          'error': 'Failed to parse explanation',
          'raw_response': response,
        };
      }
    } catch (e) {
      debugPrint('ChatGPT 에러: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// 사용자 입력을 분석하여 자동으로 학습 계획 생성
  Future<Map<String, dynamic>> generateAdaptiveStudyPlan(String userInput) async {
    try {
      // 1단계: 사용자 입력 분석
      final analysisResult = await analyzeUserInput(userInput);
      
      if (!analysisResult['success']) {
        return analysisResult;
      }
      
      final analysis = analysisResult['analysis'];
      
      // 2단계: 분석된 정보로 학습 계획 생성
      return await generateStudyPlan(
        subject: analysis['subject'] ?? '일반 학습',
        goal: analysis['goal'] ?? userInput,
        daysAvailable: analysis['daysAvailable'] ?? 30,
        currentLevel: analysis['currentLevel'] ?? 'beginner',
        hoursPerDay: analysis['hoursPerDay'] ?? 2,
      );
    } catch (e) {
      debugPrint('적응형 학습 계획 생성 에러: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// 일반 질문 응답
  Future<String> askQuestion(String question, {String? context}) async {
    try {
      final prompt = context != null 
        ? 'Context: $context\n\nQuestion: $question\n\n한국어로 답변해주세요.'
        : '$question\n\n한국어로 답변해주세요.';
      
      return await _sendRequest(prompt);
    } catch (e) {
      debugPrint('ChatGPT 에러: $e');
      return '죄송합니다. 응답을 생성하는데 실패했습니다: $e';
    }
  }

  /// OpenAI API 요청 전송 (재시도 로직 포함)
  Future<String> _sendRequest(String prompt, {String model = 'gpt-5-nano'}) async {
    print('\n' + '━' * 60);
    print('🚀 _sendRequest 호출 - OpenAI API 직접 호출 시도');
    print('모델: $model');
    
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    print('🔑 API 키 상태:');
    print('  - 존재 여부: ${apiKey.isNotEmpty}');
    if (apiKey.isNotEmpty) {
      print('  - 키 시작: ${apiKey.substring(0, 30 > apiKey.length ? apiKey.length : 30)}...');
      print('  - 키 길이: ${apiKey.length}자');
    }
    
    // API 키 유효성 검증
    if (apiKey.isEmpty || 
        apiKey == 'YOUR_OPENAI_API_KEY' || 
        !apiKey.startsWith('sk-') ||
        apiKey.length < 50) {
      print('\n❌ 유효하지 않은 API 키 발견!');
      print('  - 키 비어있음: ${apiKey.isEmpty}');
      print('  - 기본값: ${apiKey == 'YOUR_OPENAI_API_KEY'}');
      print('  - sk- 시작 안함: ${!apiKey.startsWith('sk-')}');
      print('  - 길이 부족: ${apiKey.length < 50}');
      throw Exception('유효하지 않은 API 키입니다. .env 파일을 확인해주세요.');
    }
    
    print('✅ API 키 확인 완료 - 실제 OpenAI API 호출 진행');
    print('━' * 60);

    // 재시도 로직 구현
    const maxRetries = 3;
    const baseDelay = 1000; // 1초
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('\n📡 API 호출 시도 $attempt/$maxRetries');
        print('URL: $_apiUrl');
        print('Model: $model');
        
        final response = await _dio.post(
          _apiUrl,
          options: Options(
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
          ),
          data: {
            'model': model,
            'messages': [
              {
                'role': 'system',
                'content': '''You are StudyMate, an intelligent learning assistant that understands natural language flexibly.

CORE CAPABILITIES:
1. Understand mixed Korean/English input naturally
2. Extract learning intentions from casual, informal expressions
3. Recognize all variations of subjects, time periods, and goals
4. Never ask for clarification - always infer intelligently

LANGUAGE UNDERSTANDING:
- "koreahistory" = "Korean History" = "한국사"
- "toeic" = "TOEIC" = "토익"
- "three month" = "3 months" = "3개월" = 90 days
- "first grade" = "1급" = "일급"
- Text numbers: "ten week" = 10 weeks = 70 days

GOAL EXTRACTION:
- Extract the ACTUAL goal, not the entire input
- "아니다 토익 900점 3년안에" → Goal: "TOEIC 900점 달성" (NOT the whole sentence)
- "korean history 1급 합격하고 싶어" → Goal: "한국사 1급 합격"

FLEXIBILITY:
- Understand typos, abbreviations, informal language
- Handle code-switching between Korean and English
- Recognize context even with grammatical errors
- Be creative in understanding user intent

Always respond appropriately based on the extracted information.
Default to Korean responses unless English is more appropriate.''',
              },
              {
                'role': 'user',
                'content': prompt,
              },
            ],
            'temperature': 1,
            'max_completion_tokens': 4000,
          },
        );

        print('\n✅ HTTP 응답 수신!');
        print('상태 코드: ${response.statusCode}');
        
        if (response.data['choices'] != null && response.data['choices'].isNotEmpty) {
          final content = response.data['choices'][0]['message']['content'];
          print('✅ ChatGPT 응답 성공! (시도 $attempt/$maxRetries)');
          print('응답 길이: ${content.length}자');
          print('모델 사용: ${response.data['model'] ?? 'unknown'}');
          print('토큰 사용: ${response.data['usage']?.toString() ?? 'unknown'}');
          return content;
        }

        throw Exception('Invalid response from OpenAI');
      } on DioException catch (e) {
        print('\n❌ API 호출 실패 (시도 $attempt/$maxRetries)');
        print('━' * 60);
        print('📊 에러 상세 정보:');
        print('  - 상태 코드: ${e.response?.statusCode}');
        print('  - 에러 메시지: ${e.response?.data}');
        print('  - 에러 타입: ${e.type}');
        
        // 재시도 가능한 에러인지 확인
        bool shouldRetry = _shouldRetryError(e);
        
        if (!shouldRetry) {
          print('재시도 불가능한 에러입니다.');
          throw Exception('API 호출 실패: ${_getErrorMessage(e)}');
        }
        
        if (attempt == maxRetries) {
          print('최대 재시도 횟수에 도달했습니다.');
          throw Exception('API 호출 실패 (최대 재시도 횟수 초과): ${_getErrorMessage(e)}');
        }
        
        // Exponential backoff: 1초, 2초, 3초
        final delay = baseDelay * attempt;
        print('🔄 ${delay}ms 후 재시도합니다... (${attempt + 1}/$maxRetries)');
        await Future.delayed(Duration(milliseconds: delay));
        
      } catch (e) {
        print('\n❌ 일반 예외 발생 (시도 $attempt/$maxRetries)');
        print('예외 타입: ${e.runtimeType}');
        print('예외 메시지: $e');
        
        if (attempt == maxRetries) {
          throw Exception('API 호출 실패 (최대 재시도 횟수 초과): $e');
        }
        
        final delay = baseDelay * attempt;
        print('🔄 ${delay}ms 후 재시도합니다... (${attempt + 1}/$maxRetries)');
        await Future.delayed(Duration(milliseconds: delay));
      }
    }
    
    throw Exception('예상치 못한 오류가 발생했습니다.');
  }
  
  /// 재시도 가능한 에러인지 확인
  bool _shouldRetryError(DioException e) {
    final statusCode = e.response?.statusCode;
    
    // 재시도 가능한 상태 코드
    if (statusCode != null) {
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
    
    // 네트워크 연결 에러는 재시도 가능
    return e.type == DioExceptionType.connectionTimeout ||
           e.type == DioExceptionType.receiveTimeout ||
           e.type == DioExceptionType.connectionError;
  }
  
  /// 에러 메시지 생성
  String _getErrorMessage(DioException e) {
    final statusCode = e.response?.statusCode;
    
    if (statusCode != null) {
      switch (statusCode) {
        case 401:
          return 'API 키가 유효하지 않습니다. .env 파일을 확인하세요.';
        case 429:
          return 'API 사용량 제한에 도달했습니다. 잠시 후 다시 시도하세요.';
        case 400:
          return '잘못된 요청입니다. 요청 파라미터를 확인하세요.';
        case 500:
          return 'OpenAI 서버 내부 오류입니다.';
        default:
          return 'HTTP 오류 ($statusCode): ${e.response?.data?.toString() ?? e.message}';
      }
    }
    
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return '연결 시간이 초과되었습니다.';
      case DioExceptionType.receiveTimeout:
        return '응답 시간이 초과되었습니다.';
      case DioExceptionType.connectionError:
        return '네트워크 연결 오류가 발생했습니다.';
      default:
        return '알 수 없는 오류: ${e.message}';
    }
  }

  /// 학습 요청 유효성 검사
  bool _isValidStudyRequest(String input) {
    // 일단 모든 입력을 유효하게 처리 (디버깅용)
    print('📌 유효성 검사: 모든 입력 통과 (디버깅 모드)');
    return true;
    
    final lowerInput = input.toLowerCase();
    
    // 학습과 관련없는 키워드 필터링
    final invalidKeywords = [
      'weather', '날씨', 'news', '뉴스', 
      'stock', '주식', 'game', '게임',
      'movie', '영화', 'music download', '음악 다운',
      'shopping', '쇼핑', 'recipe', '레시피',
      'joke', '농담', 'story', '이야기',
    ];
    
    for (final keyword in invalidKeywords) {
      if (lowerInput.contains(keyword)) {
        return false;
      }
    }
    
    // 학습 관련 키워드가 하나라도 있는지 확인
    final validKeywords = [
      'learn', 'study', '학습', '공부', '배우', '배워', 'learning',
      'master', '마스터', 'prepare', '준비', 'preparation',
      'exam', '시험', 'test', '테스트', 'examination',
      'course', '코스', 'lesson', '레슨', 'class', '수업',
      'practice', '연습', 'improve', '향상', 'improvement', 'enhance',
      'certification', '자격증', 'certificate', 'license', '라이센스',
      'language', '언어', 'skill', '스킬', 'ability', '능력',
      'education', '교육', 'training', '훈련', 'tutorial', '튜토리얼',
      'toeic', '토익', 'toefl', '토플', 'ielts', '아이엘츠',
      'programming', '프로그래밍', 'coding', '코딩', 'development', '개발',
      'math', '수학', 'mathematics', 'science', '과학', 'physics', '물리',
      'chemistry', '화학', 'biology', '생물', 'history', '역사',
      'english', '영어', 'japanese', '일본어', 'chinese', '중국어',
      'spanish', '스페인어', 'french', '프랑스어', 'german', '독일어',
      'korean', '한국어', 'koreahistory', 'korea history',
      'point', '점', 'score', '점수', 'level', '레벨', 'grade', '급',
      'pass', '합격', 'achieve', '달성', 'reach', '도달',
      'week', '주', 'month', '개월', 'year', '년', 'day', '일',
      'hour', '시간', 'minute', '분', 'semester', '학기',
      'beginner', '초급', 'intermediate', '중급', 'advanced', '고급',
      'basic', '기초', 'fundamental', '기본', 'expert', '전문가',
    ];
    
    // 최소한 하나의 학습 키워드가 있어야 함
    for (final keyword in validKeywords) {
      if (lowerInput.contains(keyword)) {
        return true;
      }
    }
    
    // 숫자 + 기간 패턴이 있으면 학습 관련일 가능성 높음
    if (RegExp(r'\d+\s*(week|month|year|day|주|개월|년|일)').hasMatch(lowerInput)) {
      return true;
    }
    
    return false;
  }
  
  /// JSON 추출 헬퍼 함수
  String _extractJsonFromResponse(String response) {
    // JSON 블록 찾기
    final jsonMatch = RegExp(r'```json\s*([\s\S]*?)\s*```').firstMatch(response);
    if (jsonMatch != null) {
      return jsonMatch.group(1)!.trim();
    }
    
    // 중괄호나 대괄호로 시작하는 부분 찾기
    final startIndex = response.indexOf(RegExp(r'[\{\[]'));
    if (startIndex != -1) {
      final endIndex = response.lastIndexOf(RegExp(r'[\}\]]'));
      if (endIndex != -1 && endIndex > startIndex) {
        return response.substring(startIndex, endIndex + 1);
      }
    }
    
    // 전체 응답 반환
    return response.trim();
  }

}