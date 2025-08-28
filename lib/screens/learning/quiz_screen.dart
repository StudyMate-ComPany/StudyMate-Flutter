import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/learning_plan_provider.dart';
import '../../models/learning_plan.dart';
import '../../theme/modern_theme.dart';

class QuizScreen extends StatefulWidget {
  final StudyContent content;
  final DailyTask task;
  final String timeSlot;
  
  const QuizScreen({
    super.key,
    required this.content,
    required this.task,
    required this.timeSlot,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  
  int _currentQuestionIndex = 0;
  int? _selectedAnswer;
  bool _showExplanation = false;
  int _correctAnswers = 0;
  final Map<int, int?> _userAnswers = {};
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  QuizQuestion? get currentQuestion {
    if (widget.content.questions == null || 
        widget.content.questions!.isEmpty) {
      return null;
    }
    return widget.content.questions![_currentQuestionIndex];
  }
  
  bool get isLastQuestion {
    if (widget.content.questions == null) return true;
    return _currentQuestionIndex >= widget.content.questions!.length - 1;
  }
  
  void _selectAnswer(int index) {
    if (_showExplanation) return;
    
    HapticFeedback.lightImpact();
    setState(() {
      _selectedAnswer = index;
    });
  }
  
  void _checkAnswer() {
    if (_selectedAnswer == null) return;
    
    HapticFeedback.mediumImpact();
    
    final isCorrect = _selectedAnswer == currentQuestion?.correctAnswer;
    if (isCorrect) {
      _correctAnswers++;
    }
    
    _userAnswers[_currentQuestionIndex] = _selectedAnswer;
    
    setState(() {
      _showExplanation = true;
    });
    
    _animationController.forward();
  }
  
  void _nextQuestion() {
    if (isLastQuestion) {
      _showResults();
      return;
    }
    
    _animationController.reverse().then((_) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showExplanation = false;
      });
    });
  }
  
  void _showResults() {
    HapticFeedback.mediumImpact();
    
    final totalQuestions = widget.content.questions?.length ?? 0;
    final percentage = (totalQuestions > 0) 
      ? (_correctAnswers / totalQuestions * 100).round() 
      : 0;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),
              
              // Score Circle
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: percentage >= 80
                      ? [ModernTheme.successColor, Colors.green[300]!]
                      : percentage >= 60
                        ? [ModernTheme.primaryColor, ModernTheme.secondaryColor]
                        : [ModernTheme.warningColor, ModernTheme.accentColor],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (percentage >= 80 
                        ? ModernTheme.successColor 
                        : ModernTheme.primaryColor).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$_correctAnswers / $totalQuestions',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ).animate()
                .scale(duration: 600.ms)
                .fadeIn(),
              
              const SizedBox(height: 32),
              
              Text(
                _getResultMessage(percentage),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: ModernTheme.textPrimary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Text(
                _getEncouragement(percentage),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: ModernTheme.textSecondary,
                  height: 1.5,
                ),
              ),
              
              const Spacer(),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _currentQuestionIndex = 0;
                          _selectedAnswer = null;
                          _showExplanation = false;
                          _correctAnswers = 0;
                          _userAnswers.clear();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: ModernTheme.primaryColor, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '다시 풀기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final provider = Provider.of<LearningPlanProvider>(context, listen: false);
                        await provider.completeTask(widget.task.id, widget.timeSlot);
                        
                        if (mounted) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: ModernTheme.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '완료',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
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
  
  @override
  Widget build(BuildContext context) {
    if (currentQuestion == null) {
      return Scaffold(
        backgroundColor: ModernTheme.backgroundColor,
        body: const Center(
          child: Text('퀴즈를 불러올 수 없습니다'),
        ),
      );
    }
    
    final totalQuestions = widget.content.questions?.length ?? 0;
    final progress = (_currentQuestionIndex + 1) / totalQuestions;
    
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
              Icons.close,
              size: 20,
              color: ModernTheme.primaryColor,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              '문제 ${_currentQuestionIndex + 1} / $totalQuestions',
              style: const TextStyle(
                fontSize: 14,
                color: ModernTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(ModernTheme.primaryColor),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Card
            Container(
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
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: ModernTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Q${_currentQuestionIndex + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentQuestion!.question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ModernTheme.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ).animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: -0.1, end: 0),
            
            const SizedBox(height: 32),
            
            // Answer Options
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion!.options.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedAnswer == index;
                  final isCorrect = index == currentQuestion!.correctAnswer;
                  final showResult = _showExplanation;
                  
                  Color? backgroundColor;
                  Color? borderColor;
                  Color? textColor;
                  
                  if (showResult) {
                    if (isCorrect) {
                      backgroundColor = ModernTheme.successColor.withOpacity(0.1);
                      borderColor = ModernTheme.successColor;
                      textColor = ModernTheme.successColor;
                    } else if (isSelected) {
                      backgroundColor = ModernTheme.errorColor.withOpacity(0.1);
                      borderColor = ModernTheme.errorColor;
                      textColor = ModernTheme.errorColor;
                    }
                  } else if (isSelected) {
                    backgroundColor = ModernTheme.primaryColor.withOpacity(0.1);
                    borderColor = ModernTheme.primaryColor;
                    textColor = ModernTheme.primaryColor;
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _selectAnswer(index),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: backgroundColor ?? Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: borderColor ?? Colors.grey[300]!,
                            width: borderColor != null ? 2 : 1,
                          ),
                          boxShadow: isSelected && !showResult 
                            ? ModernTheme.cardShadow 
                            : [],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: (textColor ?? ModernTheme.textSecondary)
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textColor ?? ModernTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                currentQuestion!.options[index],
                                style: TextStyle(
                                  fontSize: 15,
                                  color: textColor ?? ModernTheme.textPrimary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                            if (showResult)
                              Icon(
                                isCorrect ? Icons.check_circle : 
                                isSelected ? Icons.cancel : null,
                                color: isCorrect ? ModernTheme.successColor : ModernTheme.errorColor,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ).animate()
                    .fadeIn(delay: Duration(milliseconds: 100 * index))
                    .slideX(begin: 0.1, end: 0);
                },
              ),
            ),
            
            // Explanation (shown after answer)
            if (_showExplanation)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animationController.value,
                    child: Opacity(
                      opacity: _animationController.value,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ModernTheme.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ModernTheme.secondaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.lightbulb_outline,
                                  color: ModernTheme.secondaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '해설',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: ModernTheme.secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentQuestion!.explanation,
                              style: const TextStyle(
                                fontSize: 14,
                                color: ModernTheme.textPrimary,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            
            const SizedBox(height: 20),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _showExplanation 
                  ? _nextQuestion 
                  : (_selectedAnswer != null ? _checkAnswer : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _showExplanation 
                    ? (isLastQuestion ? '결과 보기' : '다음 문제')
                    : '정답 확인',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getResultMessage(int percentage) {
    if (percentage >= 90) return '완벽해요! 🎉';
    if (percentage >= 80) return '훌륭해요! 👏';
    if (percentage >= 70) return '잘했어요! 👍';
    if (percentage >= 60) return '좋아요! 😊';
    return '화이팅! 💪';
  }
  
  String _getEncouragement(int percentage) {
    if (percentage >= 90) {
      return '정말 대단해요!\n오늘 학습 내용을 완벽히 이해하셨네요!';
    }
    if (percentage >= 70) {
      return '좋은 성과예요!\n조금만 더 복습하면 완벽할 거예요!';
    }
    return '괜찮아요!\n틀린 문제를 다시 한번 복습해보세요!';
  }
}