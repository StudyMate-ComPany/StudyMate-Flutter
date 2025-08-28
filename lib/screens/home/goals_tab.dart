import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/study_provider.dart';
import '../../models/study_goal.dart';
import '../../theme/app_theme.dart';
import '../study/study_goals_screen.dart';

class GoalsTab extends StatelessWidget {
  const GoalsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudyProvider>(
      builder: (context, studyProvider, child) {
        final activeGoals = studyProvider.activeGoals;
        final completedGoals = studyProvider.completedGoals;

        return RefreshIndicator(
          onRefresh: () => studyProvider.loadGoals(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '학습 목표 📚',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ).animate()
                            .fadeIn(duration: 600.ms)
                            .slideX(begin: -0.2, end: 0),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const StudyGoalsScreen()),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('새 목표'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Goals Summary
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              context,
                              '진행 중',
                              activeGoals.length.toString(),
                              AppTheme.primaryColor,
                              Icons.flag,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              context,
                              '완료됨',
                              completedGoals.length.toString(),
                              AppTheme.successColor,
                              Icons.check_circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Active Goals Section
              if (activeGoals.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '진행 중인 목표 🎯',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final goal = activeGoals[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: _buildGoalCard(context, goal, studyProvider),
                      );
                    },
                    childCount: activeGoals.length,
                  ),
                ),
              ],
              
              // Completed Goals Section
              if (completedGoals.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                    child: Text(
                      '완료된 목표 ✅',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final goal = completedGoals[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: _buildGoalCard(context, goal, studyProvider),
                      );
                    },
                    childCount: completedGoals.length,
                  ),
                ),
              ],
              
              // Empty State
              if (activeGoals.isEmpty && completedGoals.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '아직 학습 목표가 없어요',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate()
                          .fadeIn(duration: 600.ms)
                          .scale(delay: 200.ms),
                        const SizedBox(height: 8),
                        Text(
                          '첫 번째 목표를 만들고 학습 진도를 관리해보세요!',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ).animate()
                          .fadeIn(delay: 300.ms),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const StudyGoalsScreen()),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('첫 목표 만들기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, StudyGoal goal, StudyProvider studyProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (goal.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          goal.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getGoalTypeColor(goal.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getGoalTypeText(goal.type),
                    style: TextStyle(
                      color: _getGoalTypeColor(goal.type),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Progress Bar
            LinearProgressIndicator(
              value: goal.progressPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getGoalTypeColor(goal.type)),
            ),
            
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${goal.completedHours}/${goal.targetHours} 시간',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${goal.progressPercentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getGoalTypeColor(goal.type),
                  ),
                ),
              ],
            ),
            
            // Subjects removed from model
            if (false) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: [].take(3).map<Widget>((subject) => Chip(
                  label: Text(
                    subject,
                    style: const TextStyle(fontSize: 10),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                )).toList(),
              ),
            ],
            
            // Action Buttons
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Edit goal
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('목표 수정 기능이 곧 추가됩니다! ✏️'),
                          backgroundColor: AppTheme.primaryColor,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('수정'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: goal.status == GoalStatus.completed ? null : () {
                      // TODO: Start session for this goal
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('학습 세션 시작 기능이 곧 추가됩니다! 🚀'),
                          backgroundColor: AppTheme.secondaryColor,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('학습'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getGoalTypeColor(GoalType type) {
    switch (type) {
      case GoalType.daily:
        return AppTheme.successColor;
      case GoalType.weekly:
        return AppTheme.primaryColor;
      case GoalType.monthly:
        return AppTheme.accentColor;
      case GoalType.custom:
        return AppTheme.secondaryColor;
    }
  }

  String _getGoalTypeText(GoalType type) {
    switch (type) {
      case GoalType.daily:
        return '일일';
      case GoalType.weekly:
        return '주간';
      case GoalType.monthly:
        return '월간';
      case GoalType.custom:
        return '사용자';
    }
  }
}