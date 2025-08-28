import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/study_provider.dart';
import '../../models/study_goal.dart';
import '../../theme/modern_theme.dart';

class ModernStudyGoalsScreen extends StatefulWidget {
  const ModernStudyGoalsScreen({super.key});

  @override
  State<ModernStudyGoalsScreen> createState() => _ModernStudyGoalsScreenState();
}

class _ModernStudyGoalsScreenState extends State<ModernStudyGoalsScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadGoals();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadGoals() async {
    final provider = Provider.of<StudyProvider>(context, listen: false);
    await provider.loadGoals();
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '학습 목표',
          style: TextStyle(
            color: ModernTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: ModernTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.refresh,
                size: 20,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              _loadGoals();
            },
          ),
        ],
      ),
      body: Consumer<StudyProvider>(
        builder: (context, provider, child) {
          if (provider.state == StudyState.loading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ModernTheme.primaryColor,
                              ModernTheme.secondaryColor,
                            ],
                            transform: GradientRotation(_animationController.value * 3.14),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.flag,
                          color: Colors.white,
                          size: 40,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '목표를 불러오는 중...',
                    style: TextStyle(
                      color: ModernTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }
          
          if (provider.goals.isEmpty) {
            return _buildEmptyState();
          }
          
          return RefreshIndicator(
            onRefresh: _loadGoals,
            color: ModernTheme.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: provider.goals.length,
              itemBuilder: (context, index) {
                final goal = provider.goals[index];
                return ModernGoalCard(goal: goal)
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: index * 100))
                  .slideY(begin: 0.1, end: 0);
              },
            ),
          );
        },
      ),
      floatingActionButton: _buildFAB(),
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
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: ModernTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.flag_outlined,
                size: 60,
                color: ModernTheme.primaryColor,
              ),
            ).animate()
              .scale(delay: 200.ms, duration: 600.ms)
              .fadeIn(),
            
            const SizedBox(height: 24),
            
            Text(
              '첫 번째 학습 목표를 만들어보세요',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ModernTheme.textPrimary,
              ),
            ).animate()
              .fadeIn(delay: 400.ms),
            
            const SizedBox(height: 8),
            
            Text(
              '목표를 설정하고 체계적으로 학습해보세요',
              style: TextStyle(
                fontSize: 14,
                color: ModernTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ).animate()
              .fadeIn(delay: 500.ms),
            
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: () => _showAddGoalDialog(),
              style: ModernTheme.primaryButtonStyle.copyWith(
                padding: const MaterialStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                ),
              ),
              child: const Text(
                '목표 만들기',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ).animate()
              .fadeIn(delay: 600.ms)
              .scale(delay: 700.ms),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFAB() {
    return Consumer<StudyProvider>(
      builder: (context, provider, child) {
        if (provider.goals.isEmpty) return const SizedBox.shrink();
        
        return FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.mediumImpact();
            _showAddGoalDialog();
          },
          backgroundColor: ModernTheme.primaryColor,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            '목표 추가',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ).animate()
          .fadeIn(duration: 300.ms)
          .scale(delay: 100.ms);
      },
    );
  }
  
  void _showAddGoalDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ModernAddGoalSheet(),
    );
  }
}

class ModernGoalCard extends StatelessWidget {
  final StudyGoal goal;
  
  const ModernGoalCard({super.key, required this.goal});
  
  @override
  Widget build(BuildContext context) {
    final progress = goal.progressForDisplay;
    final progressColor = _getProgressColor(progress);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: ModernTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showGoalDetails(context),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            progressColor.withOpacity(0.8),
                            progressColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.flag,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: ModernTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            goal.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: ModernTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Progress Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ModernTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.timer,
                                size: 16,
                                color: progressColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${goal.completedHours}h / ${goal.targetHours}h',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: ModernTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: progressColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${progress.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: progressColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress / 100,
                          minHeight: 10,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Info Row
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.calendar_today,
                      _formatDate(goal.endDate),
                      ModernTheme.accentColor,
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      Icons.category,
                      _getTypeLabel(goal.type),
                      ModernTheme.secondaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusChip() {
    Color color;
    String label;
    IconData icon;
    
    switch (goal.statusEnum) {
      case GoalStatus.active:
        color = ModernTheme.successColor;
        label = '진행중';
        icon = Icons.play_arrow;
        break;
      case GoalStatus.completed:
        color = Colors.blue;
        label = '완료';
        icon = Icons.check_circle;
        break;
      case GoalStatus.paused:
        color = ModernTheme.warningColor;
        label = '일시정지';
        icon = Icons.pause;
        break;
      case GoalStatus.cancelled:
        color = ModernTheme.errorColor;
        label = '취소';
        icon = Icons.cancel;
        break;
      case GoalStatus.archived:
        color = Colors.grey;
        label = '보관';
        icon = Icons.archive;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getProgressColor(double progress) {
    if (progress >= 100) return ModernTheme.successColor;
    if (progress >= 75) return ModernTheme.primaryColor;
    if (progress >= 50) return ModernTheme.accentColor;
    return ModernTheme.warningColor;
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
  
  String _getTypeLabel(GoalType type) {
    switch (type) {
      case GoalType.daily:
        return '일일 목표';
      case GoalType.weekly:
        return '주간 목표';
      case GoalType.monthly:
        return '월간 목표';
      case GoalType.custom:
        return '커스텀';
    }
  }
  
  void _showGoalDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ModernGoalDetailsSheet(goal: goal),
    );
  }
}

class ModernGoalDetailsSheet extends StatelessWidget {
  final StudyGoal goal;
  
  const ModernGoalDetailsSheet({super.key, required this.goal});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
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
          
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: ModernTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.flag,
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
                      goal.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: ModernTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goal.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: ModernTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    _editGoal(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: const BorderSide(color: ModernTheme.primaryColor, width: 2),
                  ),
                  icon: const Icon(Icons.edit, color: ModernTheme.primaryColor),
                  label: const Text(
                    '수정하기',
                    style: TextStyle(
                      color: ModernTheme.primaryColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                    _deleteGoal(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: ModernTheme.errorColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text(
                    '삭제하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    ).animate()
      .slideY(begin: 1, end: 0, duration: 300.ms)
      .fadeIn();
  }
  
  void _editGoal(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('목표 수정 기능을 준비 중입니다'),
        backgroundColor: ModernTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
  
  void _deleteGoal(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('목표 삭제'),
        content: Text('"${goal.title}"을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernTheme.errorColor,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && context.mounted) {
      final provider = Provider.of<StudyProvider>(context, listen: false);
      final success = await provider.deleteGoal(goal.id.toString());
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '목표가 삭제되었습니다' : '목표 삭제에 실패했습니다'),
            backgroundColor: success ? ModernTheme.successColor : ModernTheme.errorColor,
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

class ModernAddGoalSheet extends StatefulWidget {
  const ModernAddGoalSheet({super.key});

  @override
  State<ModernAddGoalSheet> createState() => _ModernAddGoalSheetState();
}

class _ModernAddGoalSheetState extends State<ModernAddGoalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetHoursController = TextEditingController(text: '10');
  final _targetSummariesController = TextEditingController(text: '5');
  final _targetQuizzesController = TextEditingController(text: '3');
  
  GoalType _selectedType = GoalType.custom;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetHoursController.dispose();
    _targetSummariesController.dispose();
    _targetQuizzesController.dispose();
    super.dispose();
  }
  
  Future<void> _createGoal() async {
    if (!_formKey.currentState!.validate()) return;
    
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    
    final provider = Provider.of<StudyProvider>(context, listen: false);
    final success = await provider.createGoal(
      title: _titleController.text,
      description: _descriptionController.text,
      type: _selectedType,
      startDate: _startDate,
      endDate: _endDate,
      targetHours: int.parse(_targetHoursController.text),
      targetSummaries: int.parse(_targetSummariesController.text),
      targetQuizzes: int.parse(_targetQuizzesController.text),
    );
    
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '목표가 생성되었습니다!' : '목표 생성에 실패했습니다'),
          backgroundColor: success ? ModernTheme.successColor : ModernTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                Row(
                  children: [
                    const Icon(
                      Icons.flag,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '새로운 학습 목표',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(
                      controller: _titleController,
                      label: '목표 제목',
                      hint: '예: 토익 900점 달성',
                      icon: Icons.title,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '제목을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildInputField(
                      controller: _descriptionController,
                      label: '목표 설명',
                      hint: '무엇을 달성하고 싶으신가요?',
                      icon: Icons.description,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '설명을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildTypeSelector(),
                    
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            controller: _targetHoursController,
                            label: '목표 시간',
                            hint: '10',
                            icon: Icons.timer,
                            suffix: '시간',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '목표 시간 입력';
                              }
                              if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                return '유효한 숫자';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInputField(
                            controller: _targetSummariesController,
                            label: '목표 요약',
                            hint: '5',
                            icon: Icons.summarize,
                            suffix: '개',
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '목표 요약 수';
                              }
                              if (int.tryParse(value) == null || int.parse(value) < 0) {
                                return '유효한 숫자';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateSelector(
                            label: '시작일',
                            date: _startDate,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _startDate,
                                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() => _startDate = date);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDateSelector(
                            label: '종료일',
                            date: _endDate,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _endDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (date != null) {
                                setState(() => _endDate = date);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createGoal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ModernTheme.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                '목표 만들기',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate()
      .slideY(begin: 1, end: 0, duration: 300.ms)
      .fadeIn();
  }
  
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? suffix,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        prefixIcon: Icon(icon, color: ModernTheme.primaryColor),
        filled: true,
        fillColor: ModernTheme.backgroundColor,
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
  
  Widget _buildTypeSelector() {
    return Container(
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
                Icons.category,
                color: ModernTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '목표 유형',
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
            children: GoalType.values.map((type) {
              final isSelected = _selectedType == type;
              return ChoiceChip(
                label: Text(_getTypeLabel(type)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedType = type;
                      switch (type) {
                        case GoalType.daily:
                          _endDate = DateTime.now().add(const Duration(days: 1));
                          break;
                        case GoalType.weekly:
                          _endDate = DateTime.now().add(const Duration(days: 7));
                          break;
                        case GoalType.monthly:
                          _endDate = DateTime.now().add(const Duration(days: 30));
                          break;
                        case GoalType.custom:
                          break;
                      }
                    });
                  }
                },
                selectedColor: ModernTheme.primaryColor,
                backgroundColor: Colors.white,
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
  
  Widget _buildDateSelector({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ModernTheme.backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: ModernTheme.primaryColor,
              size: 20,
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
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(date),
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
        ),
      ),
    );
  }
  
  String _getTypeLabel(GoalType type) {
    switch (type) {
      case GoalType.daily:
        return '일일';
      case GoalType.weekly:
        return '주간';
      case GoalType.monthly:
        return '월간';
      case GoalType.custom:
        return '커스텀';
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}