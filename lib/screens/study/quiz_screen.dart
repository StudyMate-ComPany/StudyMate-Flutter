import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/ai_provider.dart';
import '../../theme/modern_theme.dart';

class QuizScreen extends StatefulWidget {
  final String subject;
  final String? topic;
  final String difficulty;
  final int questionCount;
  
  const QuizScreen({
    super.key,
    required this.subject,
    this.topic,
    this.difficulty = 'medium',
    this.questionCount = 5,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  final Map<int, String> _userAnswers = {};
  bool _showResults = false;
  List<dynamic>? _questions;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }
  
  Future<void> _loadQuiz() async {
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    
    final response = await aiProvider.generateQuiz(
      subject: widget.subject,
      topic: widget.topic,
      questionCount: widget.questionCount,
      difficulty: widget.difficulty,
    );
    
    if (response != null && response.metadata?['questions'] != null) {
      setState(() {
        _questions = response.metadata!['questions'] as List;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('문제를 생성하는데 실패했습니다'),
            backgroundColor: ModernTheme.errorColor,
          ),
        );
        Navigator.pop(context);
      }
    }
  }
  
  void _submitAnswer(String answer) {
    HapticFeedback.lightImpact();
    setState(() {
      _userAnswers[_currentQuestionIndex] = answer;
    });
  }
  
  void _nextQuestion() {
    HapticFeedback.lightImpact();
    if (_currentQuestionIndex < (_questions?.length ?? 0) - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _showResultsDialog();
    }
  }
  
  void _previousQuestion() {
    HapticFeedback.lightImpact();
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }
  
  void _showResultsDialog() {
    int correctCount = 0;
    for (int i = 0; i < (_questions?.length ?? 0); i++) {
      if (_userAnswers[i]?.toLowerCase() == 
          _questions![i]['answer'].toString().toLowerCase()) {
        correctCount++;
      }
    }
    
    final percentage = (_questions?.isNotEmpty ?? false) 
        ? (correctCount / _questions!.length * 100).round() 
        : 0;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: ModernTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              '퀴즈 완료!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: percentage >= 80 
                    ? ModernTheme.successGradient
                    : percentage >= 60
                        ? ModernTheme.warningGradient
                        : ModernTheme.errorGradient,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$percentage%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ).animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text(
              '정답: $correctCount / ${_questions?.length ?? 0}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              percentage >= 80 
                  ? '훌륭해요! 🎉'
                  : percentage >= 60
                      ? '잘했어요! 👍'
                      : '더 노력해보세요! 💪',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _showResults = true;
              });
            },
            child: const Text('결과 보기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('완료'),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: ModernTheme.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: ModernTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 40,
                ),
              ).animate()
                .scale(duration: 1.seconds, curve: Curves.elasticOut)
                .then()
                .shimmer(duration: 1.seconds),
              const SizedBox(height: 24),
              const Text(
                'AI가 문제를 생성중입니다...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ModernTheme.textPrimary,
                ),
              ).animate()
                .fadeIn(delay: 500.ms),
              const SizedBox(height: 32),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ModernTheme.primaryColor),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_questions == null || _questions!.isEmpty) {
      return Scaffold(
        backgroundColor: ModernTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: ModernTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            '퀴즈',
            style: TextStyle(color: ModernTheme.textPrimary),
          ),
        ),
        body: const Center(
          child: Text('문제가 없습니다'),
        ),
      );
    }
    
    final currentQuestion = _questions![_currentQuestionIndex];
    final questionType = currentQuestion['type'] ?? 'multiple_choice';
    
    return Scaffold(
      backgroundColor: ModernTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ModernTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${widget.subject} 퀴즈',
          style: const TextStyle(
            color: ModernTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: ModernTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_currentQuestionIndex + 1} / ${_questions!.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            height: 4,
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions!.length,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(ModernTheme.primaryColor),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: ModernTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getQuestionTypeLabel(questionType),
                                style: const TextStyle(
                                  color: ModernTheme.primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (currentQuestion['difficulty'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor(currentQuestion['difficulty'])
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _getDifficultyLabel(currentQuestion['difficulty']),
                                  style: TextStyle(
                                    color: _getDifficultyColor(currentQuestion['difficulty']),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          currentQuestion['question'] ?? '',
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
                    .slideX(begin: 0.1, end: 0),
                  
                  const SizedBox(height: 24),
                  
                  // Answer options
                  if (questionType == 'multiple_choice' && 
                      currentQuestion['options'] != null)
                    ...List.generate(
                      currentQuestion['options'].length,
                      (index) {
                        final option = currentQuestion['options'][index];
                        final isSelected = _userAnswers[_currentQuestionIndex] == option;
                        final isCorrect = _showResults && 
                            option == currentQuestion['answer'];
                        final isWrong = _showResults && 
                            isSelected && 
                            option != currentQuestion['answer'];
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: _showResults ? null : () => _submitAnswer(option),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? ModernTheme.successColor.withOpacity(0.1)
                                    : isWrong
                                        ? ModernTheme.errorColor.withOpacity(0.1)
                                        : isSelected
                                            ? ModernTheme.primaryColor.withOpacity(0.1)
                                            : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isCorrect
                                      ? ModernTheme.successColor
                                      : isWrong
                                          ? ModernTheme.errorColor
                                          : isSelected
                                              ? ModernTheme.primaryColor
                                              : Colors.grey[300]!,
                                  width: isSelected || isCorrect || isWrong ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isCorrect
                                          ? ModernTheme.successColor
                                          : isWrong
                                              ? ModernTheme.errorColor
                                              : isSelected
                                                  ? ModernTheme.primaryColor
                                                  : Colors.grey[300],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(65 + index),
                                        style: TextStyle(
                                          color: isSelected || isCorrect || isWrong
                                              ? Colors.white
                                              : ModernTheme.textSecondary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: ModernTheme.textPrimary,
                                        fontWeight: isSelected || isCorrect || isWrong
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isCorrect)
                                    const Icon(
                                      Icons.check_circle,
                                      color: ModernTheme.successColor,
                                    ),
                                  if (isWrong)
                                    const Icon(
                                      Icons.cancel,
                                      color: ModernTheme.errorColor,
                                    ),
                                ],
                              ),
                            ),
                          ).animate()
                            .fadeIn(delay: Duration(milliseconds: 100 * index))
                            .slideX(begin: 0.1, end: 0),
                        );
                      },
                    )
                  else if (questionType == 'true_false')
                    Row(
                      children: [
                        Expanded(
                          child: _buildTrueFalseButton('True', 'true'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTrueFalseButton('False', 'false'),
                        ),
                      ],
                    )
                  else
                    // Short answer
                    TextField(
                      onChanged: (value) => _submitAnswer(value),
                      decoration: InputDecoration(
                        hintText: '답을 입력하세요',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: ModernTheme.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  
                  // Explanation (shown after results)
                  if (_showResults && currentQuestion['explanation'] != null)
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: Colors.blue[700],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '해설',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            currentQuestion['explanation'],
                            style: TextStyle(
                              color: Colors.blue[900],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ).animate()
                      .fadeIn(delay: 500.ms)
                      .slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _previousQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: ModernTheme.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '이전',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _userAnswers[_currentQuestionIndex] != null
                        ? _nextQuestion
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ModernTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentQuestionIndex < _questions!.length - 1
                          ? '다음'
                          : '제출',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTrueFalseButton(String label, String value) {
    final isSelected = _userAnswers[_currentQuestionIndex] == value;
    final currentQuestion = _questions![_currentQuestionIndex];
    final isCorrect = _showResults && value == currentQuestion['answer'];
    final isWrong = _showResults && isSelected && value != currentQuestion['answer'];
    
    return InkWell(
      onTap: _showResults ? null : () => _submitAnswer(value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isCorrect
              ? ModernTheme.successColor.withOpacity(0.1)
              : isWrong
                  ? ModernTheme.errorColor.withOpacity(0.1)
                  : isSelected
                      ? ModernTheme.primaryColor.withOpacity(0.1)
                      : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCorrect
                ? ModernTheme.successColor
                : isWrong
                    ? ModernTheme.errorColor
                    : isSelected
                        ? ModernTheme.primaryColor
                        : Colors.grey[300]!,
            width: isSelected || isCorrect || isWrong ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isCorrect
                  ? ModernTheme.successColor
                  : isWrong
                      ? ModernTheme.errorColor
                      : isSelected
                          ? ModernTheme.primaryColor
                          : ModernTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
  
  String _getQuestionTypeLabel(String type) {
    switch (type) {
      case 'multiple_choice':
        return '객관식';
      case 'true_false':
        return '참/거짓';
      case 'short_answer':
        return '주관식';
      default:
        return '문제';
    }
  }
  
  String _getDifficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return '쉬움';
      case 'medium':
        return '보통';
      case 'hard':
        return '어려움';
      default:
        return difficulty;
    }
  }
  
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}