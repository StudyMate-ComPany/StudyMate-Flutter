import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    await _requestPermissions();
  }
  
  Future<void> _requestPermissions() async {
    await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    
    await _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  
  // 온보딩에서 호출할 권한 요청 메서드
  Future<void> requestPermission() async {
    await _requestPermissions();
  }
  
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('알림 탭됨: ${response.payload}');
  }
  
  // 일일 학습 알림 스케줄링 (9시, 12시, 21시)
  Future<void> scheduleDailyStudyReminders() async {
    try {
      await _cancelAllNotifications();
      
      // 아침 9시 알림
      await _scheduleDaily(
        id: 1,
        hour: 9,
        minute: 0,
        title: '🌅 오늘의 학습 시작!',
        body: '새로운 하루의 학습을 시작해보세요. 오늘의 목표를 확인하세요!',
        payload: 'morning_study',
      );
      
      // 점심 12시 알림
      await _scheduleDaily(
        id: 2,
        hour: 12,
        minute: 0,
        title: '📚 점심 학습 시간',
        body: '잠깐! 오늘의 학습 진도를 확인하고 퀴즈를 풀어보세요.',
        payload: 'afternoon_study',
      );
      
      // 저녁 21시 알림
      await _scheduleDaily(
        id: 3,
        hour: 21,
        minute: 0,
        title: '🌙 오늘의 학습 마무리',
        body: '하루를 마무리하며 오늘 배운 내용을 복습해보세요.',
        payload: 'evening_study',
      );
      
      debugPrint('✅ 일일 학습 알림이 설정되었습니다 (9시, 12시, 21시)');
    } catch (e) {
      debugPrint('⚠️ 알림 스케줄링 실패 (권한 없음): $e');
      // 알림 권한이 없어도 앱은 정상 작동하도록 에러를 무시
    }
  }
  
  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
    required String payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    
    // 이미 지난 시간이면 다음 날로 설정
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    try {
      // 먼저 정확한 알람으로 시도
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'study_reminders',
            '학습 알림',
            channelDescription: '일일 학습 알림을 위한 채널',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // 매일 반복
        payload: payload,
      );
    } catch (e) {
      // 정확한 알람 권한이 없으면 일반 모드로 재시도
      try {
        await _notifications.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'study_reminders',
              '학습 알림',
              channelDescription: '일일 학습 알림을 위한 채널',
              importance: Importance.high,
              priority: Priority.high,
              showWhen: true,
              enableVibration: true,
              playSound: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexact,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time, // 매일 반복
          payload: payload,
        );
        debugPrint('⚠️ 정확한 알람 권한 없음, 대략적인 알람으로 설정됨');
      } catch (e2) {
        debugPrint('❌ 알람 설정 실패: $e2');
      }
    }
  }
  
  // 즉시 알림 표시
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'instant_notifications',
        '즉시 알림',
        channelDescription: '즉시 표시되는 알림',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }
  
  // 학습 완료 알림
  Future<void> showStudyCompletionNotification({
    required String subject,
    required int minutes,
  }) async {
    await showInstantNotification(
      title: '🎉 학습 완료!',
      body: '$subject 학습을 $minutes분 동안 완료했습니다. 수고하셨어요!',
      payload: 'study_completed',
    );
  }
  
  // 퀴즈 알림
  Future<void> showQuizReminderNotification() async {
    await showInstantNotification(
      title: '🧩 퀴즈 시간!',
      body: '오늘의 학습 내용을 확인하는 퀴즈를 풀어보세요.',
      payload: 'quiz_reminder',
    );
  }
  
  // 모든 알림 취소
  Future<void> _cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
  
  // 특정 알림 취소
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
  
  // 알림 권한 상태 확인
  Future<bool> hasPermission() async {
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final granted = await androidImplementation.areNotificationsEnabled();
      return granted ?? false;
    }
    
    // iOS의 경우
    final iosImplementation = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (iosImplementation != null) {
      // iOS 권한 확인 로직
      return true; // 기본적으로 true 반환
    }
    
    return false;
  }
}