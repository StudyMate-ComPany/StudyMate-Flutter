import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/study_provider.dart';
import '../../models/study_session.dart';
import '../../models/study_goal.dart';
import '../../widgets/common/loading_overlay.dart';

class StudySessionScreen extends StatefulWidget {
  const StudySessionScreen({super.key});

  @override
  State<StudySessionScreen> createState() => _StudySessionScreenState();
}

class _StudySessionScreenState extends State<StudySessionScreen> with SingleTickerProviderStateMixin {
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
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
    
    _checkActiveSession();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subjectController.dispose();
    _topicController.dispose();
    _animationController.dispose();
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
          const SnackBar(
            content: Text('학습 세션이 시작되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? '세션 시작에 실패했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pauseSession() async {
    final provider = Provider.of<StudyProvider>(context, listen: false);
    final success = await provider.pauseStudySession();
    
    if (success) {
      setState(() {
        _isSessionPaused = true;
      });
      _pauseTimer();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('세션이 일시정지되었습니다'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _resumeSession() async {
    final provider = Provider.of<StudyProvider>(context, listen: false);
    final success = await provider.resumeStudySession();
    
    if (success) {
      setState(() {
        _isSessionPaused = false;
      });
      _startTimer();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('세션이 재개되었습니다'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    }
  }

  Future<void> _endSession() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SessionEndDialog(
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
        
        // Clear form
        _subjectController.clear();
        _topicController.clear();
        _selectedGoalId = null;
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('세션이 성공적으로 완료되었습니다!'),
              backgroundColor: Colors.green,
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
      appBar: AppBar(
        title: const Text('학습 세션'),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Timer display
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: _isSessionPaused 
                      ? [Colors.orange.shade300, Colors.orange.shade600]
                      : [Colors.blue.shade300, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isSessionPaused ? Colors.orange : Colors.blue).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatDuration(_elapsedSeconds),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isSessionPaused ? '일시정지' : '진행 중',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Session info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.book, '과목', session.subject),
                    if (session.topic != null)
                      _buildInfoRow(Icons.topic, '주제', session.topic!),
                    _buildInfoRow(Icons.timer, '계획 시간', '${session.plannedDuration} 분'),
                    _buildInfoRow(Icons.category, '유형', _getTypeLabel(session.type)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!_isSessionPaused)
                  FloatingActionButton.extended(
                    onPressed: _pauseSession,
                    backgroundColor: Colors.orange,
                    icon: const Icon(Icons.pause),
                    label: const Text('일시정지'),
                  )
                else
                  FloatingActionButton.extended(
                    onPressed: _resumeSession,
                    backgroundColor: Colors.blue,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('재개'),
                  ),
                FloatingActionButton.extended(
                  onPressed: _endSession,
                  backgroundColor: Colors.red,
                  icon: const Icon(Icons.stop),
                  label: const Text('종료'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartSessionView(StudyProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Recent sessions card
            if (provider.sessions.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '최근 세션',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...provider.sessions.take(3).map((session) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: _getSessionColor(session),
                            child: Icon(
                              _getSessionIcon(session),
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          title: Text(session.subject),
                          subtitle: Text(
                            '${session.actualDuration ?? session.plannedDuration} min • ${_formatDate(session.startTime)}',
                          ),
                          trailing: session.focusScore != null
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  Text('${session.focusScore}'),
                                ],
                              )
                            : null,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Session setup form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '새 세션 시작',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Subject field
                    TextFormField(
                      controller: _subjectController,
                      decoration: const InputDecoration(
                        labelText: '과목 *',
                        hintText: '예: 수학, 물리',
                        prefixIcon: Icon(Icons.book),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '과목을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Topic field
                    TextFormField(
                      controller: _topicController,
                      decoration: const InputDecoration(
                        labelText: '주제 (선택사항)',
                        hintText: '예: 미적분, 양자역학',
                        prefixIcon: Icon(Icons.topic),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Goal selection
                    if (provider.activeGoals.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        value: _selectedGoalId,
                        decoration: const InputDecoration(
                          labelText: '목표 연결 (선택사항)',
                          prefixIcon: Icon(Icons.flag),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('목표 없음'),
                          ),
                          ...provider.activeGoals.map((goal) {
                            return DropdownMenuItem<String>(
                              value: goal.id.toString(),
                              child: Text(goal.title),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGoalId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Session type
                    DropdownButtonFormField<SessionType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        labelText: '세션 유형',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: SessionType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getTypeLabel(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Duration selector
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '학습 시간 (분)',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildDurationChip(15),
                            const SizedBox(width: 8),
                            _buildDurationChip(25),
                            const SizedBox(width: 8),
                            _buildDurationChip(45),
                            const SizedBox(width: 8),
                            _buildDurationChip(60),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Start button
                    ElevatedButton.icon(
                      onPressed: _startSession,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('세션 시작'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationChip(int minutes) {
    final isSelected = _plannedDuration == minutes;
    return ChoiceChip(
      label: Text('$minutes'),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _plannedDuration = minutes;
          });
        }
      },
    );
  }

  String _getTypeLabel(SessionType type) {
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
        return '독서';
      case SessionType.group:
        return '그룹 학습';
    }
  }

  Color _getSessionColor(StudySession session) {
    switch (session.status) {
      case SessionStatus.completed:
        return Colors.green;
      case SessionStatus.active:
        return Colors.blue;
      case SessionStatus.paused:
        return Colors.orange;
      case SessionStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getSessionIcon(StudySession session) {
    switch (session.type) {
      case SessionType.focused:
        return Icons.visibility;
      case SessionType.break_:
        return Icons.coffee;
      case SessionType.review:
        return Icons.refresh;
      case SessionType.practice:
        return Icons.edit;
      case SessionType.reading:
        return Icons.auto_stories;
      case SessionType.group:
        return Icons.group;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return '오늘';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${date.month}월 ${date.day}일';
    }
  }
}

class SessionEndDialog extends StatefulWidget {
  final int elapsedMinutes;

  const SessionEndDialog({
    super.key,
    required this.elapsedMinutes,
  });

  @override
  State<SessionEndDialog> createState() => _SessionEndDialogState();
}

class _SessionEndDialogState extends State<SessionEndDialog> {
  final _notesController = TextEditingController();
  int _focusScore = 3;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('학습 세션 종료'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.elapsedMinutes}분 동안 학습하셨습니다',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            
            // Focus score rating
            const Text(
              '집중도는 어떠셨나요?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final score = index + 1;
                return IconButton(
                  icon: Icon(
                    score <= _focusScore ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      _focusScore = score;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            
            // Notes field
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: '세션 노트 (선택사항)',
                hintText: '무엇을 배웠거나 달성했나요?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'focusScore': _focusScore,
              'notes': _notesController.text.isEmpty ? null : _notesController.text,
            });
          },
          child: const Text('세션 종료'),
        ),
      ],
    );
  }
}