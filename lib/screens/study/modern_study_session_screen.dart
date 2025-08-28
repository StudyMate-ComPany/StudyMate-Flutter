import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../../providers/study_provider.dart';
import '../../models/study_session.dart';
import '../../models/study_goal.dart';
import '../../theme/modern_theme.dart';

class ModernStudySessionScreen extends StatefulWidget {
  const ModernStudySessionScreen({super.key});

  @override
  State<ModernStudySessionScreen> createState() => _ModernStudySessionScreenState();
}

class _ModernStudySessionScreenState extends State<ModernStudySessionScreen> 
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _topicController = TextEditingController();
  
  String? _selectedGoalId;
  SessionType _selectedType = SessionType.focused;
  int _plannedDuration = 25;
  
  Timer? _timer;
  int _elapsedSeconds = 0;
  bool _isSessionActive = false;
  bool _isSessionPaused = false;
  
  late AnimationController _animationController;
  late AnimationController _timerAnimationController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _timerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _timerAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _timerAnimationController.repeat(reverse: true);
    _checkActiveSession();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    _subjectController.dispose();
    _topicController.dispose();
    _animationController.dispose();
    _timerAnimationController.dispose();
    super.dispose();
  }
  
  void _checkActiveSession() {
    final provider = Provider.of<StudyProvider>(context, listen: false);
    if (provider.activeSession != null) {
      setState(() {
        _isSessionActive = provider.activeSession!.isActive;
        _isSessionPaused = provider.activeSession!.isPaused;
        if (_isSessionActive && !_isSessionPaused) {
          _startTimer();
        }
      });
    }
  }
  
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });
  }
  
  void _pauseTimer() {
    _timer?.cancel();
  }
  
  Future<void> _startSession() async {
    if (!_formKey.currentState!.validate()) return;
    
    HapticFeedback.mediumImpact();
    
    final provider = Provider.of<StudyProvider>(context, listen: false);
    final success = await provider.startStudySession(
      subject: _subjectController.text,
      topic: _topicController.text.isEmpty ? null : _topicController.text,
      goalId: _selectedGoalId,
      plannedDuration: _plannedDuration,
      type: _selectedType,
    );
    
    if (success) {
      setState(() {
        _isSessionActive = true;
        _isSessionPaused = false;
        _elapsedSeconds = 0;
      });
      _startTimer();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('학습 세션이 시작되었습니다! 화이팅! 💪'),
            backgroundColor: ModernTheme.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? '세션 시작에 실패했습니다'),
            backgroundColor: ModernTheme.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }
    }
  }
  
  Future<void> _pauseSession() async {
    HapticFeedback.lightImpact();
    final provider = Provider.of<StudyProvider>(context, listen: false);
    final success = await provider.pauseStudySession();
    
    if (success) {
      setState(() {
        _isSessionPaused = true;
      });
      _pauseTimer();
    }
  }
  
  Future<void> _resumeSession() async {
    HapticFeedback.lightImpact();
    final provider = Provider.of<StudyProvider>(context, listen: false);
    final success = await provider.resumeStudySession();
    
    if (success) {
      setState(() {
        _isSessionPaused = false;
      });
      _startTimer();
    }
  }
  
  Future<void> _endSession() async {
    HapticFeedback.mediumImpact();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ModernSessionEndSheet(
        elapsedMinutes: _elapsedSeconds ~/ 60,
      ),
    );
    
    if (result != null) {
      final provider = Provider.of<StudyProvider>(context, listen: false);
      final success = await provider.endStudySession(
        notes: result['notes'],
        focusScore: result['focusScore'],
      );
      
      if (success) {
        setState(() {
          _isSessionActive = false;
          _isSessionPaused = false;
          _elapsedSeconds = 0;
        });
        _timer?.cancel();
        
        _subjectController.clear();
        _topicController.clear();
        _selectedGoalId = null;
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('수고하셨어요! 세션이 완료되었습니다! 🎉'),
              backgroundColor: ModernTheme.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }
      }
    }
  }
  
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ModernTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: ModernTheme.primaryColor,
            ),
          ),
          onPressed: () {
            if (_isSessionActive) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: const Text('세션 종료'),
                  content: const Text('진행 중인 세션이 있습니다. 정말 나가시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ModernTheme.errorColor,
                      ),
                      child: const Text('나가기'),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          '학습 세션',
          style: TextStyle(
            color: ModernTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<StudyProvider>(
        builder: (context, provider, child) {
          final activeSession = provider.activeSession;
          
          if (_isSessionActive && activeSession != null) {
            return _buildActiveSessionView(activeSession);
          }
          
          return _buildStartSessionView(provider);
        },
      ),
    );
  }
  
  Widget _buildActiveSessionView(StudySession session) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            ModernTheme.primaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Timer Circle
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _isSessionPaused 
                        ? [ModernTheme.warningColor, ModernTheme.accentColor]
                        : [ModernTheme.primaryColor, ModernTheme.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_isSessionPaused ? ModernTheme.warningColor : ModernTheme.primaryColor)
                            .withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isSessionPaused ? Icons.pause : Icons.timer,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _formatDuration(_elapsedSeconds),
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _isSessionPaused ? '일시정지' : '학습 중',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .scale(delay: 200.ms),
              
              const SizedBox(height: 40),
              
              // Session Info Cards
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: ModernTheme.cardShadow,
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.book,
                      '과목',
                      session.subject,
                      ModernTheme.primaryColor,
                    ),
                    if (session.topic != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.topic,
                        '주제',
                        session.topic!,
                        ModernTheme.accentColor,
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      Icons.category,
                      '유형',
                      _getSessionTypeLabel(session.type),
                      ModernTheme.secondaryColor,
                    ),
                  ],
                ),
              ).animate()
                .fadeIn(delay: 400.ms)
                .slideY(begin: 0.1, end: 0),
              
              const Spacer(),
              
              // Control Buttons
              Row(
                children: [
                  if (_isSessionPaused) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _resumeSession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ModernTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow, color: Colors.white),
                        label: const Text(
                          '재개하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pauseSession,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: ModernTheme.warningColor, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.pause, color: ModernTheme.warningColor),
                        label: const Text(
                          '일시정지',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ModernTheme.warningColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _endSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ModernTheme.errorColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.stop, color: Colors.white),
                      label: const Text(
                        '종료하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate()
                .fadeIn(delay: 600.ms)
                .slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStartSessionView(StudyProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: ModernTheme.primaryGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: ModernTheme.elevatedShadow,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.school,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '새로운 학습 세션',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '집중해서 공부할 시간이에요!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ).animate()
              .fadeIn(duration: 600.ms)
              .scale(delay: 200.ms),
            
            const SizedBox(height: 32),
            
            // Subject Input
            _buildInputField(
              controller: _subjectController,
              label: '과목',
              hint: '예: 수학, 영어, 프로그래밍',
              icon: Icons.book,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '과목을 입력해주세요';
                }
                return null;
              },
            ).animate()
              .fadeIn(delay: 400.ms)
              .slideX(begin: -0.1, end: 0),
            
            const SizedBox(height: 20),
            
            // Topic Input (Optional)
            _buildInputField(
              controller: _topicController,
              label: '주제 (선택)',
              hint: '예: 미적분, 문법, 알고리즘',
              icon: Icons.topic,
            ).animate()
              .fadeIn(delay: 500.ms)
              .slideX(begin: -0.1, end: 0),
            
            const SizedBox(height: 20),
            
            // Goal Selection
            if (provider.goals.isNotEmpty) ...[
              _buildGoalSelector(provider).animate()
                .fadeIn(delay: 600.ms)
                .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 20),
            ],
            
            // Session Type
            _buildSessionTypeSelector().animate()
              .fadeIn(delay: 700.ms)
              .slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 20),
            
            // Duration Selector
            _buildDurationSelector().animate()
              .fadeIn(delay: 800.ms)
              .slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 32),
            
            // Start Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: provider.state == StudyState.loading ? null : _startSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: provider.state == StudyState.loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      '학습 시작',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
              ),
            ).animate()
              .fadeIn(delay: 900.ms)
              .scale(delay: 1000.ms),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: ModernTheme.primaryColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ModernTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ModernTheme.errorColor, width: 1),
        ),
      ),
      validator: validator,
    );
  }
  
  Widget _buildGoalSelector(StudyProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flag,
                color: ModernTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '학습 목표 연결 (선택)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ModernTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedGoalId,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: ModernTheme.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            hint: const Text('목표 선택'),
            items: provider.goals.map((goal) {
              return DropdownMenuItem(
                value: goal.id.toString(),
                child: Text(goal.title),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGoalId = value;
              });
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSessionTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.category,
                color: ModernTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '세션 유형',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ModernTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: SessionType.values.map((type) {
              final isSelected = _selectedType == type;
              return ChoiceChip(
                label: Text(_getSessionTypeLabel(type)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedType = type;
                    });
                    HapticFeedback.selectionClick();
                  }
                },
                selectedColor: ModernTheme.primaryColor,
                backgroundColor: ModernTheme.backgroundColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : ModernTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDurationSelector() {
    final durations = [25, 45, 60, 90, 120];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.timer,
                color: ModernTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '계획 시간',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ModernTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: durations.map((duration) {
              final isSelected = _plannedDuration == duration;
              return ChoiceChip(
                label: Text('${duration}분'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _plannedDuration = duration;
                    });
                    HapticFeedback.selectionClick();
                  }
                },
                selectedColor: ModernTheme.primaryColor,
                backgroundColor: ModernTheme.backgroundColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : ModernTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: ModernTheme.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ModernTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  String _getSessionTypeLabel(SessionType type) {
    switch (type) {
      case SessionType.focused:
        return '집중 학습';
      case SessionType.break_:
        return '휴식';
      case SessionType.review:
        return '복습';
      case SessionType.practice:
        return '연습';
      case SessionType.reading:
        return '읽기';
      case SessionType.group:
        return '그룹 학습';
    }
  }
}

class ModernSessionEndSheet extends StatefulWidget {
  final int elapsedMinutes;
  
  const ModernSessionEndSheet({
    super.key,
    required this.elapsedMinutes,
  });
  
  @override
  State<ModernSessionEndSheet> createState() => _ModernSessionEndSheetState();
}

class _ModernSessionEndSheetState extends State<ModernSessionEndSheet> {
  final _notesController = TextEditingController();
  int _focusScore = 3;
  
  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: ModernTheme.primaryGradient,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Icon(
                  Icons.celebration,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 12),
                const Text(
                  '학습 세션 완료!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.elapsedMinutes}분 동안 공부하셨네요!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Focus Score
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ModernTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.psychology,
                              color: ModernTheme.primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '집중도 평가',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: ModernTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(5, (index) {
                            final score = index + 1;
                            final isSelected = score <= _focusScore;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _focusScore = score;
                                });
                                HapticFeedback.lightImpact();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isSelected 
                                    ? ModernTheme.primaryColor 
                                    : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected 
                                      ? ModernTheme.primaryColor 
                                      : Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    score.toString(),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected 
                                        ? Colors.white 
                                        : ModernTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            _getFocusLabel(_focusScore),
                            style: TextStyle(
                              fontSize: 14,
                              color: ModernTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Notes
                  TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: '학습 노트 (선택)',
                      hintText: '오늘 배운 내용이나 메모할 사항을 적어주세요',
                      prefixIcon: const Icon(Icons.note, color: ModernTheme.primaryColor),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: ModernTheme.primaryColor, width: 2),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: ModernTheme.primaryColor, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            '취소',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ModernTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, {
                              'notes': _notesController.text,
                              'focusScore': _focusScore,
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: ModernTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            '완료',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate()
      .slideY(begin: 1, end: 0, duration: 300.ms)
      .fadeIn();
  }
  
  String _getFocusLabel(int score) {
    switch (score) {
      case 1:
        return '많이 산만했어요';
      case 2:
        return '조금 산만했어요';
      case 3:
        return '보통이었어요';
      case 4:
        return '집중 잘 했어요';
      case 5:
        return '완벽하게 집중했어요!';
      default:
        return '';
    }
  }
}