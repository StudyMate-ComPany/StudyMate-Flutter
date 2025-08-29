import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/learning_plan_provider.dart';
import '../../models/learning_plan.dart';
import '../../theme/studymate_theme.dart';

class DailyContentScreen extends StatefulWidget {
  final StudyContent content;
  final DailyTask task;
  final String timeSlot;
  
  const DailyContentScreen({
    super.key,
    required this.content,
    required this.task,
    required this.timeSlot,
  });

  @override
  State<DailyContentScreen> createState() => _DailyContentScreenState();
}

class _DailyContentScreenState extends State<DailyContentScreen> {
  bool _isCompleted = false;
  
  @override
  void initState() {
    super.initState();
    _isCompleted = widget.task.completionStatus[widget.timeSlot] ?? false;
  }
  
  Future<void> _markAsComplete() async {
    HapticFeedback.mediumImpact();
    
    final provider = Provider.of<LearningPlanProvider>(context, listen: false);
    await provider.completeTask(widget.task.id, widget.timeSlot);
    
    setState(() {
      _isCompleted = true;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('학습 완료! 수고하셨어요 👏'),
          backgroundColor: StudyMateTheme.primaryBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
      
      Navigator.pop(context);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudyMateTheme.lightBlue,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: StudyMateTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: StudyMateTheme.primaryBlue,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.content.title,
          style: const TextStyle(
            color: StudyMateTheme.darkNavy,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isCompleted 
                ? StudyMateTheme.primaryBlue.withOpacity(0.1)
                : StudyMateTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  _isCompleted ? Icons.check_circle : Icons.timer,
                  size: 16,
                  color: _isCompleted 
                    ? StudyMateTheme.primaryBlue
                    : StudyMateTheme.primaryBlue,
                ),
                const SizedBox(width: 6),
                Text(
                  _isCompleted ? '완료' : '${widget.content.estimatedMinutes}분',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isCompleted 
                      ? StudyMateTheme.primaryBlue
                      : StudyMateTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Topic Tags
                  if (widget.task.topics.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.task.topics.map((topic) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: StudyMateTheme.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            topic,
                            style: const TextStyle(
                              fontSize: 12,
                              color: StudyMateTheme.primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ).animate()
                      .fadeIn(duration: 400.ms),
                    const SizedBox(height: 24),
                  ],
                  
                  // Main Content
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
          BoxShadow(
            color: StudyMateTheme.primaryBlue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Content Header
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: StudyMateTheme.buttonGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.auto_stories,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '오늘의 학습 내용',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: StudyMateTheme.grayText,
                                    ),
                                  ),
                                  Text(
                                    widget.task.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: StudyMateTheme.darkNavy,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 24),
                        
                        // Content Body
                        Text(
                          widget.content.content,
                          style: const TextStyle(
                            fontSize: 15,
                            color: StudyMateTheme.darkNavy,
                            height: 1.8,
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                    .fadeIn(delay: 200.ms, duration: 600.ms)
                    .slideY(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 24),
                  
                  // Learning Tips
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: StudyMateTheme.accentPink.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: StudyMateTheme.accentPink.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: StudyMateTheme.accentPink,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '💡 Tip: ${_getRandomTip()}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: StudyMateTheme.darkNavy,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                    .fadeIn(delay: 400.ms, duration: 600.ms),
                ],
              ),
            ),
          ),
          
          // Bottom Action Button
          if (!_isCompleted)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _markAsComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: StudyMateTheme.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          '학습 완료',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate()
              .fadeIn(delay: 600.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
  
  String _getRandomTip() {
    final tips = [
      '학습한 내용을 다시 한번 정리해보세요',
      '중요한 부분은 노트에 따로 적어두세요',
      '이해가 안 되는 부분은 반복해서 읽어보세요',
      '학습 후 5분간 휴식을 취하세요',
      '오늘 배운 내용을 누군가에게 설명해보세요',
    ];
    
    return tips[DateTime.now().second % tips.length];
  }
}