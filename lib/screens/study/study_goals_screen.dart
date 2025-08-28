import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/study_provider.dart';
import '../../models/study_goal.dart';
import '../../widgets/common/loading_overlay.dart';

class StudyGoalsScreen extends StatefulWidget {
  const StudyGoalsScreen({super.key});

  @override
  State<StudyGoalsScreen> createState() => _StudyGoalsScreenState();
}

class _StudyGoalsScreenState extends State<StudyGoalsScreen> {
  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final provider = Provider.of<StudyProvider>(context, listen: false);
    await provider.loadGoals();
  }

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddGoalDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('학습 목표'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadGoals,
          ),
        ],
      ),
      body: Consumer<StudyProvider>(
        builder: (context, provider, child) {
          if (provider.state == StudyState.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flag_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    '아직 학습 목표가 없습니다',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '첫 번째 목표를 만들어 시작해보세요',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showAddGoalDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('목표 만들기'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadGoals,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.goals.length,
              itemBuilder: (context, index) {
                final goal = provider.goals[index];
                return GoalCard(goal: goal);
              },
            ),
          );
        },
      ),
      floatingActionButton: Consumer<StudyProvider>(
        builder: (context, provider, child) {
          if (provider.goals.isEmpty) return const SizedBox.shrink();
          
          return FloatingActionButton(
            onPressed: _showAddGoalDialog,
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}

class GoalCard extends StatelessWidget {
  final StudyGoal goal;

  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = goal.progressForDisplay;
    final progressColor = _getProgressColor(progress);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showGoalDetails(context),
        borderRadius: BorderRadius.circular(12),
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          goal.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              const SizedBox(height: 16),
              
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${goal.completedHours}h / ${goal.targetHours}h',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        '${progress.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: progressColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Target date and type
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(goal.endDate),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.category, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _getTypeLabel(goal.type),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    String label;
    
    switch (goal.statusEnum) {
      case GoalStatus.active:
        color = Colors.blue;
        label = '활성';
        break;
      case GoalStatus.completed:
        color = Colors.green;
        label = '완료';
        break;
      case GoalStatus.paused:
        color = Colors.orange;
        label = '일시정지';
        break;
      case GoalStatus.cancelled:
        color = Colors.red;
        label = '취소';
        break;
      case GoalStatus.archived:
        color = Colors.grey;
        label = '보관';
        break;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 100) return Colors.green;
    if (progress >= 75) return Colors.blue;
    if (progress >= 50) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
        return '사용자 정의';
    }
  }

  void _showGoalDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => GoalDetailsSheet(goal: goal),
    );
  }
}

class GoalDetailsSheet extends StatelessWidget {
  final StudyGoal goal;

  const GoalDetailsSheet({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            goal.description,
            style: TextStyle(color: Colors.grey[600]),
          ),
          
          const SizedBox(height: 24),
          
          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _editGoal(context);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('수정'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _deleteGoal(context);
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('삭제', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editGoal(BuildContext context) {
    // TODO: Implement edit goal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('목표 수정 기능은 공 준비 중입니다')),
    );
  }

  void _deleteGoal(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('목표 삭제'),
        content: Text('"${goal.title}"을(를) 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
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
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}

class AddGoalDialog extends StatefulWidget {
  const AddGoalDialog({super.key});

  @override
  State<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetHoursController = TextEditingController(text: '10');
  final _targetSummariesController = TextEditingController(text: '5');
  final _targetQuizzesController = TextEditingController(text: '3');
  
  GoalType _selectedType = GoalType.custom;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  int _targetSummaries = 5;
  int _targetQuizzes = 3;
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
          content: Text(success ? '목표가 성공적으로 생성되었습니다' : '목표 생성에 실패했습니다'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('학습 목표 만들기'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                  hintText: '예: 수학 코스 완료',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '제목을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '설명',
                  hintText: '무엇을 달성하고 싶으신가요?',
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '설명을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<GoalType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: '목표 유형'),
                items: GoalType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                    // Adjust target date based on type
                    switch (value) {
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
                        // Keep current date
                        break;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _targetHoursController,
                decoration: const InputDecoration(
                  labelText: '목표 시간',
                  suffixText: '시간',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '목표 시간을 입력해주세요';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return '유효한 숫자를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              InkWell(
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
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '시작일',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(_formatDate(_startDate)),
                ),
              ),
              const SizedBox(height: 16),
              
              InkWell(
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
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: '종료일',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(_formatDate(_endDate)),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _targetSummariesController,
                decoration: const InputDecoration(
                  labelText: '목표 요약 수',
                  suffixText: '개',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '목표 요약 수를 입력해주세요';
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return '유효한 숫자를 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _targetQuizzesController,
                decoration: const InputDecoration(
                  labelText: '목표 퀴즈 수',
                  suffixText: '개',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '목표 퀴즈 수를 입력해주세요';
                  }
                  if (int.tryParse(value) == null || int.parse(value) < 0) {
                    return '유효한 숫자를 입력해주세요';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createGoal,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('만들기'),
        ),
      ],
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
        return '사용자 정의';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}