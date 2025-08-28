import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../providers/study_provider.dart';
import '../../providers/ai_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/study_session.dart';
import '../../models/pomodoro_settings.dart';
import '../../services/local_storage_service.dart';
import '../../services/chatgpt_service.dart';
import '../../utils/logger.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'pomodoro_settings_screen.dart';

class PomodoroTimerScreen extends StatefulWidget {
  final String subject;
  final String? topic;
  final String? goalId;
  
  const PomodoroTimerScreen({
    super.key,
    required this.subject,
    this.topic,
    this.goalId,
  });

  @override
  State<PomodoroTimerScreen> createState() => _PomodoroTimerScreenState();
}

class _PomodoroTimerScreenState extends State<PomodoroTimerScreen>
    with SingleTickerProviderStateMixin {
  // Timer settings
  late PomodoroSettings _settings;
  int workMinutes = 25;
  int shortBreakMinutes = 5;
  int longBreakMinutes = 15;
  int sessionsUntilLongBreak = 4;
  
  // Timer state
  Timer? _timer;
  late int _totalSeconds;
  late int _currentSeconds;
  bool _isRunning = false;
  bool _isBreak = false;
  int _completedSessions = 0;
  
  // Animation
  late AnimationController _animationController;
  
  // Study session
  String? _currentSessionId;
  DateTime? _sessionStartTime;
  
  @override
  void initState() {
    super.initState();
    _totalSeconds = workMinutes * 60;
    _currentSeconds = workMinutes * 60;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final stored = await LocalStorageService.getData('pomodoro_settings');
    if (stored != null) {
      setState(() {
        _settings = PomodoroSettings.fromJson(stored);
        workMinutes = _settings.workMinutes;
        shortBreakMinutes = _settings.shortBreakMinutes;
        longBreakMinutes = _settings.longBreakMinutes;
        sessionsUntilLongBreak = _settings.sessionsUntilLongBreak;
        _totalSeconds = workMinutes * 60;
        _currentSeconds = workMinutes * 60;
      });
    } else {
      _settings = const PomodoroSettings();
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _endCurrentSession();
    super.dispose();
  }
  
  void _startTimer() {
    if (!_isRunning) {
      setState(() {
        _isRunning = true;
      });
      
      if (!_isBreak && _currentSessionId == null) {
        _startStudySession();
      }
      
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_currentSeconds > 0) {
            _currentSeconds--;
          } else {
            _completeSession();
          }
        });
      });
    }
  }
  
  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
    
    if (!_isBreak && _currentSessionId != null) {
      // Pause the study session
      context.read<StudyProvider>().pauseStudySession();
    }
  }
  
  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _currentSeconds = _totalSeconds;
    });
  }
  
  void _skipSession() {
    _completeSession();
  }
  
  void _completeSession() {
    _timer?.cancel();
    
    if (!_isBreak) {
      _completedSessions++;
      _endCurrentSession();
      _requestAISummary(); // AI 요약 요청
      
      // Determine break type
      if (_completedSessions % sessionsUntilLongBreak == 0) {
        _startLongBreak();
      } else {
        _startShortBreak();
      }
      
      // Auto start if enabled
      if (_settings.autoStartBreaks) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _startTimer();
        });
      }
    } else {
      _startWorkSession();
      
      // Auto start if enabled
      if (_settings.autoStartPomodoros) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) _startTimer();
        });
      }
    }
  }
  
  Future<void> _requestAISummary() async {
    try {
      final chatGPTService = ChatGPTService();
      final summary = await chatGPTService.askQuestion(
        '방금 완료한 ${widget.subject} ${widget.topic ?? ""} 포모도로 세션에 대해 짧은 격려 메시지를 작성해주세요.',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(summary),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: '닫기',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      Logger.error('AI 요약 생성 실패: $e');
    }
  }
  
  void _startWorkSession() {
    setState(() {
      _isBreak = false;
      _totalSeconds = workMinutes * 60;
      _currentSeconds = workMinutes * 60;
      _isRunning = false;
    });
  }
  
  void _startShortBreak() {
    setState(() {
      _isBreak = true;
      _totalSeconds = shortBreakMinutes * 60;
      _currentSeconds = shortBreakMinutes * 60;
      _isRunning = false;
    });
    
    _showBreakNotification('Short Break', shortBreakMinutes);
  }
  
  void _startLongBreak() {
    setState(() {
      _isBreak = true;
      _totalSeconds = longBreakMinutes * 60;
      _currentSeconds = longBreakMinutes * 60;
      _isRunning = false;
    });
    
    _showBreakNotification('Long Break', longBreakMinutes);
  }
  
  Future<void> _startStudySession() async {
    final studyProvider = context.read<StudyProvider>();
    _sessionStartTime = DateTime.now();
    
    final success = await studyProvider.startStudySession(
      subject: widget.subject,
      topic: widget.topic,
      goalId: widget.goalId,
      plannedDuration: workMinutes,
      type: SessionType.focused,
    );
    
    if (success && studyProvider.activeSession != null) {
      _currentSessionId = studyProvider.activeSession!.id;
      Logger.info('포모도로 세션 시작: $_currentSessionId');
    }
  }
  
  Future<void> _endCurrentSession() async {
    if (_currentSessionId != null && _sessionStartTime != null) {
      final studyProvider = context.read<StudyProvider>();
      final duration = DateTime.now().difference(_sessionStartTime!).inMinutes;
      
      await studyProvider.endStudySession(
        notes: 'Pomodoro session - ${widget.subject}',
        focusScore: _calculateFocusScore(),
      );
      
      _currentSessionId = null;
      _sessionStartTime = null;
    }
  }
  
  int _calculateFocusScore() {
    // Calculate focus score based on completion
    final completionRate = (_totalSeconds - _currentSeconds) / _totalSeconds;
    return (completionRate * 100).round();
  }
  
  void _showBreakNotification(String title, int minutes) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title 시작! $minutes분 휴식하세요'),
        backgroundColor: AppTheme.successColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  
  double get _progress => 1 - (_currentSeconds / _totalSeconds);
  
  @override
  Widget build(BuildContext context) {
    final sessionType = _isBreak ? 'Break' : 'Focus';
    final sessionColor = _isBreak ? AppTheme.successColor : AppTheme.primaryColor;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('포모도로 타이머'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final newSettings = await Navigator.push<PomodoroSettings>(
                context,
                MaterialPageRoute(
                  builder: (context) => const PomodoroSettingsScreen(),
                ),
              );
              
              if (newSettings != null && mounted) {
                setState(() {
                  _settings = newSettings;
                  workMinutes = _settings.workMinutes;
                  shortBreakMinutes = _settings.shortBreakMinutes;
                  longBreakMinutes = _settings.longBreakMinutes;
                  sessionsUntilLongBreak = _settings.sessionsUntilLongBreak;
                  
                  // Reset timer with new settings if not running
                  if (!_isRunning) {
                    if (!_isBreak) {
                      _totalSeconds = workMinutes * 60;
                      _currentSeconds = workMinutes * 60;
                    }
                  }
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('포모도로 기법'),
                  content: const Text(
                    '• 25분 집중 학습\n'
                    '• 5분 짧은 휴식\n'
                    '• 4회 반복 후 15분 긴 휴식\n\n'
                    '집중력을 높이고 피로를 줄이는 효과적인 학습법입니다.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('확인'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Session Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: sessionColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.subject,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.topic != null)
                          Text(
                            widget.topic!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: sessionColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        sessionType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: -0.2, end: 0),
              
              const SizedBox(height: 40),
              
              // Timer Circle
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress Ring
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: CircularProgressIndicator(
                          value: _progress,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(sessionColor),
                        ),
                      ),
                      
                      // Timer Display
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(_currentSeconds),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate(
                            onPlay: (controller) => controller.repeat(),
                          ).shimmer(
                            duration: 2000.ms,
                            color: _isRunning ? sessionColor : Colors.transparent,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isBreak ? '휴식 시간' : '집중 시간',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Session Counter
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.successColor),
                    const SizedBox(width: 8),
                    Text(
                      '완료한 세션: $_completedSessions',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reset Button
                  FloatingActionButton(
                    heroTag: 'reset',
                    onPressed: _resetTimer,
                    backgroundColor: Colors.grey,
                    child: const Icon(Icons.refresh),
                  ),
                  
                  // Play/Pause Button
                  FloatingActionButton.large(
                    heroTag: 'play',
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    backgroundColor: sessionColor,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        _isRunning ? Icons.pause : Icons.play_arrow,
                        key: ValueKey(_isRunning),
                        size: 32,
                      ),
                    ),
                  ).animate()
                    .scale(delay: 300.ms),
                  
                  // Skip Button
                  FloatingActionButton(
                    heroTag: 'skip',
                    onPressed: _skipSession,
                    backgroundColor: AppTheme.warningColor,
                    child: const Icon(Icons.skip_next),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}