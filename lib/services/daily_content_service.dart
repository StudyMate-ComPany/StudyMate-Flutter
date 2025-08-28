import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/learning_plan.dart';
import 'chatgpt_session_service.dart';
import 'package:uuid/uuid.dart';

class DailyContentService {
  final ChatGPTSessionService _chatGPTService;
  final FlutterLocalNotificationsPlugin _notifications;
  final _uuid = const Uuid();
  
  DailyContentService({
    required ChatGPTSessionService chatGPTService,
    required FlutterLocalNotificationsPlugin notifications,
  })  : _chatGPTService = chatGPTService,
        _notifications = notifications {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
  }
  
  // 하루치 학습 콘텐츠 생성
  Future<DailyTask> generateDailyContent(
    LearningPlan plan,
    DateTime date,
    List<String> topics,
  ) async {
    print('📚 ${date.toString().split(' ')[0]} 학습 콘텐츠 생성 시작');
    
    // 오전 콘텐츠 (요약)
    final morningContent = await _generateContent(
      plan.id,
      topics.first,
      'morning',
      'summary',
    );
    
    // 오후 콘텐츠 (문제)
    final afternoonContent = await _generateContent(
      plan.id,
      topics.length > 1 ? topics[1] : topics.first,
      'afternoon',
      'quiz',
    );
    
    // 저녁 콘텐츠 (복습 문제)
    final eveningContent = await _generateContent(
      plan.id,
      topics.join(', '),
      'evening',
      'quiz',
    );
    
    final dailyTask = DailyTask(
      id: _uuid.v4(),
      planId: plan.id,
      date: date,
      title: '${plan.subject} Day ${_getDayNumber(plan.startDate, date)}',
      description: '오늘의 학습 주제: ${topics.join(', ')}',
      topics: topics,
      morningContent: morningContent,
      afternoonContent: afternoonContent,
      eveningContent: eveningContent,
      completionStatus: {
        'morning': false,
        'afternoon': false,
        'evening': false,
      },
    );
    
    // 알림 스케줄링
    await _scheduleNotifications(dailyTask, date);
    
    print('✅ 학습 콘텐츠 생성 완료');
    return dailyTask;
  }
  
  // 콘텐츠 생성
  Future<StudyContent> _generateContent(
    String planId,
    String topic,
    String timeOfDay,
    String type,
  ) async {
    Map<String, dynamic> contentData;
    
    if (type == 'summary') {
      contentData = await _chatGPTService.generateSummary(
        planId,
        topic,
        timeOfDay,
      );
    } else {
      final questionCount = timeOfDay == 'evening' ? 5 : 3;
      contentData = await _chatGPTService.generateQuiz(
        planId,
        topic,
        timeOfDay,
        questionCount,
      );
    }
    
    // QuizQuestion 객체 생성
    List<QuizQuestion>? questions;
    if (contentData['questions'] != null) {
      questions = (contentData['questions'] as List).map((q) {
        return QuizQuestion(
          id: _uuid.v4(),
          question: q['question'] ?? '',
          options: List<String>.from(q['options'] ?? []),
          correctAnswer: q['correct_answer'] ?? 0,
          explanation: q['explanation'] ?? '',
        );
      }).toList();
    }
    
    return StudyContent(
      type: type,
      title: contentData['title'] ?? '$topic 학습',
      content: contentData['content'] ?? '',
      questions: questions,
      estimatedMinutes: _getEstimatedMinutes(type, timeOfDay),
      notificationId: _uuid.v4(),
    );
  }
  
  // 알림 스케줄링 (public 메소드)
  Future<void> scheduleNotifications(DailyTask task, DateTime date) async {
    return _scheduleNotifications(task, date);
  }

  // 알림 스케줄링 (internal)
  Future<void> _scheduleNotifications(DailyTask task, DateTime date) async {
    // 오전 9시 알림
    await _scheduleNotification(
      task.morningContent,
      date.add(const Duration(hours: 9)),
      '오전 학습 시간입니다 📚',
      task.morningContent.title,
    );
    
    // 오후 12시 알림
    await _scheduleNotification(
      task.afternoonContent,
      date.add(const Duration(hours: 12)),
      '점심 후 학습 시간입니다 🍽️📖',
      task.afternoonContent.title,
    );
    
    // 저녁 9시 알림
    await _scheduleNotification(
      task.eveningContent,
      date.add(const Duration(hours: 21)),
      '오늘의 마지막 학습 시간입니다 🌙',
      task.eveningContent.title,
    );
  }
  
  // 개별 알림 스케줄
  Future<void> _scheduleNotification(
    StudyContent content,
    DateTime scheduledTime,
    String title,
    String body,
  ) async {
    // 과거 시간이면 스케줄하지 않음
    if (scheduledTime.isBefore(DateTime.now())) {
      return;
    }
    
    final androidDetails = AndroidNotificationDetails(
      'study_reminder',
      '학습 알림',
      channelDescription: '일일 학습 알림',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      styleInformation: BigTextStyleInformation(
        '${content.type == 'summary' ? '📖 요약' : '✏️ 문제'}: ${content.content.substring(0, min(100, content.content.length))}...',
        contentTitle: title,
        summaryText: '예상 소요 시간: ${content.estimatedMinutes}분',
      ),
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );
    
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    // 고유 ID 생성 (날짜와 시간 기반)
    final notificationId = scheduledTime.millisecondsSinceEpoch ~/ 1000;
    
    await _notifications.zonedSchedule(
      notificationId,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: '${content.notificationId}',
    );
    
    print('📅 알림 예약: $scheduledTime - $title');
  }
  
  // 주간 콘텐츠 일괄 생성
  Future<List<DailyTask>> generateWeeklyContent(
    LearningPlan plan,
    DateTime startDate,
  ) async {
    final tasks = <DailyTask>[];
    final curriculum = plan.curriculum;
    final weeklyTopics = _distributeTopics(curriculum, 7);
    
    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      final topics = weeklyTopics[i];
      
      if (topics.isNotEmpty) {
        final task = await generateDailyContent(plan, date, topics);
        tasks.add(task);
      }
    }
    
    return tasks;
  }
  
  // 주제 분배 (개선된 버전)
  List<List<String>> _distributeTopics(
    Map<String, dynamic> curriculum,
    int days,
  ) {
    final distributed = <List<String>>[];
    
    try {
      // 커리큘럼에서 주제 추출
      List<String> allTopics = [];
      
      // weekly_breakdown에서 주제 추출
      if (curriculum['weekly_breakdown'] != null) {
        final weeks = curriculum['weekly_breakdown'] as List;
        for (var week in weeks) {
          if (week is Map && week['topics'] is List) {
            final topics = (week['topics'] as List).map((t) => t.toString()).toList();
            allTopics.addAll(topics);
          }
        }
      }
      
      // 다른 형태의 커리큘럼에서 주제 추출
      if (allTopics.isEmpty) {
        curriculum.forEach((key, value) {
          if (value is List && key != 'weekly_breakdown') {
            allTopics.addAll(value.map((t) => t.toString()));
          } else if (value is Map && value['topics'] is List) {
            allTopics.addAll((value['topics'] as List).map((t) => t.toString()));
          }
        });
      }
      
      // 기본 주제가 없는 경우 생성
      if (allTopics.isEmpty) {
        allTopics = List.generate(days, (index) => '학습 주제 ${index + 1}');
      }
      
      print('📋 추출된 주제: ${allTopics.length}개 - ${allTopics.take(3).join(', ')}...');
      
      // 일별로 균등 분배
      for (int i = 0; i < days; i++) {
        if (i < allTopics.length) {
          // 각 일자에 1-2개 주제 할당
          final topicsForDay = <String>[];
          
          // 기본 주제
          topicsForDay.add(allTopics[i % allTopics.length]);
          
          // 추가 주제 (복습 또는 심화)
          if (i > 0 && allTopics.length > 1) {
            final reviewTopicIndex = (i - 1) % allTopics.length;
            if (reviewTopicIndex != i % allTopics.length) {
              topicsForDay.add('${allTopics[reviewTopicIndex]} 복습');
            }
          }
          
          distributed.add(topicsForDay);
        } else {
          // 주제가 부족한 경우 이전 주제 복습
          final reviewIndex = i % allTopics.length;
          distributed.add(['${allTopics[reviewIndex]} 심화']);
        }
      }
      
      print('📅 ${days}일간 주제 분배 완료');
      
    } catch (e) {
      print('❌ 주제 분배 오류: $e');
      // 오류 발생 시 기본 주제 생성
      for (int i = 0; i < days; i++) {
        distributed.add(['Day ${i + 1} 학습']);
      }
    }
    
    return distributed;
  }
  
  // 예상 소요 시간 계산
  int _getEstimatedMinutes(String type, String timeOfDay) {
    if (type == 'summary') {
      return 10; // 요약은 10분
    } else {
      // 문제는 시간대별로 다름
      switch (timeOfDay) {
        case 'morning':
          return 15;
        case 'afternoon':
          return 20;
        case 'evening':
          return 25;
        default:
          return 15;
      }
    }
  }
  
  // 학습일 계산
  int _getDayNumber(DateTime startDate, DateTime currentDate) {
    return currentDate.difference(startDate).inDays + 1;
  }
  
  // 알림 권한 요청
  Future<bool> requestNotificationPermissions() async {
    final androidImplementation = 
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }
    
    final iosImplementation = 
        _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    
    if (iosImplementation != null) {
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    
    return true;
  }
  
  // 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
  
  // 특정 플랜의 알림 취소
  Future<void> cancelPlanNotifications(String planId) async {
    // 플랜 ID로 알림을 필터링하여 취소
    final pendingNotifications = await _notifications.pendingNotificationRequests();
    
    for (final notification in pendingNotifications) {
      if (notification.payload?.contains(planId) ?? false) {
        await _notifications.cancel(notification.id);
      }
    }
  }
}