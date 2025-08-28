import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/learning_plan.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';
import '../services/chatgpt_session_service.dart';
import '../services/daily_content_service.dart';

enum LearningPlanState { initial, loading, loaded, error }

class LearningPlanProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final Dio _dio = Dio();
  late final ChatGPTSessionService _chatGPTService;
  late final DailyContentService _dailyContentService;
  late final FlutterLocalNotificationsPlugin _notifications;
  
  // OpenAI API 설정 (실제 운영시 서버에서 관리하거나 env 파일 사용)
  static const String _openAIApiKey = String.fromEnvironment(
    'OPENAI_API_KEY', 
    defaultValue: 'YOUR_OPENAI_API_KEY'
  );
  static const String _openAIEndpoint = 'https://api.openai.com/v1/chat/completions';
  
  LearningPlanProvider() {
    _initializeServices();
  }
  
  Future<void> _initializeServices() async {
    // ChatGPT 서비스 초기화
    _chatGPTService = ChatGPTSessionService(apiKey: _openAIApiKey);
    
    // 알림 초기화
    _notifications = FlutterLocalNotificationsPlugin();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );
    
    // 일일 콘텐츠 서비스 초기화
    _dailyContentService = DailyContentService(
      chatGPTService: _chatGPTService,
      notifications: _notifications,
    );
  }
  
  void _handleNotificationResponse(NotificationResponse response) {
    // 알림 클릭 시 처리
    final payload = response.payload;
    if (payload != null) {
      // 해당 콘텐츠로 이동
      print('🔔 알림 클릭: $payload');
      // TODO: 라우팅 처리
    }
  }
  
  LearningPlanState _state = LearningPlanState.initial;
  LearningPlanState get state => _state;
  
  List<LearningPlan> _plans = [];
  List<LearningPlan> get plans => _plans;
  
  LearningPlan? _activePlan;
  LearningPlan? get activePlan => _activePlan;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  // 학습 플랜 생성 및 콘텐츠 초기화
  Future<LearningPlan?> createLearningPlan(Map<String, dynamic> planData) async {
    try {
      _state = LearningPlanState.loading;
      notifyListeners();
      
      // 플랜 데이터 정리
      final duration = planData['duration_days'] ?? planData['duration'] ?? 30;
      final planId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // 플랜 생성 (임시로 빈 dailyTasks로 시작)
      final tempPlan = LearningPlan(
        id: planId,
        userId: 'current_user',
        goal: planData['goal'] ?? '학습 목표 달성',
        subject: planData['subject'] ?? '일반 학습',
        level: planData['level'] ?? '중급',
        durationDays: duration,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: duration)),
        status: PlanStatus.active,
        planType: PlanType.free,
        curriculum: planData['curriculum'] ?? {},
        dailyTasks: [],
        metadata: planData,
      );
      
      // ChatGPT 세션 초기화 (개선된 planData 전달)
      final sessionPlanData = {
        ...planData,
        'id': planId,
        'duration_days': duration,
      };
      await _chatGPTService.initializeSession(tempPlan.id, sessionPlanData);
      
      print('🤖 ChatGPT 세션 초기화 완료');
      
      // 첫 주 콘텐츠 생성
      print('📚 첫 주 학습 콘텐츠 생성 시작...');
      final weeklyContent = await _dailyContentService.generateWeeklyContent(
        tempPlan,
        DateTime.now(),
      );
      
      print('✅ 생성된 일일 콘텐츠: ${weeklyContent.length}개');
      
      // 최종 플랜 생성 (dailyTasks 포함)
      final updatedPlan = LearningPlan(
        id: tempPlan.id,
        userId: tempPlan.userId,
        goal: tempPlan.goal,
        subject: tempPlan.subject,
        level: tempPlan.level,
        durationDays: tempPlan.durationDays,
        startDate: tempPlan.startDate,
        endDate: tempPlan.endDate,
        status: tempPlan.status,
        planType: tempPlan.planType,
        curriculum: tempPlan.curriculum,
        dailyTasks: weeklyContent,
        metadata: tempPlan.metadata,
      );
      
      // 플랜 저장
      _plans.add(updatedPlan);
      _activePlan = updatedPlan;
      await _savePlansLocally();
      
      _state = LearningPlanState.loaded;
      notifyListeners();
      
      return updatedPlan;
    } catch (e) {
      _errorMessage = e.toString();
      _state = LearningPlanState.error;
      notifyListeners();
      return null;
    }
  }
  
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
          'model': 'gpt-5-nano',
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
          'temperature': 1,
          'max_completion_tokens': 2000,
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
  
  // 학습 플랜 생성 및 저장 (기존 메서드 사용 - createLearningPlan)
  Future<bool> createLearningPlanLegacy({
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
  
  // 일일 콘텐츠 생성 (실제 구현 - 추후 ChatGPT 호출로 대체)
  Future<Map<String, dynamic>> _generateDailyContent({
    required String subject,
    required String level,
    required int week,
    required int day,
    required Map<String, dynamic> curriculum,
  }) async {
    // 실제로는 ChatGPT API를 호출해야 하지만,
    // 현재는 커리큘럼 기반의 구조화된 콘텐츠를 생성
    
    String focusArea = '기본 개념';
    List<String> todayTopics = ['기본 개념'];
    
    // 커리큘럼에서 해당 주차 정보 추출
    if (curriculum['weekly_breakdown'] != null) {
      final weeks = curriculum['weekly_breakdown'] as List;
      if (week <= weeks.length && weeks[week - 1] is Map) {
        final weekData = weeks[week - 1] as Map;
        focusArea = weekData['focus'] ?? focusArea;
        if (weekData['topics'] is List) {
          todayTopics = (weekData['topics'] as List).map((t) => t.toString()).toList();
        }
      }
    }
    
    // 오늘의 구체적인 주제 선택
    final todayMainTopic = todayTopics.isNotEmpty 
      ? todayTopics[(day - 1) % todayTopics.length]
      : '$subject Day $day';
    
    return {
      'title': '$subject Week $week Day $day: $todayMainTopic',
      'description': '$focusArea 중심으로 $todayMainTopic을 학습합니다.',
      'topics': [todayMainTopic, '$focusArea 적용', '실전 연습'],
      'morning': {
        'title': '$todayMainTopic 기본 개념',
        'content': '''
📚 $todayMainTopic 핵심 정리

오늘의 학습 목표:
• $todayMainTopic의 기본 개념 이해
• 핵심 원리와 특징 파악
• 실제 적용 방법 학습

주요 학습 포인트:
1. 기본 정의와 개념
2. 중요한 특징과 원리
3. 다른 개념과의 연관성
4. 실생활 적용 사례

💡 학습 팁: 개념을 자신의 말로 설명할 수 있을 때까지 반복 학습하세요.
'''
      },
      'afternoon': {
        'title': '$todayMainTopic 실전 문제',
        'content': '학습한 $todayMainTopic 내용을 문제를 통해 확인해보세요.',
        'questions': [
          {
            'question': '$todayMainTopic에 대한 설명으로 옳은 것은?',
            'options': [
              '기본적인 개념을 나타내는 선택지',
              '일반적인 특징을 설명하는 선택지',
              '올바른 정답을 포함한 선택지',
              '잘못된 정보를 포함한 선택지'
            ],
            'correct': 2,
            'explanation': '$todayMainTopic의 핵심은 정확한 개념 이해입니다. 기본 원리를 숙지하고 응용할 수 있어야 합니다.'
          },
          {
            'question': '$todayMainTopic을 실제로 적용할 때 고려해야 할 점은?',
            'options': [
              '이론적 배경만 고려',
              '실용적 측면만 고려',
              '이론과 실무를 균형있게 고려',
              '결과만 중요시'
            ],
            'correct': 2,
            'explanation': '이론적 이해와 실무 적용능력을 모두 갖추는 것이 중요합니다.'
          }
        ]
      },
      'evening': {
        'title': '$todayMainTopic 정리 및 복습',
        'content': '''
🌙 오늘 학습 내용 정리

1. 학습한 내용 요약
   • $todayMainTopic의 기본 개념
   • 주요 특징과 원리
   • 실전 문제 해결 방법

2. 중요 포인트 재확인
   • 핵심 개념의 정확한 이해
   • 문제 해결 과정의 논리
   • 실제 적용 가능성

3. 내일을 위한 준비
   • 오늘 학습의 연장선에서 내일 주제 미리보기
   • 부족한 부분 체크 및 보완 계획
   • 학습 진도 점검

🎯 성취도 체크: 오늘의 학습 목표를 달성했는지 스스로 평가해보세요.
'''
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
      
      // 먼저 로컬 스토리지에서 불러오기
      await _loadPlansFromLocal();
      
      // 서버에서 플랜 불러오기 (추후 구현)
      // try {
      //   final response = await _apiService.get('/learning-plans');
      //   if (response.statusCode == 200) {
      //     // 서버 데이터로 업데이트
      //   }
      // } catch (serverError) {
      //   print('서버 연결 실패, 로컬 데이터 사용: $serverError');
      // }
      
      _state = LearningPlanState.loaded;
      notifyListeners();
      
      print('🔄 플랜 로딩 완료: ${_plans.length}개 플랜, 활성 플랜: ${_activePlan?.subject ?? '없음'}');
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
    await _savePlansLocally();
  }
  
  // 작업 완료 업데이트 (quiz_screen에서 사용)
  Future<void> updateTaskCompletion(
    String planId,
    DateTime date,
    String timeOfDay,
    bool completed,
  ) async {
    if (_activePlan == null || _activePlan!.id != planId) return;
    
    // 해당 날짜의 태스크 찾기
    final taskIndex = _activePlan!.dailyTasks.indexWhere((task) =>
      task.date.year == date.year &&
      task.date.month == date.month &&
      task.date.day == date.day
    );
    
    if (taskIndex == -1) return;
    
    // 시간대별 완료 상태 업데이트
    _activePlan!.dailyTasks[taskIndex].completionStatus[timeOfDay] = completed;
    
    // 전체 완료 체크
    final allCompleted = _activePlan!.dailyTasks[taskIndex]
        .completionStatus.values.every((v) => v == true);
    
    if (allCompleted) {
      debugPrint('✅ 오늘의 모든 학습이 완료되었습니다!');
    }
    
    notifyListeners();
    await _savePlansLocally();
  }
  
  // 다음 주 콘텐츠 생성
  Future<void> generateNextWeekContent() async {
    if (_activePlan == null) return;
    
    try {
      _state = LearningPlanState.loading;
      notifyListeners();
      
      // 마지막 태스크의 날짜 확인
      if (_activePlan!.dailyTasks.isEmpty) return;
      
      final lastTask = _activePlan!.dailyTasks.last;
      final nextWeekStart = lastTask.date.add(const Duration(days: 1));
      
      // 다음 주 콘텐츠 생성
      final nextWeekContent = await _dailyContentService.generateWeeklyContent(
        _activePlan!,
        nextWeekStart,
      );
      
      // 플랜에 추가
      _activePlan!.dailyTasks.addAll(nextWeekContent);
      
      await _savePlansLocally();
      
      _state = LearningPlanState.loaded;
      notifyListeners();
      
      debugPrint('📅 다음 주 학습 콘텐츠가 준비되었습니다!');
    } catch (e) {
      _errorMessage = '콘텐츠 생성 실패: $e';
      _state = LearningPlanState.error;
      notifyListeners();
    }
  }
  
  // 알림 권한 요청
  Future<bool> requestNotificationPermissions() async {
    return await _dailyContentService.requestNotificationPermissions();
  }
  
  // 플랜 일시정지
  Future<void> pausePlan(String planId) async {
    final planIndex = _plans.indexWhere((p) => p.id == planId);
    if (planIndex == -1) return;
    
    // 알림 취소
    await _dailyContentService.cancelPlanNotifications(planId);
    
    // 상태 업데이트
    _plans[planIndex] = LearningPlan(
      id: _plans[planIndex].id,
      userId: _plans[planIndex].userId,
      goal: _plans[planIndex].goal,
      subject: _plans[planIndex].subject,
      level: _plans[planIndex].level,
      durationDays: _plans[planIndex].durationDays,
      startDate: _plans[planIndex].startDate,
      endDate: _plans[planIndex].endDate,
      status: PlanStatus.paused,
      planType: _plans[planIndex].planType,
      curriculum: _plans[planIndex].curriculum,
      dailyTasks: _plans[planIndex].dailyTasks,
      metadata: _plans[planIndex].metadata,
    );
    
    if (_activePlan?.id == planId) {
      _activePlan = _plans[planIndex];
    }
    
    await _savePlansLocally();
    notifyListeners();
  }
  
  // 플랜 재개
  Future<void> resumePlan(String planId) async {
    final planIndex = _plans.indexWhere((p) => p.id == planId);
    if (planIndex == -1) return;
    
    // 알림 재스케줄
    for (final task in _plans[planIndex].dailyTasks) {
      if (task.date.isAfter(DateTime.now())) {
        await _dailyContentService.scheduleNotifications(task, task.date);
      }
    }
    
    // 상태 업데이트
    _plans[planIndex] = LearningPlan(
      id: _plans[planIndex].id,
      userId: _plans[planIndex].userId,
      goal: _plans[planIndex].goal,
      subject: _plans[planIndex].subject,
      level: _plans[planIndex].level,
      durationDays: _plans[planIndex].durationDays,
      startDate: _plans[planIndex].startDate,
      endDate: _plans[planIndex].endDate,
      status: PlanStatus.active,
      planType: _plans[planIndex].planType,
      curriculum: _plans[planIndex].curriculum,
      dailyTasks: _plans[planIndex].dailyTasks,
      metadata: _plans[planIndex].metadata,
    );
    
    if (_activePlan?.id == planId) {
      _activePlan = _plans[planIndex];
    }
    
    await _savePlansLocally();
    notifyListeners();
  }
  
  // 플랜을 로컬 스토리지에 저장
  Future<void> _savePlansLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 모든 플랜을 JSON으로 변환하여 저장
      final plansJson = _plans.map((plan) => plan.toJson()).toList();
      await prefs.setString('learning_plans', json.encode(plansJson));
      
      // 활성 플랜 ID 저장
      if (_activePlan != null) {
        await prefs.setString('active_plan_id', _activePlan!.id);
      }
      
      print('📱 학습 플랜이 로컬 스토리지에 저장되었습니다.');
    } catch (e) {
      print('❌ 로컬 스토리지 저장 실패: $e');
    }
  }

  // 로컬 스토리지에서 플랜 불러오기
  Future<void> _loadPlansFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 저장된 플랜들 불러오기
      final plansJsonString = prefs.getString('learning_plans');
      if (plansJsonString != null) {
        final List<dynamic> plansJson = json.decode(plansJsonString);
        _plans = plansJson.map((planJson) => LearningPlan.fromJson(planJson)).toList();
      }
      
      // 활성 플랜 설정
      final activePlanId = prefs.getString('active_plan_id');
      if (activePlanId != null) {
        _activePlan = _plans.firstWhereOrNull((plan) => plan.id == activePlanId);
      }
      
      print('📱 로컬 스토리지에서 ${_plans.length}개의 플랜을 불러왔습니다.');
    } catch (e) {
      print('❌ 로컬 스토리지 불러오기 실패: $e');
      _plans = [];
      _activePlan = null;
    }
  }

  // 시스템 상태 체크 (디버깅용)
  void checkSystemStatus() {
    print('🔍 StudyMate 학습 플래너 시스템 상태 체크');
    print('  - ChatGPT 서비스: ${_chatGPTService != null ? '✅ 초기화됨' : '❌ 초기화 안됨'}');
    print('  - 일일 콘텐츠 서비스: ${_dailyContentService != null ? '✅ 초기화됨' : '❌ 초기화 안됨'}');
    print('  - 알림 서비스: ${_notifications != null ? '✅ 초기화됨' : '❌ 초기화 안됨'}');
    print('  - 현재 플랜 수: ${_plans.length}개');
    print('  - 활성 플랜: ${_activePlan?.subject ?? '없음'}');
    print('  - API 키 설정: ${_openAIApiKey != 'YOUR_OPENAI_API_KEY' ? '✅ 설정됨' : '❌ 기본값 사용'}');
    
    if (_activePlan != null) {
      print('  - 활성 플랜 일일 태스크: ${_activePlan!.dailyTasks.length}개');
      print('  - 오늘의 태스크: ${_activePlan!.todayTask != null ? '✅ 있음' : '❌ 없음'}');
    }
  }

}