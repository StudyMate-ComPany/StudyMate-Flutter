import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/learning_plan_provider.dart';
import '../../theme/modern_theme.dart';
import '../../models/learning_plan.dart';
import '../learning/ai_learning_setup_screen.dart';
import '../learning/daily_content_screen.dart';
import '../learning/quiz_screen.dart' as learning;
import '../study/quiz_screen.dart' as study;
import '../study/pomodoro_timer_screen.dart';

class LearningDashboard extends StatefulWidget {
  const LearningDashboard({super.key});

  @override
  State<LearningDashboard> createState() => _LearningDashboardState();
}

class _LearningDashboardState extends State<LearningDashboard> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    print('\n🎆 LearningDashboard initState() 호출됨!');
    print('━' * 50);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadData();
  }
  
  @override
  void dispose() {
    print('\n🎆 LearningDashboard dispose() 호출됨!');
    print('━' * 50);
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    final provider = Provider.of<LearningPlanProvider>(context, listen: false);
    await provider.loadPlans();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernTheme.backgroundColor,
      body: Consumer<LearningPlanProvider>(
        builder: (context, provider, child) {
          if (provider.state == LearningPlanState.loading) {
            return _buildLoadingState();
          }
          
          if (provider.activePlan == null) {
            return _buildEmptyState();
          }
          
          return _buildActivePlanView(provider.activePlan!);
        },
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ModernTheme.primaryColor,
                      ModernTheme.secondaryColor,
                    ],
                    transform: GradientRotation(_animationController.value * 3.14),
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 50,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            '학습 플랜을 불러오는 중...',
            style: TextStyle(
              fontSize: 16,
              color: ModernTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                gradient: ModernTheme.primaryGradient,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 80,
                color: Colors.white,
              ),
            ).animate()
              .scale(duration: 600.ms)
              .fadeIn(),
            
            const SizedBox(height: 32),
            
            const Text(
              '스마트 학습 플래너와\n시작해보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: ModernTheme.textPrimary,
              ),
            ).animate()
              .fadeIn(delay: 200.ms),
            
            const SizedBox(height: 16),
            
            const Text(
              '당신의 목표를 알려주시면\n맞춤형 학습 플랜을 만들어드려요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: ModernTheme.textSecondary,
                height: 1.5,
              ),
            ).animate()
              .fadeIn(delay: 300.ms),
            
            const SizedBox(height: 48),
            
            ElevatedButton.icon(
              onPressed: () {
                print('\n🚀 [학습 플랜 만들기] 버튼 클릭됨!');
                print('  - AILearningSetupScreen으로 이동합니다');
                print('━' * 50);
                HapticFeedback.mediumImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AILearningSetupScreen(),
                  ),
                ).then((value) {
                  print('\n🎆 AILearningSetupScreen에서 돌아옴');
                  print('  - 반환값: $value');
                  print('━' * 50);
                });
              },
              icon: const Icon(Icons.rocket_launch, color: Colors.white),
              label: const Text(
                '학습 플랜 만들기',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.quiz,
                    label: 'AI 퀴즈',
                    color: ModernTheme.secondaryColor,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const study.QuizScreen(
                            subject: '일반',
                            topic: '기초',
                            difficulty: 'medium',
                            questionCount: 5,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    icon: Icons.timer,
                    label: '포모도로',
                    color: ModernTheme.accentColor,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PomodoroTimerScreen(
                            subject: '집중 학습',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ).animate()
              .fadeIn(delay: 600.ms)
              .slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActivePlanView(LearningPlan plan) {
    final todayTask = plan.todayTask;
    
    return RefreshIndicator(
      onRefresh: _loadData,
      color: ModernTheme.primaryColor,
      child: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: ModernTheme.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            plan.subject,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          plan.goal,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'D-${plan.daysRemaining}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 20),
                            const Icon(
                              Icons.trending_up,
                              color: Colors.white70,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${plan.progressPercentage.toStringAsFixed(0)}% 완료',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Progress Card
                _buildProgressCard(plan),
                const SizedBox(height: 20),
                
                // Today's Tasks
                if (todayTask != null) ...[
                  _buildSectionTitle('오늘의 학습 📚'),
                  const SizedBox(height: 12),
                  _buildTodayTasksCard(todayTask),
                  const SizedBox(height: 20),
                ],
                
                // Quick Actions
                _buildSectionTitle('빠른 실행'),
                const SizedBox(height: 12),
                _buildQuickActions(),
                const SizedBox(height: 20),
                
                // Weekly Overview
                _buildSectionTitle('주간 진행 상황'),
                const SizedBox(height: 12),
                _buildWeeklyOverview(plan),
              ]),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressCard(LearningPlan plan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: ModernTheme.cardShadow,
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
                    '전체 진행률',
                    style: TextStyle(
                      fontSize: 14,
                      color: ModernTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${plan.progressPercentage.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: ModernTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              Container(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: plan.progressPercentage / 100,
                  strokeWidth: 8,
                  backgroundColor: ModernTheme.primaryColor.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(ModernTheme.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: plan.progressPercentage / 100,
            minHeight: 8,
            backgroundColor: ModernTheme.primaryColor.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(ModernTheme.primaryColor),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '시작: ${_formatDate(plan.startDate)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: ModernTheme.textSecondary,
                ),
              ),
              Text(
                '목표: ${_formatDate(plan.endDate)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: ModernTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideY(begin: 0.1, end: 0);
  }
  
  Widget _buildTodayTasksCard(DailyTask task) {
    return Column(
      children: [
        // Morning Task
        _buildTaskItem(
          time: '오전 9시',
          title: task.morningContent.title,
          description: '${task.morningContent.estimatedMinutes}분 소요',
          icon: Icons.wb_sunny,
          color: ModernTheme.secondaryColor,
          completed: task.completionStatus['morning'] ?? false,
          onTap: () => _openContent(task, 'morning'),
        ),
        const SizedBox(height: 12),
        
        // Afternoon Task
        _buildTaskItem(
          time: '낮 12시',
          title: task.afternoonContent.title,
          description: '퀴즈 ${task.afternoonContent.questions?.length ?? 0}문제',
          icon: Icons.quiz,
          color: ModernTheme.primaryColor,
          completed: task.completionStatus['afternoon'] ?? false,
          onTap: () => _openContent(task, 'afternoon'),
        ),
        const SizedBox(height: 12),
        
        // Evening Task
        _buildTaskItem(
          time: '저녁 9시',
          title: task.eveningContent.title,
          description: '${task.eveningContent.estimatedMinutes}분 소요',
          icon: Icons.nights_stay,
          color: ModernTheme.accentColor,
          completed: task.completionStatus['evening'] ?? false,
          onTap: () => _openContent(task, 'evening'),
        ),
      ],
    );
  }
  
  Widget _buildTaskItem({
    required String time,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool completed,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: completed ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: completed ? color : Colors.grey[200]!,
            width: completed ? 2 : 1,
          ),
          boxShadow: completed ? [] : ModernTheme.cardShadow,
        ),
        child: Row(
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (completed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: ModernTheme.successColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '완료',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ModernTheme.textPrimary,
                      decoration: completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: ModernTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              completed ? Icons.check_circle : Icons.arrow_forward_ios,
              color: completed ? color : ModernTheme.textLight,
              size: 20,
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(delay: Duration(milliseconds: 100))
      .slideX(begin: 0.1, end: 0);
  }
  
  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.history,
            label: '학습 기록',
            color: ModernTheme.primaryColor,
            onTap: () {
              // 학습 기록 화면으로 이동
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.analytics,
            label: '통계',
            color: ModernTheme.accentColor,
            onTap: () {
              // 통계 화면으로 이동
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            icon: Icons.settings,
            label: '설정',
            color: ModernTheme.secondaryColor,
            onTap: () {
              // 설정 화면으로 이동
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
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
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ModernTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWeeklyOverview(LearningPlan plan) {
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: ModernTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final date = weekStart.add(Duration(days: index));
              final isToday = date.day == today.day;
              DailyTask? task;
              for (final t in plan.dailyTasks) {
                if (t.date.day == date.day && t.date.month == date.month) {
                  task = t;
                  break;
                }
              }
              
              final completed = task?.completionPercentage ?? 0;
              
              return Column(
                children: [
                  Text(
                    _getWeekdayLabel(index + 1),
                    style: TextStyle(
                      fontSize: 12,
                      color: isToday ? ModernTheme.primaryColor : ModernTheme.textSecondary,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isToday 
                        ? ModernTheme.primaryColor 
                        : completed >= 100 
                          ? ModernTheme.successColor 
                          : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        date.day.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: isToday || completed >= 100 ? Colors.white : ModernTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (completed > 0 && completed < 100)
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ModernTheme.warningColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: ModernTheme.textPrimary,
      ),
    );
  }
  
  void _openContent(DailyTask task, String timeSlot) {
    HapticFeedback.lightImpact();
    
    StudyContent content;
    switch (timeSlot) {
      case 'morning':
        content = task.morningContent;
        break;
      case 'afternoon':
        content = task.afternoonContent;
        break;
      case 'evening':
        content = task.eveningContent;
        break;
      default:
        return;
    }
    
    if (content.type == 'quiz' && content.questions != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => learning.QuizScreen(
            content: content,
            task: task,
            timeSlot: timeSlot,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DailyContentScreen(
            content: content,
            task: task,
            timeSlot: timeSlot,
          ),
        ),
      );
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
  
  String _getWeekdayLabel(int weekday) {
    switch (weekday) {
      case 1: return '월';
      case 2: return '화';
      case 3: return '수';
      case 4: return '목';
      case 5: return '금';
      case 6: return '토';
      case 7: return '일';
      default: return '';
    }
  }
}