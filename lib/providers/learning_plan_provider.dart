import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import '../models/learning_plan.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';

enum LearningPlanState { initial, loading, loaded, error }

class LearningPlanProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final Dio _dio = Dio();
  
  // OpenAI API 설정 (실제 운영시 서버에서 관리)
  static const String _openAIApiKey = 'YOUR_OPENAI_API_KEY';
  static const String _openAIEndpoint = 'https://api.openai.com/v1/chat/completions';
  
  LearningPlanState _state = LearningPlanState.initial;
  LearningPlanState get state => _state;
  
  List<LearningPlan> _plans = [];
  List<LearningPlan> get plans => _plans;
  
  LearningPlan? _activePlan;
  LearningPlan? get activePlan => _activePlan;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  // ChatGPT를 사용한 학습 플랜 생성
  Future<Map<String, dynamic>> generatePlanWithAI(String userInput) async {
    try {
      _state = LearningPlanState.loading;
      notifyListeners();
      
      // ChatGPT API 호출
      final response = await _dio.post(
        _openAIEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_openAIApiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'gpt-4',
          'messages': [
            {
              'role': 'system',
              'content': '''
You are an expert educational planner. Analyze the user's learning goal and create a structured learning plan.
Extract and return the following information in JSON format:
{
  "goal": "The specific learning goal",
  "subject": "The main subject area",
  "level": "The target level or proficiency",
  "duration_days": "Number of days for the plan",
  "curriculum": {
    "overview": "Brief overview of the learning plan",
    "weekly_breakdown": [
      {
        "week": 1,
        "focus": "Main focus for this week",
        "topics": ["topic1", "topic2", "topic3"],
        "milestones": ["milestone1", "milestone2"]
      }
    ],
    "daily_schedule": {
      "morning": "What to study in the morning (9 AM)",
      "afternoon": "What to study at noon (12 PM)",
      "evening": "What to review in the evening (9 PM)"
    }
  },
  "daily_tasks": "Description of daily learning tasks",
  "success_tips": ["tip1", "tip2", "tip3"]
}

Make sure to:
1. Create realistic and achievable goals
2. Break down complex topics into manageable daily tasks
3. Include variety (theory, practice, review)
4. Adapt to the specific timeframe requested
5. Be specific about what to study each day
'''
            },
            {
              'role': 'user',
              'content': userInput
            }
          ],
          'temperature': 0.7,
          'max_tokens': 2000,
          'response_format': { 'type': 'json_object' }
        },
      );
      
      final aiResponse = response.data['choices'][0]['message']['content'];
      final planData = _parseAIResponse(aiResponse);
      
      _state = LearningPlanState.loaded;
      notifyListeners();
      
      return planData;
    } catch (e) {
      _errorMessage = '플랜 생성 실패: $e';
      _state = LearningPlanState.error;
      notifyListeners();
      
      // 오프라인 또는 에러 시 기본 플랜 반환
      return _generateDefaultPlan(userInput);
    }
  }
  
  Map<String, dynamic> _parseAIResponse(String response) {
    try {
      // JSON 파싱
      if (response is String && response.startsWith('{')) {
        final Map<String, dynamic> data = jsonDecode(response);
        return data;
      }
      return {};
    } catch (e) {
      debugPrint('AI Response parsing error: $e');
      return {};
    }
  }
  
  // 오프라인 또는 에러 시 기본 플랜 생성
  Map<String, dynamic> _generateDefaultPlan(String userInput) {
    // 간단한 키워드 분석
    String subject = '일반 학습';
    String level = '중급';
    int duration = 30;
    
    // 토익 관련
    if (userInput.toLowerCase().contains('토익') || 
        userInput.toLowerCase().contains('toeic')) {
      subject = '토익';
      final scoreMatch = RegExp(r'\d{3,4}').firstMatch(userInput);
      if (scoreMatch != null) {
        level = '목표 ${scoreMatch.group(0)}점';
      }
      
      // 990점 목표인 경우 특별 커리큘럼
      if (userInput.contains('990')) {
        duration = 90; // 3개월
        return {
          'goal': '토익 990점 만점 달성',
          'subject': '토익',
          'level': '990점 (만점)',
          'duration_days': duration,
          'curriculum': {
            'overview': '토익 만점을 위한 집중 학습 플랜',
            'weekly_breakdown': _generateTOEIC990Curriculum(),
            'daily_schedule': {
              'morning': 'LC Part 1-2 집중 연습 + 어휘 100개',
              'afternoon': 'RC Part 5-6 문법 + 독해 전략',
              'evening': 'Part 3-4, 7 실전 문제 + 오답 정리'
            }
          },
          'daily_tasks': '매일 실전 모의고사 1회분 + 오답노트 작성',
          'success_tips': [
            '매일 꾸준히 3시간 이상 학습',
            '실전과 동일한 환경에서 모의고사 실시',
            '오답노트 반복 학습'
          ]
        };
      }
    }
    
    // 한국사 관련
    else if (userInput.contains('한국사')) {
      subject = '한국사능력검정시험';
      if (userInput.contains('1급')) level = '1급';
      else if (userInput.contains('2급')) level = '2급';
      duration = 30;
    }
    
    // 프로그래밍 관련
    else if (userInput.toLowerCase().contains('프로그래밍') || 
             userInput.toLowerCase().contains('코딩') ||
             userInput.toLowerCase().contains('python')) {
      subject = '프로그래밍';
      level = '중급';
      duration = 21;
    }
    
    // 기간 추출
    final monthMatch = RegExp(r'(\d+)달|(\d+)개월').firstMatch(userInput);
    final weekMatch = RegExp(r'(\d+)주').firstMatch(userInput);
    final yearMatch = RegExp(r'올해|1년|(\d+)년').firstMatch(userInput);
    
    if (yearMatch != null) {
      duration = 365;
    } else if (monthMatch != null) {
      final months = int.tryParse(monthMatch.group(1) ?? monthMatch.group(2) ?? '1') ?? 1;
      duration = months * 30;
    } else if (weekMatch != null) {
      final weeks = int.tryParse(weekMatch.group(1) ?? '1') ?? 1;
      duration = weeks * 7;
    }
    
    return {
      'goal': userInput,
      'subject': subject,
      'level': level,
      'duration_days': duration,
      'curriculum': {
        'overview': '$subject $level 달성을 위한 맞춤 학습 플랜',
        'weekly_breakdown': _generateGenericCurriculum(duration),
        'daily_schedule': {
          'morning': '핵심 개념 학습 및 이론 정리',
          'afternoon': '문제 풀이 및 실전 연습',
          'evening': '복습 및 오답 정리'
        }
      },
      'daily_tasks': '일일 학습 목표 달성 및 복습',
      'success_tips': [
        '매일 정해진 시간에 학습하기',
        '작은 목표부터 달성하기',
        '꾸준함이 가장 중요합니다'
      ]
    };
  }
  
  List<Map<String, dynamic>> _generateTOEIC990Curriculum() {
    return [
      {
        'week': 1,
        'focus': 'LC/RC 기초 다지기',
        'topics': ['Part 1-2 완벽 마스터', 'Part 5 문법 기초', '필수 어휘 500개'],
        'milestones': ['LC 450점 달성', '기초 문법 완성']
      },
      {
        'week': 2,
        'focus': 'Part 3-4 집중 훈련',
        'topics': ['Part 3 대화 패턴', 'Part 4 설명문 유형', '동의어 마스터'],
        'milestones': ['LC 470점 달성', '청취 속도 적응']
      },
      {
        'week': 3,
        'focus': 'Part 6-7 독해 전략',
        'topics': ['Part 6 문맥 파악', 'Part 7 Single Passage', '시간 관리 전략'],
        'milestones': ['RC 450점 달성', '독해 속도 향상']
      },
      {
        'week': 4,
        'focus': 'Part 7 Double/Triple 완성',
        'topics': ['복수 지문 연결', '추론 문제 전략', '고난도 어휘'],
        'milestones': ['RC 470점 달성', '전 파트 마스터']
      },
    ];
  }
  
  List<Map<String, dynamic>> _generateGenericCurriculum(int days) {
    final weeks = (days / 7).ceil();
    final curriculum = <Map<String, dynamic>>[];
    
    for (int week = 1; week <= weeks && week <= 4; week++) {
      curriculum.add({
        'week': week,
        'focus': '${week}주차 핵심 학습',
        'topics': ['기초 개념', '심화 학습', '실전 연습'],
        'milestones': ['주간 목표 달성', '실력 점검']
      });
    }
    
    return curriculum;
  }
  
  // 학습 플랜 생성 및 저장
  Future<bool> createLearningPlan({
    required String goal,
    required String subject,
    required String level,
    required int durationDays,
    required Map<String, dynamic> curriculum,
  }) async {
    try {
      _state = LearningPlanState.loading;
      notifyListeners();
      
      // 일일 태스크 생성
      final dailyTasks = await _generateDailyTasks(
        subject: subject,
        level: level,
        duration: durationDays,
        curriculum: curriculum,
      );
      
      final plan = LearningPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: await LocalStorageService.getString('user_id') ?? 'user_1',
        goal: goal,
        subject: subject,
        level: level,
        durationDays: durationDays,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: durationDays)),
        status: PlanStatus.active,
        planType: PlanType.free, // 기본 무료 플랜
        curriculum: curriculum,
        dailyTasks: dailyTasks,
      );
      
      // 서버에 저장 (실제 구현 시)
      // await _apiService.post('/learning-plans', plan.toJson());
      
      // 로컬 상태 업데이트
      _plans.add(plan);
      _activePlan = plan;
      
      // 로컬 저장소에 저장
      await LocalStorageService.saveString('active_plan', plan.id);
      
      // 알림 스케줄링
      await _scheduleNotifications(plan);
      
      _state = LearningPlanState.loaded;
      notifyListeners();
      
      return true;
    } catch (e) {
      _errorMessage = '플랜 생성 실패: $e';
      _state = LearningPlanState.error;
      notifyListeners();
      return false;
    }
  }
  
  // 일일 태스크 생성
  Future<List<DailyTask>> _generateDailyTasks({
    required String subject,
    required String level,
    required int duration,
    required Map<String, dynamic> curriculum,
  }) async {
    final tasks = <DailyTask>[];
    
    for (int day = 0; day < duration; day++) {
      final date = DateTime.now().add(Duration(days: day));
      final weekNumber = (day ~/ 7) + 1;
      final dayOfWeek = day % 7 + 1;
      
      // ChatGPT로 일일 콘텐츠 생성 (실제 구현 시)
      final dailyContent = await _generateDailyContent(
        subject: subject,
        level: level,
        week: weekNumber,
        day: dayOfWeek,
        curriculum: curriculum,
      );
      
      tasks.add(DailyTask(
        id: '${date.millisecondsSinceEpoch}',
        planId: 'plan_id',
        date: date,
        title: 'Day ${day + 1}: ${dailyContent['title']}',
        description: dailyContent['description'],
        topics: List<String>.from(dailyContent['topics']),
        morningContent: StudyContent(
          type: 'summary',
          title: '오전 학습: ${dailyContent['morning']['title']}',
          content: dailyContent['morning']['content'],
          estimatedMinutes: 30,
        ),
        afternoonContent: StudyContent(
          type: 'quiz',
          title: '오후 퀴즈: ${dailyContent['afternoon']['title']}',
          content: dailyContent['afternoon']['content'],
          questions: _generateQuizQuestions(dailyContent['afternoon']['questions']),
          estimatedMinutes: 20,
        ),
        eveningContent: StudyContent(
          type: 'summary',
          title: '저녁 복습: ${dailyContent['evening']['title']}',
          content: dailyContent['evening']['content'],
          estimatedMinutes: 25,
        ),
        completionStatus: {
          'morning': false,
          'afternoon': false,
          'evening': false,
        },
      ));
    }
    
    return tasks;
  }
  
  // 일일 콘텐츠 생성
  Future<Map<String, dynamic>> _generateDailyContent({
    required String subject,
    required String level,
    required int week,
    required int day,
    required Map<String, dynamic> curriculum,
  }) async {
    // ChatGPT API 호출하여 실제 콘텐츠 생성
    // 여기서는 예시 데이터 반환
    
    return {
      'title': '$subject Week $week Day $day',
      'description': '오늘의 학습 목표를 달성해보세요!',
      'topics': ['주제 1', '주제 2', '주제 3'],
      'morning': {
        'title': '핵심 개념 학습',
        'content': '오늘 학습할 핵심 개념입니다...'
      },
      'afternoon': {
        'title': '실전 문제',
        'content': '학습한 내용을 바탕으로 문제를 풀어보세요',
        'questions': [
          {
            'question': '문제 1',
            'options': ['선택지 1', '선택지 2', '선택지 3', '선택지 4'],
            'correct': 0,
            'explanation': '정답 설명'
          }
        ]
      },
      'evening': {
        'title': '오늘의 복습',
        'content': '오늘 학습한 내용을 정리합니다...'
      }
    };
  }
  
  List<QuizQuestion> _generateQuizQuestions(List<dynamic>? questions) {
    if (questions == null) return [];
    
    return questions.map((q) => QuizQuestion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      question: q['question'] ?? '',
      options: List<String>.from(q['options'] ?? []),
      correctAnswer: q['correct'] ?? 0,
      explanation: q['explanation'] ?? '',
    )).toList();
  }
  
  // 알림 스케줄링
  Future<void> _scheduleNotifications(LearningPlan plan) async {
    // Flutter Local Notifications 패키지로 구현
    // 9시, 12시, 21시에 알림 설정
    
    for (final task in plan.dailyTasks) {
      // 오전 9시 알림
      await _scheduleNotification(
        task.date.add(const Duration(hours: 9)),
        '오전 학습 시간입니다! 📚',
        task.morningContent.title,
      );
      
      // 낮 12시 알림
      await _scheduleNotification(
        task.date.add(const Duration(hours: 12)),
        '점심 퀴즈 시간입니다! 🧠',
        task.afternoonContent.title,
      );
      
      // 저녁 9시 알림
      await _scheduleNotification(
        task.date.add(const Duration(hours: 21)),
        '오늘의 복습 시간입니다! 🌙',
        task.eveningContent.title,
      );
    }
  }
  
  Future<void> _scheduleNotification(
    DateTime scheduledTime,
    String title,
    String body,
  ) async {
    // 실제 알림 구현
    debugPrint('Notification scheduled: $scheduledTime - $title');
  }
  
  // 학습 플랜 불러오기
  Future<void> loadPlans() async {
    try {
      _state = LearningPlanState.loading;
      notifyListeners();
      
      // 서버에서 플랜 불러오기
      // final response = await _apiService.get('/learning-plans');
      
      // 테스트 데이터
      _plans = [];
      
      final activePlanId = await LocalStorageService.getString('active_plan');
      if (activePlanId != null) {
        for (final p in _plans) {
          if (p.id == activePlanId) {
            _activePlan = p;
            break;
          }
        }
      }
      
      _state = LearningPlanState.loaded;
      notifyListeners();
    } catch (e) {
      _errorMessage = '플랜 불러오기 실패: $e';
      _state = LearningPlanState.error;
      notifyListeners();
    }
  }
  
  // 태스크 완료 처리
  Future<void> completeTask(String taskId, String timeSlot) async {
    if (_activePlan == null) return;
    
    final taskIndex = _activePlan!.dailyTasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return;
    
    final task = _activePlan!.dailyTasks[taskIndex];
    task.completionStatus[timeSlot] = true;
    
    // 모든 시간대 완료 체크
    if (task.completionStatus.values.every((v) => v == true)) {
      // 태스크 완료 처리
      debugPrint('Daily task completed!');
    }
    
    notifyListeners();
  }
  
}