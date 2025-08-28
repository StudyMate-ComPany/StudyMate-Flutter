import 'package:flutter/foundation.dart';
import '../models/study_goal.dart';
import '../models/study_session.dart';
import '../services/api_service.dart';

enum StudyState { loading, loaded, error }

class StudyProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  StudyState _state = StudyState.loading;
  List<StudyGoal> _goals = [];
  List<StudySession> _sessions = [];
  StudySession? _activeSession;
  String? _errorMessage;
  bool _isInitialized = false;

  StudyState get state => _state;
  List<StudyGoal> get goals => _goals;
  List<StudySession> get sessions => _sessions;
  StudySession? get activeSession => _activeSession;
  String? get errorMessage => _errorMessage;

  StudyProvider() {
    // Don't load data in constructor, wait for auth
  }

  Future<void> initializeWithAuth() async {
    if (!_isInitialized) {
      _isInitialized = true;
      await _loadInitialData();
    }
  }

  Future<void> _loadInitialData() async {
    await loadGoals();
    await loadSessions();
  }

  Future<void> loadGoals() async {
    try {
      _setState(StudyState.loading);
      debugPrint('📚 Loading study goals...');
      _goals = await _apiService.getStudyGoals();
      debugPrint('✅ Loaded ${_goals.length} goals');
      _setState(StudyState.loaded);
    } catch (e) {
      debugPrint('❌ Failed to load goals: $e');
      _setError('학습 목표를 불러오는데 실패했습니다: $e');
    }
  }

  Future<void> loadSessions({DateTime? startDate, DateTime? endDate}) async {
    try {
      if (_state != StudyState.loading) {
        _setState(StudyState.loading);
      }
      
      _sessions = await _apiService.getStudySessions(
        startDate: startDate,
        endDate: endDate,
      );
      
      // Find active session
      // 안전한 활성 세션 찾기
      try {
        _activeSession = _sessions.firstWhere(
          (session) => session.isActive,
        );
      } catch (e) {
        // 활성 세션이 없는 경우 null로 설정
        _activeSession = null;
      }
      
      _setState(StudyState.loaded);
    } catch (e) {
      if (_sessions.isEmpty) {
        _setError('학습 세션을 불러오는데 실패했습니다: $e');
      } else {
        // 이미 세션이 있는 경우 디버그 메시지만 표시
        debugPrint('세션 새로고침 실패: $e');
      }
    }
  }

  Future<bool> createGoal({
    required String title,
    required String description,
    required GoalType type,
    required DateTime startDate,
    required DateTime endDate,
    required int targetHours,
    int targetSummaries = 0,
    int targetQuizzes = 0,
  }) async {
    try {
      // Convert hours to duration string format
      final targetStudyTime = '$targetHours:00:00';
      
      final goalData = {
        'title': title,
        'description': description,
        'goal_type': type.name,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate.toIso8601String().split('T')[0],
        'target_study_time': targetStudyTime,
        'target_summaries': targetSummaries,
        'target_quizzes': targetQuizzes,
      };

      final newGoal = await _apiService.createStudyGoal(goalData);
      _goals.add(newGoal);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('목표를 생성하는데 실패했습니다: $e');
      return false;
    }
  }

  Future<bool> updateGoal(StudyGoal goal) async {
    try {
      final updatedGoal = await _apiService.updateStudyGoal(goal.id, goal.toJson());
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = updatedGoal;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError('목표를 업데이트하는데 실패했습니다: $e');
      return false;
    }
  }

  Future<bool> deleteGoal(String goalId) async {
    try {
      await _apiService.deleteStudyGoal(goalId);
      _goals.removeWhere((goal) => goal.id == goalId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('목표를 삭제하는데 실패했습니다: $e');
      return false;
    }
  }

  Future<bool> startStudySession({
    required String subject,
    String? topic,
    String? goalId,
    int plannedDuration = 25,
    SessionType type = SessionType.focused,
  }) async {
    try {
      print('[StudyProvider] startStudySession 호출됨');
      print('[StudyProvider] subject: $subject, topic: $topic, plannedDuration: $plannedDuration, type: ${type.name}');
      
      if (_activeSession != null && _activeSession!.isActive) {
        print('[StudyProvider] 이미 활성 세션이 있음: ${_activeSession!.subject}');
        throw Exception('학습 세션이 이미 진행 중입니다');
      }

      final sessionData = {
        'subject': subject,
        'topic': topic,
        'goal_id': goalId,
        'type': type.name,
        'status': SessionStatus.active.name,
        'planned_duration': plannedDuration,
        'start_time': DateTime.now().toIso8601String(),
      };

      print('[StudyProvider] API 호출 전 sessionData: $sessionData');
      final newSession = await _apiService.createStudySession(sessionData);
      print('[StudyProvider] API 응답: 세션 생성됨 - ${newSession.id}');
      
      _activeSession = newSession;
      _sessions.insert(0, newSession);
      notifyListeners();
      print('[StudyProvider] 세션 시작 성공');
      return true;
    } catch (e) {
      print('[StudyProvider ERROR] 세션 시작 실패: $e');
      _setError('학습 세션을 시작하는데 실패했습니다: $e');
      return false;
    }
  }

  Future<bool> pauseStudySession() async {
    if (_activeSession == null || !_activeSession!.isActive) {
      return false;
    }

    try {
      final updatedSession = _activeSession!.copyWith(
        status: SessionStatus.paused,
      );
      
      await _apiService.updateStudySession(_activeSession!.id, updatedSession.toJson());
      _activeSession = updatedSession;
      _updateSessionInList(updatedSession);
      return true;
    } catch (e) {
      _setError('학습 세션을 일시정지하는데 실패했습니다: $e');
      return false;
    }
  }

  Future<bool> resumeStudySession() async {
    if (_activeSession == null || !_activeSession!.isPaused) {
      return false;
    }

    try {
      final updatedSession = _activeSession!.copyWith(
        status: SessionStatus.active,
      );
      
      await _apiService.updateStudySession(_activeSession!.id, updatedSession.toJson());
      _activeSession = updatedSession;
      _updateSessionInList(updatedSession);
      return true;
    } catch (e) {
      _setError('학습 세션을 재개하는데 실패했습니다: $e');
      return false;
    }
  }

  Future<bool> endStudySession({String? notes, int? focusScore}) async {
    if (_activeSession == null) {
      return false;
    }

    try {
      final endTime = DateTime.now();
      final actualDuration = endTime.difference(_activeSession!.startTime).inMinutes;
      
      final updatedSession = _activeSession!.copyWith(
        status: SessionStatus.completed,
        endTime: endTime,
        actualDuration: actualDuration,
        notes: notes,
        focusScore: focusScore,
      );
      
      await _apiService.updateStudySession(_activeSession!.id, updatedSession.toJson());
      
      // Update goal progress if session is linked to a goal
      if (_activeSession!.goalId != null) {
        await _updateGoalProgress(_activeSession!.goalId!, actualDuration);
      }
      
      _activeSession = null;
      _updateSessionInList(updatedSession);
      return true;
    } catch (e) {
      _setError('학습 세션을 종료하는데 실패했습니다: $e');
      return false;
    }
  }

  Future<void> _updateGoalProgress(String goalId, int studyMinutes) async {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex != -1) {
      final goal = _goals[goalIndex];
      final studyHours = studyMinutes / 60.0;
      // Convert study hours to duration string
      final newHours = goal.completedHours + studyHours.round();
      final newStudyTime = '$newHours:00:00';
      
      final updatedGoal = goal.copyWith(
        currentStudyTime: newStudyTime,
        updatedAt: DateTime.now(),
      );
      
      if (updatedGoal.isCompleted && updatedGoal.status != 'completed') {
        final completedGoal = updatedGoal.copyWith(status: 'completed');
        await updateGoal(completedGoal);
      } else {
        await updateGoal(updatedGoal);
      }
    }
  }

  void _updateSessionInList(StudySession session) {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      _sessions[index] = session;
      notifyListeners();
    }
  }

  List<StudyGoal> get activeGoals {
    return _goals.where((goal) => goal.status == 'active').toList();
  }

  List<StudyGoal> get completedGoals {
    return _goals.where((goal) => goal.status == 'completed').toList();
  }

  List<StudySession> getSessionsForGoal(String goalId) {
    return _sessions.where((session) => session.goalId == goalId).toList();
  }

  List<StudySession> getSessionsForDateRange(DateTime start, DateTime end) {
    return _sessions.where((session) {
      return session.startTime.isAfter(start) && session.startTime.isBefore(end);
    }).toList();
  }

  Map<String, dynamic> getStudyStatistics() {
    final totalSessions = _sessions.length;
    final completedSessions = _sessions.where((s) => s.isCompleted).length;
    final totalStudyTime = _sessions
        .where((s) => s.actualDuration != null)
        .fold<int>(0, (sum, s) => sum + s.actualDuration!);
    
    final averageSessionTime = completedSessions > 0 
        ? totalStudyTime / completedSessions 
        : 0.0;
    
    final completedGoalsCount = completedGoals.length;
    final activeGoalsCount = activeGoals.length;
    
    return {
      'total_sessions': totalSessions,
      'completed_sessions': completedSessions,
      'total_study_time_minutes': totalStudyTime,
      'average_session_time_minutes': averageSessionTime,
      'completed_goals': completedGoalsCount,
      'active_goals': activeGoalsCount,
    };
  }

  void clearError() {
    _errorMessage = null;
    if (_state == StudyState.error) {
      _setState(StudyState.loaded);
    }
  }

  void _setState(StudyState newState) {
    _state = newState;
    if (newState != StudyState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _state = StudyState.error;
    notifyListeners();
  }
}