import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/study_provider.dart';
import '../../models/study_session.dart';
import '../../theme/app_theme.dart';
import '../study/study_session_screen.dart';

class SessionsTab extends StatelessWidget {
  const SessionsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StudyProvider>(
      builder: (context, studyProvider, child) {
        final sessions = studyProvider.sessions;
        final activeSession = studyProvider.activeSession;

        return RefreshIndicator(
          onRefresh: () => studyProvider.loadSessions(),
          color: AppTheme.primaryColor,
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
                            '학습 세션 ⏰',
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
                                MaterialPageRoute(builder: (context) => const StudySessionScreen()),
                              );
                            },
                            icon: const Icon(Icons.timer),
                            label: const Text('세션 시작'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ).animate()
                            .fadeIn(delay: 200.ms)
                            .scale(),
                        ],
                      ),
                      
                      if (activeSession != null) ...[
                        const SizedBox(height: 16),
                        _buildActiveSessionCard(context, activeSession, studyProvider),
                      ],
                      
                      const SizedBox(height: 16),
                      
                      // Session Stats
                      _buildSessionStats(context, sessions),
                    ],
                  ),
                ),
              ),
              
              // Sessions List
              if (sessions.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final session = sessions[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: _buildSessionCard(context, session).animate()
                          .fadeIn(delay: (100 * index).ms)
                          .slideX(begin: 0.2, end: 0),
                      );
                    },
                    childCount: sessions.length,
                  ),
                )
              else
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: Icon(
                            Icons.timer_outlined,
                            size: 64,
                            color: AppTheme.secondaryColor,
                          ),
                        ).animate()
                          .fadeIn(duration: 600.ms)
                          .scale(),
                        const SizedBox(height: 16),
                        Text(
                          '아직 학습 세션이 없어요',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate()
                          .fadeIn(delay: 200.ms),
                        const SizedBox(height: 8),
                        Text(
                          '첫 학습을 시작하고 진도를 기록해보세요! 💪',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ).animate()
                          .fadeIn(delay: 400.ms),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const StudySessionScreen()),
                            );
                          },
                          icon: const Icon(Icons.timer),
                          label: const Text('첫 세션 시작하기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.secondaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ).animate()
                          .fadeIn(delay: 600.ms)
                          .scale(),
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

  Widget _buildActiveSessionCard(BuildContext context, StudySession session, StudyProvider studyProvider) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: AppTheme.successColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.successColor, AppTheme.successColor.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.play_circle_filled,
                    color: Colors.white,
                    size: 24,
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                  .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '진행 중인 세션 🔥',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successColor,
                        ),
                      ),
                      Text(
                        session.subject,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (session.topic != null)
                        Text(
                          session.topic!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  _formatDuration(session.elapsed),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: session.isPaused 
                        ? () => studyProvider.resumeStudySession()
                        : () => studyProvider.pauseStudySession(),
                    icon: Icon(session.isPaused ? Icons.play_arrow : Icons.pause),
                    label: Text(session.isPaused ? '계속하기' : '일시정지'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => studyProvider.endStudySession(),
                    icon: const Icon(Icons.stop),
                    label: const Text('세션 종료'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
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
    ).animate()
      .fadeIn(duration: 600.ms)
      .slideY(begin: -0.2, end: 0);
  }

  Widget _buildSessionStats(BuildContext context, List<StudySession> sessions) {
    final completedSessions = sessions.where((s) => s.isCompleted).length;
    final totalMinutes = sessions
        .where((s) => s.actualDuration != null)
        .fold<int>(0, (sum, s) => sum + s.actualDuration!);
    final averageMinutes = completedSessions > 0 ? totalMinutes / completedSessions : 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            '완료됨',
            completedSessions.toString(),
            Icons.check_circle,
            AppTheme.successColor,
          ).animate()
            .fadeIn(delay: 100.ms)
            .scale(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            '총 시간',
            _formatMinutes(totalMinutes),
            Icons.schedule,
            AppTheme.primaryColor,
          ).animate()
            .fadeIn(delay: 200.ms)
            .scale(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            '평균',
            _formatMinutes(averageMinutes.round()),
            Icons.analytics,
            AppTheme.accentColor,
          ).animate()
            .fadeIn(delay: 300.ms)
            .scale(),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, StudySession session) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getSessionStatusColor(session.status),
                _getSessionStatusColor(session.status).withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getSessionStatusIcon(session.status),
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          session.subject,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (session.topic != null) 
              Text(
                session.topic!,
                style: TextStyle(color: Colors.grey[700]),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(session.startTime),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.timer, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  session.actualDuration != null
                      ? _formatMinutes(session.actualDuration!)
                      : '진행 중',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getSessionStatusColor(session.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getSessionStatusText(session.status),
            style: TextStyle(
              color: _getSessionStatusColor(session.status),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          _showSessionDetails(context, session);
        },
      ),
    );
  }

  void _showSessionDetails(BuildContext context, StudySession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getSessionStatusColor(session.status),
                          _getSessionStatusColor(session.status).withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getSessionStatusIcon(session.status),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '세션 상세 정보',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          session.subject,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow(context, '📚 과목', session.subject),
              if (session.topic != null)
                _buildDetailRow(context, '📝 주제', session.topic!),
              _buildDetailRow(context, '🎯 유형', _getSessionTypeText(session.type)),
              _buildDetailRow(context, '📊 상태', _getSessionStatusText(session.status)),
              _buildDetailRow(context, '🕐 시작 시간', _formatFullDateTime(session.startTime)),
              if (session.endTime != null)
                _buildDetailRow(context, '🕑 종료 시간', _formatFullDateTime(session.endTime!)),
              _buildDetailRow(context, '⏱️ 계획 시간', '${session.plannedDuration}분'),
              if (session.actualDuration != null)
                _buildDetailRow(context, '✅ 실제 시간', '${session.actualDuration}분'),
              if (session.focusScore != null)
                _buildDetailRow(context, '🎯 집중도', '${session.focusScore}점'),
              if (session.notes != null && session.notes!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.note, color: AppTheme.primaryColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '메모',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        session.notes!,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSessionStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.active:
        return AppTheme.successColor;
      case SessionStatus.paused:
        return Colors.orange;
      case SessionStatus.completed:
        return AppTheme.primaryColor;
      case SessionStatus.cancelled:
        return AppTheme.errorColor;
    }
  }

  IconData _getSessionStatusIcon(SessionStatus status) {
    switch (status) {
      case SessionStatus.active:
        return Icons.play_circle;
      case SessionStatus.paused:
        return Icons.pause_circle;
      case SessionStatus.completed:
        return Icons.check_circle;
      case SessionStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getSessionStatusText(SessionStatus status) {
    switch (status) {
      case SessionStatus.active:
        return '진행중';
      case SessionStatus.paused:
        return '일시정지';
      case SessionStatus.completed:
        return '완료';
      case SessionStatus.cancelled:
        return '취소됨';
    }
  }

  String _getSessionTypeText(SessionType type) {
    switch (type) {
      case SessionType.focused:
        return '집중학습';
      case SessionType.break_:
        return '휴식';
      case SessionType.review:
        return '복습';
      case SessionType.practice:
        return '연습';
      case SessionType.reading:
        return '읽기';
      case SessionType.group:
        return '그룹학습';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours}시간 ${minutes}분 ${seconds}초';
    }
    return '${minutes}분 ${seconds}초';
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (hours > 0) {
      return '${hours}시간 ${remainingMinutes}분';
    }
    return '${minutes}분';
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }

  String _formatFullDateTime(DateTime dateTime) {
    final months = ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'];
    final month = months[dateTime.month - 1];
    final period = dateTime.hour < 12 ? '오전' : '오후';
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    
    return '${dateTime.year}년 $month ${dateTime.day}일 '
           '$period ${hour}시 ${dateTime.minute.toString().padLeft(2, '0')}분';
  }
}