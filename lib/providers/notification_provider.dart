import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';

class NotificationProvider with ChangeNotifier {
  static const String _notificationEnabledKey = 'notificationsEnabled';
  static const String _studyReminderKey = 'studyReminder';
  static const String _goalReminderKey = 'goalReminder';
  static const String _reminderTimeKey = 'reminderTime';
  
  bool _notificationsEnabled = false;
  bool _studyReminder = true;
  bool _goalReminder = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _hasPermission = false;
  
  bool get notificationsEnabled => _notificationsEnabled;
  bool get studyReminder => _studyReminder;
  bool get goalReminder => _goalReminder;
  TimeOfDay get reminderTime => _reminderTime;
  bool get hasPermission => _hasPermission;
  
  NotificationProvider() {
    _loadSettings();
    _checkPermission();
  }
  
  /// 설정 불러오기
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_notificationEnabledKey) ?? false;
    _studyReminder = prefs.getBool(_studyReminderKey) ?? true;
    _goalReminder = prefs.getBool(_goalReminderKey) ?? true;
    
    final hour = prefs.getInt('${_reminderTimeKey}_hour') ?? 9;
    final minute = prefs.getInt('${_reminderTimeKey}_minute') ?? 0;
    _reminderTime = TimeOfDay(hour: hour, minute: minute);
    
    notifyListeners();
  }
  
  /// 권한 확인
  Future<void> _checkPermission() async {
    final status = await Permission.notification.status;
    _hasPermission = status.isGranted;
    
    if (_hasPermission && _notificationsEnabled) {
      // 알림이 활성화되어 있고 권한도 있는 경우
      Logger.info('알림 권한 확인 완료: 허용됨');
    }
    
    notifyListeners();
  }
  
  /// 알림 토글
  Future<bool> toggleNotifications() async {
    if (!_hasPermission) {
      // 권한 요청
      final status = await Permission.notification.request();
      _hasPermission = status.isGranted;
      
      if (!_hasPermission) {
        Logger.warning('알림 권한이 거부되었습니다');
        return false;
      }
    }
    
    _notificationsEnabled = !_notificationsEnabled;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, _notificationsEnabled);
    
    if (_notificationsEnabled) {
      await _scheduleNotifications();
    } else {
      await _cancelAllNotifications();
    }
    
    notifyListeners();
    return true;
  }
  
  /// 학습 리마인더 토글
  Future<void> toggleStudyReminder() async {
    _studyReminder = !_studyReminder;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_studyReminderKey, _studyReminder);
    
    if (_studyReminder && _notificationsEnabled) {
      await _scheduleStudyReminder();
    }
    
    notifyListeners();
  }
  
  /// 목표 리마인더 토글
  Future<void> toggleGoalReminder() async {
    _goalReminder = !_goalReminder;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_goalReminderKey, _goalReminder);
    
    if (_goalReminder && _notificationsEnabled) {
      await _scheduleGoalReminder();
    }
    
    notifyListeners();
  }
  
  /// 리마인더 시간 설정
  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_reminderTimeKey}_hour', time.hour);
    await prefs.setInt('${_reminderTimeKey}_minute', time.minute);
    
    // 새로운 시간으로 알림 재설정
    if (_notificationsEnabled) {
      await _scheduleNotifications();
    }
    
    notifyListeners();
  }
  
  /// 알림 예약
  Future<void> _scheduleNotifications() async {
    if (_studyReminder) {
      await _scheduleStudyReminder();
    }
    if (_goalReminder) {
      await _scheduleGoalReminder();
    }
  }
  
  /// 학습 리마인더 예약
  Future<void> _scheduleStudyReminder() async {
    // 실제 구현시 flutter_local_notifications 패키지 사용
    Logger.info('학습 리마인더 예약: ${_reminderTime.hour}:${_reminderTime.minute.toString().padLeft(2, '0')}');
  }
  
  /// 목표 리마인더 예약
  Future<void> _scheduleGoalReminder() async {
    // 실제 구현시 flutter_local_notifications 패키지 사용
    Logger.info('목표 리마인더 예약: 매주 일요일');
  }
  
  /// 모든 알림 취소
  Future<void> _cancelAllNotifications() async {
    // 실제 구현시 flutter_local_notifications 패키지 사용
    Logger.info('모든 알림 취소');
  }
  
  /// 권한 설정 열기
  Future<void> openSettings() async {
    await openAppSettings();
  }
}