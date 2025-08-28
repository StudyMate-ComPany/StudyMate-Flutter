import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/study_provider.dart';
import '../../theme/modern_theme.dart';
import '../../models/study_goal.dart';
import '../../models/study_session.dart';
import '../../utils/constants.dart';
import '../study/pomodoro_timer_screen.dart';

class ModernDashboard extends StatefulWidget {
  const ModernDashboard({super.key});

  @override
  State<ModernDashboard> createState() => _ModernDashboardState();
}

class _ModernDashboardState extends State<ModernDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernTheme.backgroundColor,
      body: SafeArea(
        child: Consumer2<AuthProvider, StudyProvider>(
          builder: (context, authProvider, studyProvider, child) {
            final user = authProvider.user;
            final stats = studyProvider.getStudyStatistics();
            final activeGoals = studyProvider.activeGoals;
            final recentSessions = studyProvider.sessions.take(3).toList();

            return RefreshIndicator(
              color: ModernTheme.primaryColor,
              backgroundColor: Colors.white,
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                await studyProvider.loadGoals();
                await studyProvider.loadSessions();
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // 모던한 앱바
                  _buildModernAppBar(context, user?.name ?? '학습자'),
                  
                  // 오늘의 학습 현황
                  SliverToBoxAdapter(
                    child: _buildTodayStudyCard(context, stats),
                  ),
                  
                  // 빠른 시작 버튼들
                  SliverToBoxAdapter(
                    child: _buildQuickStartSection(context),
                  ),
                  
                  // 진행 중인 목표
                  if (activeGoals.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildGoalsSection(context, activeGoals.take(2).toList()),
                    ),
                  
                  // 최근 학습 기록
                  if (recentSessions.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildRecentSessionsSection(context, recentSessions),
                    ),
                  
                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context, String userName) {
    final hour = DateTime.now().hour;
    String greeting;
    
    if (hour < 12) {
      greeting = '좋은 아침이에요';
    } else if (hour < 17) {
      greeting = '좋은 오후예요';
    } else {
      greeting = '좋은 저녁이에요';
    }

    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  color: ModernTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .slideX(begin: -0.2, end: 0),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '$userName님',
                    style: const TextStyle(
                      color: ModernTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate()
                    .fadeIn(delay: 200.ms, duration: 600.ms)
                    .slideX(begin: -0.2, end: 0),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ModernTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '레벨 ${_calculateLevel(0)}',
                      style: const TextStyle(
                        color: ModernTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ).animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms)
                    .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            // 알림 화면으로 이동
          },
          icon: Stack(
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: ModernTheme.textPrimary,
                size: 24,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: ModernTheme.accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ).animate()
          .fadeIn(delay: 600.ms, duration: 600.ms),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTodayStudyCard(BuildContext context, Map<String, dynamic> stats) {
    final todayHours = stats['todayHours'] ?? 0;
    final todayMinutes = ((todayHours % 1) * 60).round();
    final hours = todayHours.floor();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: ModernTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ModernTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '오늘의 학습 시간',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$hours',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        '시간 ',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$todayMinutes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        '분',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        value: (todayHours / 8).clamp(0.0, 1.0),
                        strokeWidth: 6,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    Text(
                      '${((todayHours / 8) * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildMiniStat(
                icon: Icons.flag_outlined,
                value: '${stats['completedGoals'] ?? 0}',
                label: '완료 목표',
              ),
              const SizedBox(width: 16),
              _buildMiniStat(
                icon: Icons.local_fire_department_outlined,
                value: '${stats['streak'] ?? 0}일',
                label: '연속 학습',
              ),
              const SizedBox(width: 16),
              _buildMiniStat(
                icon: Icons.trending_up_outlined,
                value: '+${stats['weekGrowth'] ?? 0}%',
                label: '주간 성장',
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 800.ms)
      .slideY(begin: 0.1, end: 0);
  }

  Widget _buildMiniStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStartSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '빠른 시작',
            style: TextStyle(
              color: ModernTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickStartButton(
                  context: context,
                  icon: Icons.play_circle_outline,
                  label: '학습 시작',
                  color: ModernTheme.primaryColor,
                  onTap: () => _showStartStudyDialog(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStartButton(
                  context: context,
                  icon: Icons.timer_outlined,
                  label: '포모도로',
                  color: ModernTheme.secondaryColor,
                  onTap: () => _showPomodoroTimer(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickStartButton(
                  context: context,
                  icon: Icons.flag_outlined,
                  label: '목표 설정',
                  color: ModernTheme.successColor,
                  onTap: () {
                    DefaultTabController.of(context)?.animateTo(1);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStartButton(
                  context: context,
                  icon: Icons.auto_awesome_outlined,
                  label: 'AI 도우미',
                  color: ModernTheme.accentColor,
                  onTap: () {
                    DefaultTabController.of(context)?.animateTo(3);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: 200.ms, duration: 600.ms);
  }

  Widget _buildQuickStartButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: ModernTheme.cardShadow,
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: ModernTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalsSection(BuildContext context, List<StudyGoal> goals) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '진행 중인 목표',
                style: TextStyle(
                  color: ModernTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  DefaultTabController.of(context)?.animateTo(1);
                },
                child: const Text(
                  '모두 보기',
                  style: TextStyle(
                    color: ModernTheme.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...goals.map((goal) => _buildGoalCard(context, goal)),
        ],
      ),
    ).animate()
      .fadeIn(delay: 400.ms, duration: 600.ms);
  }

  Widget _buildGoalCard(BuildContext context, StudyGoal goal) {
    final progress = goal.progressPercentage / 100;
    final color = _getGoalColor(goal.goalType);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            // 목표 상세 화면으로 이동
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.flag,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: const TextStyle(
                              color: ModernTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            goal.description,
                            style: const TextStyle(
                              color: ModernTheme.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey[100],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSessionsSection(BuildContext context, List<StudySession> sessions) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '최근 학습',
            style: TextStyle(
              color: ModernTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: ModernTheme.cardShadow,
            ),
            child: Column(
              children: sessions.map((session) {
                final isLast = sessions.last == session;
                return _buildSessionItem(context, session, isLast);
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate()
      .fadeIn(delay: 600.ms, duration: 600.ms);
  }

  Widget _buildSessionItem(BuildContext context, StudySession session, bool isLast) {
    final duration = session.actualDuration ?? session.plannedDuration;
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          // 세션 상세 화면으로 이동
        },
        borderRadius: BorderRadius.circular(isLast ? 16 : 0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: !isLast ? Border(
              bottom: BorderSide(
                color: Colors.grey[100]!,
                width: 1,
              ),
            ) : null,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ModernTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.book_outlined,
                  color: ModernTheme.primaryColor,
                  size: 24,
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
                        color: ModernTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatSessionDate(session.startTime),
                      style: const TextStyle(
                        color: ModernTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    hours > 0 ? '${hours}시간 ${minutes}분' : '${minutes}분',
                    style: const TextStyle(
                      color: ModernTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: session.status == SessionStatus.completed
                          ? ModernTheme.successColor.withOpacity(0.1)
                          : ModernTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      session.status == SessionStatus.completed ? '완료' : '진행중',
                      style: TextStyle(
                        color: session.status == SessionStatus.completed
                            ? ModernTheme.successColor
                            : ModernTheme.warningColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStartStudyDialog(BuildContext context) {
    final studyProvider = Provider.of<StudyProvider>(context, listen: false);
    String selectedSubject = '수학';
    String topic = '';
    int duration = 25;
    SessionType sessionType = SessionType.focused;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '학습 시작하기',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ModernTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                // 과목 선택
                const Text(
                  '과목',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ModernTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedSubject,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                const SizedBox(height: 20),
                // 학습 시간
                const Text(
                  '학습 시간',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ModernTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildTimeChip('25분', duration == 25, () {
                      setState(() => duration = 25);
                    }),
                    const SizedBox(width: 8),
                    _buildTimeChip('45분', duration == 45, () {
                      setState(() => duration = 45);
                    }),
                    const SizedBox(width: 8),
                    _buildTimeChip('60분', duration == 60, () {
                      setState(() => duration = 60);
                    }),
                    const SizedBox(width: 8),
                    _buildTimeChip('90분', duration == 90, () {
                      setState(() => duration = 90);
                    }),
                  ],
                ),
                const SizedBox(height: 32),
                // 시작 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      HapticFeedback.mediumImpact();
                      
                      final success = await studyProvider.startStudySession(
                        subject: selectedSubject,
                        topic: topic.isNotEmpty ? topic : null,
                        plannedDuration: duration,
                        type: sessionType,
                      );
                      
                      if (success && context.mounted) {
                        DefaultTabController.of(context)?.animateTo(2);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('학습이 시작되었습니다'),
                            backgroundColor: ModernTheme.successColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                    style: ModernTheme.primaryButtonStyle,
                    child: const Text('시작하기'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeChip(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? ModernTheme.primaryColor : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? ModernTheme.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : ModernTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPomodoroTimer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PomodoroTimerScreen(
          subject: '집중 학습',
        ),
      ),
    );
  }

  Color _getGoalColor(String type) {
    switch (type.toLowerCase()) {
      case 'daily':
        return ModernTheme.primaryColor;
      case 'weekly':
        return ModernTheme.secondaryColor;
      case 'monthly':
        return ModernTheme.successColor;
      default:
        return ModernTheme.accentColor;
    }
  }

  String _formatSessionDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      final hours = date.hour;
      final minutes = date.minute.toString().padLeft(2, '0');
      final period = hours >= 12 ? '오후' : '오전';
      final displayHours = hours > 12 ? hours - 12 : (hours == 0 ? 12 : hours);
      return '오늘 $period $displayHours:$minutes';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${date.month}월 ${date.day}일';
    }
  }

  int _calculateLevel(int totalHours) {
    // 50시간마다 레벨업
    return (totalHours / 50).floor() + 1;
  }
}