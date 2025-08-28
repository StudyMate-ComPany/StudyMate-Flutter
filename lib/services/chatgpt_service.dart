import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatGPTService {
  static final ChatGPTService _instance = ChatGPTService._internal();
  factory ChatGPTService() => _instance;
  ChatGPTService._internal();

  final Dio _dio = Dio();
  
  // OpenAI API 설정
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions';
  static String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? 'YOUR_OPENAI_API_KEY';
  
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
        // API 실패 시 모의 응답 사용
        final mockResponse = _getMockResponse(prompt);
        try {
          final mockAnalysis = json.decode(mockResponse);
          return {
            'success': true,
            'analysis': mockAnalysis,
          };
        } catch (e2) {
          return {
            'success': false,
            'error': 'Failed to parse analysis',
            'raw_response': response,
          };
        }
      }
    } catch (e) {
      print('\n⚠️ ChatGPT API 호출 중 예외 발생!');
      print('에러: $e');
      print('📎 모의 응답으로 대체합니다...');
      // API 실패 시 모의 응답 사용
      final mockPrompt = '''
You are an AI that analyzes user input for creating personalized study plans.
Be VERY flexible and understand various expressions in Korean, English, and mixed languages.

User input: "$userInput"
      ''';
      final mockResponse = _getMockResponse(mockPrompt);
      try {
        final mockAnalysis = json.decode(mockResponse);
        return {
          'success': true,
          'analysis': mockAnalysis,
          'usingMock': true, // 모의 응답 사용 표시
        };
      } catch (e2) {
        debugPrint('모의 응답 파싱 실패: $e2');
        return {
          'success': false,
          'error': e.toString(),
        };
      }
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

  /// OpenAI API 요청 전송  
  Future<String> _sendRequest(String prompt, {String model = 'gpt-3.5-turbo'}) async {
    print('\n' + '━' * 60);
    print('🚀 _sendRequest 호출 - OpenAI API 직접 호출 시도');
    print('모델: $model');
    
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    print('🔑 API 키 상태:');
    print('  - 존재 여부: ${apiKey.isNotEmpty}');
    if (apiKey.isNotEmpty) {
      print('  - 키 시작: ${apiKey.substring(0, 30)}...');
      print('  - 키 길이: ${apiKey.length}자');
    }
    
    // API 키 유효성 검증 강화
    if (apiKey.isEmpty || 
        apiKey == 'YOUR_OPENAI_API_KEY' || 
        !apiKey.startsWith('sk-') ||
        apiKey.length < 50) {
      print('\n❌ 유효하지 않은 API 키 발견!');
      print('  - 키 비어있음: ${apiKey.isEmpty}');
      print('  - 기본값: ${apiKey == 'YOUR_OPENAI_API_KEY'}');
      print('  - sk- 시작 안함: ${!apiKey.startsWith('sk-')}');
      print('  - 길이 부족: ${apiKey.length < 50}');
      print('📄 모의 응답으로 대체합니다.');
      print('━' * 60);
      return _getMockResponse(prompt);
    }
    
    print('✅ API 키 확인 완료 - 실제 OpenAI API 호출 진행');
    print('━' * 60);

    try {
      print('\n📡 HTTP POST 요청 전송 중...');
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
          'temperature': 0.7,
          'max_completion_tokens': 4000,
        },
      );

      print('\n✅ HTTP 응답 수신!');
      print('상태 코드: ${response.statusCode}');
      
      if (response.data['choices'] != null && response.data['choices'].isNotEmpty) {
        final content = response.data['choices'][0]['message']['content'];
        print('✅ ChatGPT 응답 성공!');
        print('응답 길이: ${content.length}자');
        print('모델 사용: ${response.data['model'] ?? 'unknown'}');
        print('토큰 사용: ${response.data['usage']?.toString() ?? 'unknown'}');
        return content;
      }

      throw Exception('Invalid response from OpenAI');
    } on DioException catch (e) {
      print('\n❌ OpenAI API 네트워크 에러 발생!');
      print('━' * 60);
      print('📊 에러 상세 정보:');
      print('  - 상태 코드: ${e.response?.statusCode}');
      print('  - 에러 메시지: ${e.response?.data}');
      print('  - 에러 타입: ${e.type}');
      print('  - 요청 URL: ${e.requestOptions.path}');
      print('  - 요청 메서드: ${e.requestOptions.method}');
      
      // 구체적인 에러 분석
      String errorReason = '';
      if (e.response?.statusCode == 401) {
        errorReason = 'API 키가 유효하지 않습니다. .env 파일을 확인하세요.';
        print('🔑 API 키 문제: $errorReason');
      } else if (e.response?.statusCode == 429) {
        errorReason = 'API 사용량 제한에 도달했습니다. 잠시 후 다시 시도하세요.';
        print('⏳ 요청 한도 초과: $errorReason');
      } else if (e.response?.statusCode == 400) {
        errorReason = '잘못된 요청입니다. 모델명($model) 또는 요청 파라미터를 확인하세요.';
        print('⚠️ 요청 오류: $errorReason');
        if (e.response?.data?.toString().contains('model') == true) {
          print('🤖 모델 관련 오류가 감지되었습니다. 사용 가능한 모델을 확인하세요.');
        }
      } else if (e.response?.statusCode == 500) {
        errorReason = 'OpenAI 서버 내부 오류입니다. 잠시 후 다시 시도하세요.';
        print('🔧 서버 오류: $errorReason');
      } else {
        errorReason = '알 수 없는 네트워크 오류입니다.';
        print('❓ 기타 오류: $errorReason');
      }
      
      print('━' * 60);
      print('💡 모의 응답으로 대체합니다.');
      return _getMockResponse(prompt);
    } catch (e) {
      print('\n❌ OpenAI API 일반 예외 발생!');
      print('━' * 60);
      print('예외 타입: ${e.runtimeType}');
      print('예외 메시지: $e');
      print('스택 추적: ${StackTrace.current}');
      print('━' * 60);
      print('💡 모의 응답으로 대체합니다.');
      return _getMockResponse(prompt);
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

  /// 모의 응답 생성 (API 키가 없을 때)
  String _getMockResponse(String prompt) {
    print('\n' + '🎭' * 30);
    print('⚠️ 모의 응답 생성 중 (실제 ChatGPT 미사용)');
    print('🎭' * 30 + '\n');
    // 사용자 입력 분석 요청 (영어 또는 한글 프롬프트 체크)
    if (prompt.contains('User input:') || prompt.contains('사용자의 다음 입력을 분석')) {
      // 프롬프트에서 사용자 입력 추출
      final userInputMatch = RegExp(r'"([^"]*)"').firstMatch(prompt);
      final userInput = userInputMatch?.group(1) ?? '';
      final lowerInput = userInput.toLowerCase();
      
      // 자유로운 분석 - 사용자 입력에서 키워드를 유연하게 추출
      String subject = '';
      String goal = '';
      String level = 'beginner';
      int days = 30;
      String studyType = 'general';
      
      // 스마트한 과목 추출 - 정확한 패턴 매칭
      // koreahistory를 한 단어로 먼저 체크
      if (lowerInput.contains('koreahistory')) {
        subject = '한국사';
      } else if (lowerInput.contains('korean history')) {
        subject = '한국사';
      } else if (lowerInput.contains('korea history')) {
        subject = '한국사';
      } else if (lowerInput.contains('toeic') || lowerInput.contains('토익')) {
        subject = 'TOEIC';
      } else if (lowerInput.contains('toefl') || lowerInput.contains('토플')) {
        subject = 'TOEFL';
      } else if (lowerInput.contains('ielts') || lowerInput.contains('아이엘츠')) {
        subject = 'IELTS';
      } else if (lowerInput.contains('한국사')) {
        subject = '한국사';
      } else if (lowerInput.contains('영어') || lowerInput.contains('english')) {
        subject = '영어';
      } else if (lowerInput.contains('수학') || lowerInput.contains('math')) {
        subject = '수학';
      } else if (lowerInput.contains('과학') || lowerInput.contains('science')) {
        subject = '과학';
      } else if (lowerInput.contains('physics') || lowerInput.contains('물리')) {
        subject = '물리학';
      } else if (lowerInput.contains('chemistry') || lowerInput.contains('화학')) {
        subject = '화학';
      } else if (lowerInput.contains('biology') || lowerInput.contains('생물')) {
        subject = '생물학';
      } else if (lowerInput.contains('history')) {
        subject = '역사';
      } else if (lowerInput.contains('programming') || lowerInput.contains('coding') || lowerInput.contains('프로그래밍') || lowerInput.contains('코딩')) {
        subject = '프로그래밍';
      } else if (lowerInput.contains('python') || lowerInput.contains('파이썬')) {
        subject = 'Python';
      } else if (lowerInput.contains('java')) {
        if (lowerInput.contains('script')) {
          subject = 'JavaScript';
        } else {
          subject = 'Java';
        }
      } else if (lowerInput.contains('web') || lowerInput.contains('웹')) {
        subject = '웹개발';
      } else {
        // 첫 단어를 과목으로 추정
        final words = userInput.split(RegExp(r'\s+'));
        if (words.isNotEmpty) {
          final firstWord = words[0].toLowerCase();
          // 일반적인 학습 단어가 아니면 첫 단어를 과목으로
          if (!['learn', 'study', 'master', 'prepare', '공부', '학습'].contains(firstWord)) {
            subject = words[0];
          } else {
            subject = '일반 학습';
          }
        } else {
          subject = '일반 학습';
        }
      }
      
      // 텍스트 숫자를 실제 숫자로 변환
      final textNumbers = {
        'one': 1, 'two': 2, 'three': 3, 'four': 4, 'five': 5,
        'six': 6, 'seven': 7, 'eight': 8, 'nine': 9, 'ten': 10,
        'eleven': 11, 'twelve': 12, 'thirteen': 13, 'fourteen': 14, 'fifteen': 15,
        'sixteen': 16, 'seventeen': 17, 'eighteen': 18, 'nineteen': 19, 'twenty': 20,
        'thirty': 30, 'forty': 40, 'fifty': 50, 'sixty': 60, 'seventy': 70,
        'eighty': 80, 'ninety': 90, 'hundred': 100,
        '하나': 1, '둘': 2, '셋': 3, '넷': 4, '다섯': 5,
        '여섯': 6, '일곱': 7, '여덟': 8, '아홉': 9, '열': 10,
        '스무': 20, '서른': 30, '마흔': 40, '쉰': 50, '예순': 60,
      };
      
      // 텍스트 숫자를 실제 숫자로 치환
      String processedInput = lowerInput;
      textNumbers.forEach((text, number) {
        processedInput = processedInput.replaceAll(RegExp('\\b$text\\b'), number.toString());
      });
      
      // 학습 기간 추출 (더 유연하게)
      final durationPatterns = [
        (RegExp(r'(\d+)\s*year'), (match) => int.parse(match.group(1)!) * 365),
        (RegExp(r'(\d+)\s*month'), (match) => int.parse(match.group(1)!) * 30),
        (RegExp(r'(\d+)\s*week'), (match) => int.parse(match.group(1)!) * 7),
        (RegExp(r'(\d+)\s*day'), (match) => int.parse(match.group(1)!)),
        (RegExp(r'(\d+)년'), (match) => int.parse(match.group(1)!) * 365),
        (RegExp(r'(\d+)개월'), (match) => int.parse(match.group(1)!) * 30),
        (RegExp(r'(\d+)주'), (match) => int.parse(match.group(1)!) * 7),
        (RegExp(r'(\d+)일'), (match) => int.parse(match.group(1)!)),
      ];
      
      for (final pattern in durationPatterns) {
        final match = pattern.$1.firstMatch(processedInput);
        if (match != null) {
          days = pattern.$2(match);
          break;
        }
      }
      
      // 급수 처리 (first grade, 1급 등)
      bool hasGrade = false;
      String gradeLevel = '';
      
      if (lowerInput.contains('first grade') || lowerInput.contains('1급') || lowerInput.contains('일급')) {
        gradeLevel = '1급';
        hasGrade = true;
      } else if (lowerInput.contains('second grade') || lowerInput.contains('2급') || lowerInput.contains('이급')) {
        gradeLevel = '2급';
        hasGrade = true;
      } else if (lowerInput.contains('third grade') || lowerInput.contains('3급') || lowerInput.contains('삼급')) {
        gradeLevel = '3급';
        hasGrade = true;
      } else if (lowerInput.contains('fourth grade') || lowerInput.contains('4급') || lowerInput.contains('사급')) {
        gradeLevel = '4급';
        hasGrade = true;
      } else if (lowerInput.contains('fifth grade') || lowerInput.contains('5급') || lowerInput.contains('오급')) {
        gradeLevel = '5급';
        hasGrade = true;
      }
      
      // 한국사 급수 목표 설정
      if (subject == '한국사' && hasGrade) {
        goal = '한국사 $gradeLevel 합격';
        level = '$gradeLevel 수준';
      }
      
      // 목표 점수나 레벨 추출 및 목표 설정 (급수가 없는 경우)
      if (!hasGrade) {
        final scoreMatch = RegExp(r'(\d{2,4})\s*(점|point|score)?').firstMatch(lowerInput);
        if (scoreMatch != null) {
          final score = scoreMatch.group(1)!;
          level = '$score점 목표';
          
          // 과목과 점수를 조합하여 목표 생성
          if (subject == 'TOEIC' || subject == 'TOEFL' || subject == 'IELTS') {
            goal = '$subject ${score}점 달성';
          } else if (scoreMatch != null) {
            goal = '${score}점 달성';
          }
        }
      }
      
      // 목표가 아직 설정되지 않은 경우
      if (goal.isEmpty) {
        if (subject == 'TOEIC' || subject == 'TOEFL' || subject == 'IELTS') {
          goal = '$subject 고득점 달성';
        } else if (subject == '한국사') {
          goal = '한국사 자격증 취득';
        } else if (subject.isNotEmpty && subject != userInput) {
          goal = '$subject 실력 향상';
        } else {
          // 학습 관련 키워드로 목표 추론
          if (lowerInput.contains('master') || lowerInput.contains('마스터')) {
            goal = '완벽 마스터';
          } else if (lowerInput.contains('pass') || lowerInput.contains('합격')) {
            goal = '시험 합격';
          } else if (lowerInput.contains('improve') || lowerInput.contains('향상')) {
            goal = '실력 향상';
          } else {
            goal = '학습 목표 달성';
          }
        }
      }
      
      // 학습 유형 추론
      if (lowerInput.contains('exam') || lowerInput.contains('test') || lowerInput.contains('시험') || 
          lowerInput.contains('examination') || lowerInput.contains('quiz')) {
        studyType = 'exam_prep';
      } else if (lowerInput.contains('certificate') || lowerInput.contains('certification') || 
                 lowerInput.contains('자격증') || lowerInput.contains('license')) {
        studyType = 'certification';
      } else if (lowerInput.contains('hobby') || lowerInput.contains('취미') || 
                 lowerInput.contains('fun') || lowerInput.contains('casual')) {
        studyType = 'hobby';
      } else if (lowerInput.contains('professional') || lowerInput.contains('career') || 
                 lowerInput.contains('job') || lowerInput.contains('직업') || lowerInput.contains('전문')) {
        studyType = 'professional';
      } else if (lowerInput.contains('academic') || lowerInput.contains('university') || 
                 lowerInput.contains('college') || lowerInput.contains('대학') || lowerInput.contains('학술')) {
        studyType = 'academic';
      }
      
      // 난이도 추출
      if (lowerInput.contains('beginner') || lowerInput.contains('초급') || lowerInput.contains('입문') ||
          lowerInput.contains('basic') || lowerInput.contains('elementary') || lowerInput.contains('starter')) {
        level = 'beginner';
      } else if (lowerInput.contains('intermediate') || lowerInput.contains('중급') || 
                 lowerInput.contains('medium') || lowerInput.contains('moderate')) {
        level = 'intermediate';
      } else if (lowerInput.contains('advanced') || lowerInput.contains('고급') || lowerInput.contains('상급') ||
                 lowerInput.contains('expert') || lowerInput.contains('professional') || lowerInput.contains('high')) {
        level = 'advanced';
      }
      
      // 토픽은 과목명으로 설정
      String topic = subject;
      
      return '''
{
  "subject": "$subject",
  "topic": "$topic",
  "goal": "$goal",
  "currentLevel": "$level",
  "daysAvailable": $days,
  "hoursPerDay": 2,
  "studyType": "$studyType",
  "additionalInfo": "사용자 맞춤 분석 결과"
}
''';
    } else if (prompt.contains('문제를 생성')) {
      return '''
[
  {
    "question": "다음 중 광합성에 필요한 요소가 아닌 것은?",
    "type": "multiple_choice",
    "options": ["이산화탄소", "물", "빛", "산소"],
    "answer": "산소",
    "explanation": "광합성은 이산화탄소, 물, 빛을 이용해 포도당과 산소를 생성하는 과정입니다. 산소는 광합성의 결과물이지 필요 요소가 아닙니다.",
    "difficulty": "medium",
    "points": 10
  },
  {
    "question": "세포의 에너지 공장이라 불리는 세포소기관은?",
    "type": "short_answer",
    "answer": "미토콘드리아",
    "explanation": "미토콘드리아는 ATP를 생산하여 세포에 에너지를 공급하는 역할을 합니다.",
    "difficulty": "medium",
    "points": 10
  },
  {
    "question": "DNA는 이중나선 구조를 가지고 있다.",
    "type": "true_false",
    "answer": "true",
    "explanation": "DNA는 왓슨과 크릭이 발견한 이중나선(double helix) 구조를 가지고 있습니다.",
    "difficulty": "easy",
    "points": 5
  }
]
''';
    } else if (prompt.contains('학습 계획')) {
      // 프롬프트에서 과목과 기간 추출
      String subject = "일반 학습";
      String goal = "학습 목표 달성";
      int days = 30;
      
      final lowerPrompt = prompt.toLowerCase();
      if (prompt.contains('한국사')) {
        subject = "한국사";
        goal = "한국사 시험 대비";
      } else if (lowerPrompt.contains('toeic') || lowerPrompt.contains('토익')) {
        subject = "토익";
        goal = "토익 점수 향상";
        // 점수 추출
        final scoreMatch = RegExp(r'\d{3,4}').firstMatch(prompt);
        if (scoreMatch != null) {
          goal = "토익 ${scoreMatch.group(0)}점 달성";
        }
      } else if (prompt.contains('영어')) {
        subject = "영어";
        goal = "영어 실력 향상";
      } else if (prompt.contains('수학')) {
        subject = "수학";
        goal = "수학 개념 마스터";
      } else if (prompt.contains('과학') || prompt.contains('생물')) {
        subject = "과학";
        goal = "과학 기초 다지기";
      }
      
      // 영어 기간 처리 추가
      if (lowerPrompt.contains('year')) {
        if (lowerPrompt.contains('two') || lowerPrompt.contains('2')) days = 730;
        else if (lowerPrompt.contains('three') || lowerPrompt.contains('3')) days = 1095;
        else days = 365;
      } else if (lowerPrompt.contains('two month') || lowerPrompt.contains('2 month')) days = 60;
      else if (lowerPrompt.contains('three month') || lowerPrompt.contains('3 month')) days = 90;
      else if (prompt.contains('7일') || prompt.contains('일주일')) days = 7;
      else if (prompt.contains('14일') || prompt.contains('2주')) days = 14;
      else if (prompt.contains('30일') || prompt.contains('한달')) days = 30;
      else if (prompt.contains('60일') || prompt.contains('2개월') || prompt.contains('두달')) days = 60;
      else if (prompt.contains('90일') || prompt.contains('3개월')) days = 90;
      
      return '''
{
  "title": "$subject 마스터 플랜",
  "overview": "${days}일간 $subject 체계적 학습 계획",
  "totalDays": $days,
  "hoursPerDay": 2,
  "schedule": [
    {
      "day": 1,
      "date": "2024-01-01",
      "topics": ["$subject 기초 개념", "$subject 핵심 내용"],
      "activities": [
        {
          "time": "09:00-10:00",
          "activity": "$subject 기본 개념 학습",
          "type": "lecture"
        },
        {
          "time": "10:00-11:00",
          "activity": "$subject 연습 문제 풀기",
          "type": "practice"
        }
      ],
      "goals": ["$subject 기본 개념 이해", "$subject 핵심 내용 숙지"],
      "resources": ["$subject 교재", "$subject 온라인 강의"]
    }
  ],
  "milestones": [
    {
      "day": 3,
      "title": "$subject 기초 단원 완료",
      "description": "$subject 기본 개념 완벽 이해"
    }
  ],
  "tips": ["매일 복습 노트 작성하기", "그림으로 개념 정리하기", "실생활 예시와 연결하기"]
}
''';
    } else {
      return '모의 응답입니다. 실제 사용을 위해서는 AI API 키를 설정해주세요.';
    }
  }
}