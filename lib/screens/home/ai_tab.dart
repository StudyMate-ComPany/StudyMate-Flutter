import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_provider.dart';
import '../../models/ai_response.dart';
import '../study/ai_assistant_screen.dart';

class AITab extends StatelessWidget {
  const AITab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AIProvider>(
      builder: (context, aiProvider, child) {
        final history = aiProvider.history;

        return RefreshIndicator(
          onRefresh: () => aiProvider.loadHistory(),
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
                            '스마트 도우미',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const AIAssistantScreen()),
                              );
                            },
                            icon: const Icon(Icons.chat),
                            label: const Text('새 대화'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Quick Actions
                      _buildQuickActions(context, aiProvider),
                      
                      const SizedBox(height: 16),
                      
                      // AI Stats
                      _buildAIStats(context, history),
                    ],
                  ),
                ),
              ),
              
              // Recent Interactions
              if (history.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '최근 대화',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final response = history[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        child: _buildAIResponseCard(context, response),
                      );
                    },
                    childCount: history.length,
                  ),
                ),
              ] else
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.psychology_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '아직 AI와의 대화가 없습니다',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '스마트 학습 도우미와 대화를 시작해보세요',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const AIAssistantScreen()),
                            );
                          },
                          icon: const Icon(Icons.chat),
                          label: const Text('대화 시작'),
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

  Widget _buildQuickActions(BuildContext context, AIProvider aiProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '빠른 작업',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3,
          children: [
            _buildQuickActionCard(
              context,
              '학습 계획',
              Icons.schedule,
              Colors.blue,
              () => _showStudyPlanDialog(context, aiProvider),
            ),
            _buildQuickActionCard(
              context,
              '퀴즈 풍기',
              Icons.quiz,
              Colors.green,
              () => _showQuizDialog(context, aiProvider),
            ),
            _buildQuickActionCard(
              context,
              '주제 설명',
              Icons.lightbulb,
              Colors.orange,
              () => _showExplainDialog(context, aiProvider),
            ),
            _buildQuickActionCard(
              context,
              '학습 팁',
              Icons.tips_and_updates,
              Colors.purple,
              () => _showTipsDialog(context, aiProvider),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIStats(BuildContext context, List<AIResponse> history) {
    final studyPlans = history.where((r) => r.type == AIResponseType.studyPlan).length;
    final quizzes = history.where((r) => r.type == AIResponseType.quiz).length;
    final explanations = history.where((r) => r.type == AIResponseType.explanation).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            '학습 계획',
            studyPlans.toString(),
            Icons.schedule,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            '퀴즈',
            quizzes.toString(),
            Icons.quiz,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            '설명',
            explanations.toString(),
            Icons.lightbulb,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
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
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIResponseCard(BuildContext context, AIResponse response) {
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getResponseTypeColor(response.type).withOpacity(0.1),
          child: Icon(
            _getResponseTypeIcon(response.type),
            color: _getResponseTypeColor(response.type),
          ),
        ),
        title: Text(
          response.query,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          _formatDateTime(response.createdAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getResponseTypeColor(response.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            response.type.name.toUpperCase(),
            style: TextStyle(
              color: _getResponseTypeColor(response.type),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Response:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(response.response),
                if (response.confidence != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'Confidence: ',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${(response.confidence! * 100).toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                if (response.tags != null && response.tags!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    children: response.tags!.map((tag) => Chip(
                      label: Text(
                        tag,
                        style: const TextStyle(fontSize: 10),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getResponseTypeColor(AIResponseType type) {
    switch (type) {
      case AIResponseType.studyPlan:
        return Colors.blue;
      case AIResponseType.quiz:
        return Colors.green;
      case AIResponseType.explanation:
        return Colors.orange;
      case AIResponseType.recommendation:
        return Colors.purple;
      case AIResponseType.feedback:
        return Colors.red;
    }
  }

  IconData _getResponseTypeIcon(AIResponseType type) {
    switch (type) {
      case AIResponseType.studyPlan:
        return Icons.schedule;
      case AIResponseType.quiz:
        return Icons.quiz;
      case AIResponseType.explanation:
        return Icons.lightbulb;
      case AIResponseType.recommendation:
        return Icons.recommend;
      case AIResponseType.feedback:
        return Icons.feedback;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inMinutes}분 전';
    }
  }

  void _showStudyPlanDialog(BuildContext context, AIProvider aiProvider) {
    final subjectController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('학습 계획 만들기'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: '과목',
                hintText: '예: 수학, 물리, 역사',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (subjectController.text.isNotEmpty) {
                Navigator.pop(context);
                await aiProvider.getStudyPlan(subject: subjectController.text);
              }
            },
            child: const Text('생성'),
          ),
        ],
      ),
    );
  }

  void _showQuizDialog(BuildContext context, AIProvider aiProvider) {
    final subjectController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('퀴즈 생성'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: '과목',
                hintText: '예: 생물학, 화학, 문학',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (subjectController.text.isNotEmpty) {
                Navigator.pop(context);
                await aiProvider.generateQuiz(subject: subjectController.text);
              }
            },
            child: const Text('생성'),
          ),
        ],
      ),
    );
  }

  void _showExplainDialog(BuildContext context, AIProvider aiProvider) {
    final conceptController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('개념 설명'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: conceptController,
              decoration: const InputDecoration(
                labelText: '개념',
                hintText: '예: 광합성, 뉴턴의 법칙, 민주주의',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (conceptController.text.isNotEmpty) {
                Navigator.pop(context);
                await aiProvider.explainConcept(concept: conceptController.text);
              }
            },
            child: const Text('설명'),
          ),
        ],
      ),
    );
  }

  void _showTipsDialog(BuildContext context, AIProvider aiProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('학습 팁'),
        content: const Text('학습 패턴에 기반한 개인화된 학습 추천을 받아보세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await aiProvider.getStudyRecommendations(
                studyHistory: {},
                goals: '학습 효율성과 기억력 향상',
              );
            },
            child: const Text('팁 받기'),
          ),
        ],
      ),
    );
  }
}