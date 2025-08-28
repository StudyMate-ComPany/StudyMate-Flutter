import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/study_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/study_goal.dart';
import '../../models/study_session.dart';
import '../../utils/constants.dart';
import '../study/pomodoro_timer_screen.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, StudyProvider>(
      builder: (context, authProvider, studyProvider, child) {
        final user = authProvider.user;
        final stats = studyProvider.getStudyStatistics();
        final activeGoals = studyProvider.activeGoals;
        final recentSessions = studyProvider.sessions.take(5).toList();

        return RefreshIndicator(
          color: AppTheme.primaryColor,
          onRefresh: () async {
            await studyProvider.loadGoals();
            await studyProvider.loadSessions();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 환영 섹션
                _buildWelcomeSection(context, user?.name ?? '학습자'),
                
                const SizedBox(height: 24),
                
                // 활성 세션 카드
                if (studyProvider.activeSession != null)
                  _buildActiveSessionCard(context, studyProvider.activeSession!),
                
                // 통계 카드
                _buildStatisticsSection(context, stats),
                
                const SizedBox(height: 24),
                
                // 빠른 실행
                _buildQuickActionsSection(context),
                
                const SizedBox(height: 24),
                
                // 활성 목표
                if (activeGoals.isNotEmpty) ...[
                  _buildSectionHeader(context, '진행 중인 목표 🎯', '모두 보기', () {
                    // TODO: 목표 탭으로 이동
                  }),
                  const SizedBox(height: 12),
                  _buildGoalsList(context, activeGoals.take(3).toList()),
                  const SizedBox(height: 24),
                ],
                
                // 최근 세션
                if (recentSessions.isNotEmpty) ...[
                  _buildSectionHeader(context, '최근 학습 기록 📚', '모두 보기', () {
                    // TODO: 세션 탭으로 이동
                  }),
                  const SizedBox(height: 12),
                  _buildSessionsList(context, recentSessions),
                ],
                
                // 빈 상태
                if (activeGoals.isEmpty && recentSessions.isEmpty)
                  _buildEmptyState(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(BuildContext context, String userName) {
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;
    
    if (hour < 6) {
      greeting = '새벽 공부 화이팅';
      emoji = '🌙';
    } else if (hour < 12) {
      greeting = '좋은 아침이에요';
      emoji = '☀️';
    } else if (hour < 17) {
      greeting = '오후도 힘내세요';
      emoji = '🌤️';
    } else if (hour < 21) {
      greeting = '저녁 시간이네요';
      emoji = '🌆';
    } else {
      greeting = '오늘도 수고했어요';
      emoji = '🌃';
    }

    final motivationalMessages = [
      '오늘도 목표를 향해 한 걸음!',
      '꾸준함이 실력을 만들어요!',
      '작은 노력이 큰 변화를 만들어요!',
      '당신의 노력은 반드시 빛날 거예요!',
      '오늘도 최선을 다하는 당신, 멋져요!',
    ];
    
    final randomMessage = motivationalMessages[DateTime.now().minute % motivationalMessages.length];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.pastelGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ).animate()
                .fadeIn(duration: 600.ms)
                .scale(delay: 200.ms),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, $userName님!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ).animate()
                      .fadeIn(delay: 300.ms)
                      .slideX(begin: -0.2, end: 0),
                    const SizedBox(height: 4),
                    Text(
                      randomMessage,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ).animate()
                      .fadeIn(delay: 500.ms),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 800.ms)
      .slideY(begin: -0.1, end: 0);
  }

  Widget _buildActiveSessionCard(BuildContext context, StudySession session) {
    final duration = DateTime.now().difference(session.startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.successColor.withOpacity(0.8),
            AppTheme.successColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.successColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.timer,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '학습 진행 중',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            session.subject,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 600.ms)
      .scale(delay: 200.ms);
  }

  Widget _buildStatisticsSection(BuildContext context, Map<String, dynamic> stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: '오늘 학습',
                value: '${stats['todayHours'] ?? 0}시간',
                icon: Icons.today,
                color: AppTheme.primaryColor,
                delay: 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: '이번 주',
                value: '${stats['weekHours'] ?? 0}시간',
                icon: Icons.calendar_view_week,
                color: AppTheme.secondaryColor,
                delay: 100,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: '완료 목표',
                value: '${stats['completedGoals'] ?? 0}개',
                icon: Icons.check_circle,
                color: AppTheme.successColor,
                delay: 200,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: '연속 학습',
                value: '${stats['streak'] ?? 0}일',
                icon: Icons.local_fire_department,
                color: AppTheme.warningColor,
                delay: 300,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: delay.ms, duration: 600.ms)
      .scale(delay: delay.ms);
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '빠른 실행 ⚡',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ).animate()
          .fadeIn(duration: 600.ms),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                title: '학습 시작',
                icon: Icons.play_arrow,
                color: AppTheme.primaryColor,
                onTap: () {
                  // 학습 시작 다이얼로그 표시
                  _showStartStudyDialog(context);
                },
                delay: 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                title: '포모도로',
                icon: Icons.timer,
                color: Colors.orange,
                onTap: () {
                  // 포모도로 타이머 시작
                  _showPomodoroTimer(context);
                },
                delay: 100,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                title: '목표 추가',
                icon: Icons.add_task,
                color: AppTheme.secondaryColor,
                onTap: () {
                  // 목표 탭으로 이동
                  DefaultTabController.of(context)!.animateTo(1);
                },
                delay: 200,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                title: 'AI 도움',
                icon: Icons.smart_toy,
                color: AppTheme.accentColor,
                onTap: () {
                  // AI 탭으로 이동
                  DefaultTabController.of(context)!.animateTo(3);
                },
                delay: 200,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required int delay,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(delay: delay.ms, duration: 600.ms)
      .scale(delay: delay.ms);
  }

  Widget _buildSectionHeader(BuildContext context, String title, String actionText, VoidCallback onAction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionText,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoalsList(BuildContext context, List<StudyGoal> goals) {
    return Column(
      children: goals.map((goal) {
        final progress = goal.progressPercentage.toInt();
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.flag,
                      color: AppTheme.primaryColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      goal.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getGoalTypeColorFromString(goal.goalType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getGoalTypeTextFromString(goal.goalType),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getGoalTypeColorFromString(goal.goalType),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (goal.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  goal.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 100 ? AppTheme.successColor : AppTheme.primaryColor,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$progress%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: progress >= 100 ? AppTheme.successColor : AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate()
          .fadeIn(delay: (goals.indexOf(goal) * 100).ms, duration: 600.ms)
          .slideX(begin: 0.2, end: 0);
      }).toList(),
    );
  }

  Widget _buildSessionsList(BuildContext context, List<StudySession> sessions) {
    return Column(
      children: sessions.map((session) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.book,
                  color: AppTheme.secondaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.subject,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatSessionDate(session.startTime),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDurationFromMinutes(session.actualDuration ?? session.plannedDuration),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: session.status == SessionStatus.completed
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      session.status == SessionStatus.completed ? '완료' : '진행중',
                      style: TextStyle(
                        fontSize: 11,
                        color: session.status == SessionStatus.completed
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate()
          .fadeIn(delay: (sessions.indexOf(session) * 100).ms, duration: 600.ms)
          .slideX(begin: -0.2, end: 0);
      }).toList(),
    );
  }

  void _showPomodoroTimer(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context, listen: false);
    String selectedSubject = '수학';
    String topic = '';
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('포모도로 타이머'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedSubject,
              decoration: const InputDecoration(
                labelText: '과목 선택',
                border: OutlineInputBorder(),
              ),
              items: AppConstants.defaultSubjects.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Text(subject),
                );
              }).toList(),
              onChanged: (value) {
                selectedSubject = value!;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: '주제 (선택사항)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                topic = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PomodoroTimerScreen(
                    subject: selectedSubject,
                    topic: topic.isNotEmpty ? topic : null,
                  ),
                ),
              );
            },
            child: const Text('시작'),
          ),
        ],
      ),
    );
  }
  
  void _showStartStudyDialog(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context, listen: false);
    String selectedSubject = '수학';
    String topic = '';
    int duration = 25;
    SessionType sessionType = SessionType.focused;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('학습 시작'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedSubject,
                decoration: const InputDecoration(
                  labelText: '과목',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.defaultSubjects.map((subject) {
                  return DropdownMenuItem(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSubject = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '주제 (선택사항)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  topic = value;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<SessionType>(
                value: sessionType,
                decoration: const InputDecoration(
                  labelText: '학습 유형',
                  border: OutlineInputBorder(),
                ),
                items: SessionType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getSessionTypeName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    sessionType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('학습 시간: '),
                  Expanded(
                    child: Slider(
                      value: duration.toDouble(),
                      min: 5,
                      max: 120,
                      divisions: 23,
                      label: '$duration분',
                      onChanged: (value) {
                        setState(() {
                          duration = value.toInt();
                        });
                      },
                    ),
                  ),
                  Text('$duration분'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              print('[DEBUG] 학습 시작 버튼 클릭됨');
              print('[DEBUG] 선택된 과목: $selectedSubject');
              print('[DEBUG] 주제: $topic');
              print('[DEBUG] 시간: $duration분');
              print('[DEBUG] 타입: ${sessionType.name}');
              
              try {
                final success = await studyProvider.startStudySession(
                  subject: selectedSubject,
                  topic: topic.isNotEmpty ? topic : null,
                  plannedDuration: duration,
                  type: sessionType,
                );
                
                print('[DEBUG] startStudySession 결과: $success');
                
                if (success && context.mounted) {
                  // 세션 탭으로 이동
                  DefaultTabController.of(context)!.animateTo(2);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('학습 세션이 시작되었습니다'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (!success) {
                  print('[DEBUG] 학습 세션 시작 실패');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(studyProvider.errorMessage ?? '학습 세션을 시작할 수 없습니다'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                print('[ERROR] 학습 세션 시작 중 오류: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('오류 발생: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('시작'),
          ),
        ],
      ),
    );
  }

  String _getSessionTypeName(SessionType type) {
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

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.school,
                size: 60,
                color: AppTheme.primaryColor,
              ),
            ).animate()
              .fadeIn(duration: 600.ms)
              .scale(delay: 200.ms),
            const SizedBox(height: 24),
            const Text(
              '아직 학습 기록이 없어요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ).animate()
              .fadeIn(delay: 400.ms),
            const SizedBox(height: 8),
            Text(
              '목표를 설정하고 학습을 시작해보세요!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ).animate()
              .fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }


  Color _getGoalTypeColorFromString(String type) {
    switch (type.toLowerCase()) {
      case 'daily':
        return AppTheme.primaryColor;
      case 'weekly':
        return AppTheme.secondaryColor;
      case 'monthly':
        return AppTheme.accentColor;
      case 'custom':
        return AppTheme.warningColor;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getGoalTypeTextFromString(String type) {
    switch (type.toLowerCase()) {
      case 'daily':
        return '일일';
      case 'weekly':
        return '주간';
      case 'monthly':
        return '월간';
      case 'custom':
        return '사용자';
      default:
        return type;
    }
  }

  String _formatSessionDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return '오늘 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${date.month}월 ${date.day}일';
    }
  }


  String _formatDurationFromMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    
    if (hours > 0) {
      return '${hours}시간 ${mins}분';
    } else {
      return '${mins}분';
    }
  }
}