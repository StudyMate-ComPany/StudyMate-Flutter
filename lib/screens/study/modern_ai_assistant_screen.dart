import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/ai_provider.dart';
import '../../models/ai_response.dart';
import '../../theme/studymate_theme.dart';
import '../../widgets/korean_enabled_text_field.dart';

class ModernAIAssistantScreen extends StatefulWidget {
  const ModernAIAssistantScreen({super.key});

  @override
  State<ModernAIAssistantScreen> createState() => _ModernAIAssistantScreenState();
}

class _ModernAIAssistantScreenState extends State<ModernAIAssistantScreen> 
    with SingleTickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late AnimationController _animationController;
  bool _isTyping = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHistory();
    });
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadHistory() async {
    final provider = Provider.of<AIProvider>(context, listen: false);
    await provider.loadHistory(limit: 20);
  }
  
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final message = _messageController.text.trim();
    _messageController.clear();
    
    HapticFeedback.lightImpact();
    
    setState(() {
      _isTyping = true;
    });
    
    final provider = Provider.of<AIProvider>(context, listen: false);
    await provider.askQuestion(message);
    
    setState(() {
      _isTyping = false;
    });
    
    // 스크롤을 맨 아래로
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        StudyMateTheme.primaryBlue,
                        StudyMateTheme.accentPink,
                      ],
                      transform: GradientRotation(_animationController.value * 3.14),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 20,
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            const Text(
              '스마트 학습 도우미',
              style: TextStyle(
                color: StudyMateTheme.darkNavy,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: StudyMateTheme.accentPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.refresh,
                size: 20,
                color: StudyMateTheme.accentPink,
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              _loadHistory();
            },
          ),
        ],
      ),
      body: Consumer<AIProvider>(
        builder: (context, aiProvider, child) {
          return Column(
            children: [
              // Quick Actions
              _buildQuickActions(aiProvider),
              
              // Chat Messages
              Expanded(
                child: aiProvider.history.isEmpty
                  ? _buildEmptyState()
                  : _buildChatList(aiProvider),
              ),
              
              // Typing Indicator
              if (_isTyping) _buildTypingIndicator(),
              
              // Input Field
              _buildInputField(aiProvider),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildQuickActions(AIProvider aiProvider) {
    final quickActions = [
      {
        'icon': Icons.schedule,
        'label': '학습 계획',
        'color': StudyMateTheme.primaryBlue,
        'action': () async {
          HapticFeedback.lightImpact();
          setState(() => _isTyping = true);
          await aiProvider.askQuestion(
            '오늘의 효과적인 학습 계획을 만들어주세요',
            type: AIResponseType.studyPlan,
          );
          setState(() => _isTyping = false);
        },
      },
      {
        'icon': Icons.quiz,
        'label': '퀴즈 생성',
        'color': StudyMateTheme.accentPink,
        'action': () async {
          HapticFeedback.lightImpact();
          _showQuizGenerationDialog(aiProvider);
        },
      },
      {
        'icon': Icons.lightbulb,
        'label': '개념 설명',
        'color': StudyMateTheme.accentPink,
        'action': () async {
          HapticFeedback.lightImpact();
          _showConceptExplanationDialog(aiProvider);
        },
      },
      {
        'icon': Icons.summarize,
        'label': '요약',
        'color': StudyMateTheme.primaryBlue,
        'action': () async {
          HapticFeedback.lightImpact();
          setState(() => _isTyping = true);
          await aiProvider.askQuestion(
            '오늘 학습한 내용을 요약해주세요',
            type: AIResponseType.recommendation,
          );
          setState(() => _isTyping = false);
        },
      },
    ];
    
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: quickActions.length,
        itemBuilder: (context, index) {
          final action = quickActions[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: action['action'] as VoidCallback,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 80,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
          BoxShadow(
            color: StudyMateTheme.primaryBlue.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (action['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        action['icon'] as IconData,
                        size: 20,
                        color: action['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action['label'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: StudyMateTheme.darkNavy,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ).animate()
            .fadeIn(delay: Duration(milliseconds: index * 100))
            .slideX(begin: 0.1, end: 0);
        },
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
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: StudyMateTheme.buttonGradient,
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.smart_toy,
                size: 60,
                color: Colors.white,
              ),
            ).animate()
              .scale(delay: 200.ms, duration: 600.ms)
              .fadeIn(),
            
            const SizedBox(height: 24),
            
            const Text(
              '스마트 학습 도우미입니다',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: StudyMateTheme.darkNavy,
              ),
            ).animate()
              .fadeIn(delay: 400.ms),
            
            const SizedBox(height: 8),
            
            const Text(
              '무엇이든 물어보세요!\n학습을 도와드리겠습니다',
              style: TextStyle(
                fontSize: 14,
                color: StudyMateTheme.grayText,
              ),
              textAlign: TextAlign.center,
            ).animate()
              .fadeIn(delay: 500.ms),
            
            const SizedBox(height: 32),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildSuggestionChip('오늘 뭘 공부할까요?'),
                _buildSuggestionChip('수학 문제 풀어주세요'),
                _buildSuggestionChip('영어 문법 설명해주세요'),
                _buildSuggestionChip('과학 퀴즈 만들어주세요'),
              ],
            ).animate()
              .fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSuggestionChip(String text) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        _messageController.text = text;
        _sendMessage();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: StudyMateTheme.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: StudyMateTheme.primaryBlue.withOpacity(0.3),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            color: StudyMateTheme.primaryBlue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
  
  Widget _buildChatList(AIProvider aiProvider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: aiProvider.history.length,
      itemBuilder: (context, index) {
        final response = aiProvider.history[index];
        
        return Column(
          children: [
            _buildMessageBubble(
              response.query,
              isUser: true,
            ).animate()
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.1, end: 0),
            if (response.response.isNotEmpty)
              _buildMessageBubble(
                response.response,
                isUser: false,
              ).animate()
                .fadeIn(duration: 300.ms, delay: 200.ms)
                .slideX(begin: -0.1, end: 0),
          ],
        );
      },
    );
  }
  
  Widget _buildMessageBubble(String message, {required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: isUser 
            ? StudyMateTheme.buttonGradient
            : null,
          color: isUser ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
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
            if (!isUser)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: StudyMateTheme.buttonGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.smart_toy,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'AI 도우미',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: StudyMateTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            if (!isUser) const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: isUser ? Colors.white : StudyMateTheme.darkNavy,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTypingIndicator() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: StudyMateTheme.buttonGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.smart_toy,
                size: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(3, (index) {
                  return Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: StudyMateTheme.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ).animate(
                    onPlay: (controller) => controller.repeat(),
                  )
                    .scale(
                      delay: Duration(milliseconds: index * 200),
                      duration: 600.ms,
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1, 1),
                    )
                    .then()
                    .scale(
                      duration: 600.ms,
                      begin: const Offset(1, 1),
                      end: const Offset(0.5, 0.5),
                    );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInputField(AIProvider aiProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: StudyMateTheme.lightBlue,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: '메시지를 입력하세요...',
                    hintStyle: const TextStyle(
                      color: StudyMateTheme.grayText,
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        _showAttachmentOptions();
                      },
                      icon: const Icon(
                        Icons.attach_file,
                        color: StudyMateTheme.grayText,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: StudyMateTheme.buttonGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: StudyMateTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: aiProvider.state == AIState.loading || _isTyping
                  ? null 
                  : _sendMessage,
                icon: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showQuizGenerationDialog(AIProvider aiProvider) {
    String subject = '';
    int questionCount = 5;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Padding(
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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: StudyMateTheme.buttonGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.quiz,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '퀴즈 생성',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: StudyMateTheme.darkNavy,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  TextField(
                    onChanged: (value) => subject = value,
                    decoration: InputDecoration(
                      labelText: '과목',
                      hintText: '예: 수학, 영어, 과학',
                      prefixIcon: const Icon(Icons.book, color: StudyMateTheme.primaryBlue),
                      filled: true,
                      fillColor: StudyMateTheme.lightBlue,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      const Icon(Icons.numbers, color: StudyMateTheme.primaryBlue),
                      const SizedBox(width: 12),
                      const Text('문제 수:'),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Slider(
                          value: questionCount.toDouble(),
                          min: 3,
                          max: 10,
                          divisions: 7,
                          activeColor: StudyMateTheme.primaryBlue,
                          label: questionCount.toString(),
                          onChanged: (value) {
                            setState(() {
                              questionCount = value.toInt();
                            });
                          },
                        ),
                      ),
                      Text(
                        '$questionCount개',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: StudyMateTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: const BorderSide(color: StudyMateTheme.primaryBlue, width: 2),
                          ),
                          child: const Text('취소'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: subject.isEmpty ? null : () async {
                            Navigator.pop(context);
                            setState(() => _isTyping = true);
                            await aiProvider.generateQuiz(
                              subject: subject,
                              questionCount: questionCount,
                            );
                            setState(() => _isTyping = false);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: StudyMateTheme.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text('생성'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  void _showConceptExplanationDialog(AIProvider aiProvider) {
    String concept = '';
    String subject = '';
    
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Padding(
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: StudyMateTheme.buttonGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lightbulb,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '개념 설명',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: StudyMateTheme.darkNavy,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              TextField(
                onChanged: (value) => concept = value,
                decoration: InputDecoration(
                  labelText: '개념',
                  hintText: '예: 광합성, 미분, 영문법',
                  prefixIcon: const Icon(Icons.lightbulb_outline, color: StudyMateTheme.primaryBlue),
                  filled: true,
                  fillColor: StudyMateTheme.lightBlue,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              TextField(
                onChanged: (value) => subject = value,
                decoration: InputDecoration(
                  labelText: '과목 (선택)',
                  hintText: '예: 생물학, 수학, 영어',
                  prefixIcon: const Icon(Icons.book, color: StudyMateTheme.primaryBlue),
                  filled: true,
                  fillColor: StudyMateTheme.lightBlue,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: const BorderSide(color: StudyMateTheme.primaryBlue, width: 2),
                      ),
                      child: const Text('취소'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: concept.isEmpty ? null : () async {
                        Navigator.pop(context);
                        setState(() => _isTyping = true);
                        await aiProvider.explainConcept(
                          concept: concept,
                          subject: subject.isEmpty ? null : subject,
                        );
                        setState(() => _isTyping = false);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: StudyMateTheme.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('설명 받기'),
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
  
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  Icons.image,
                  '이미지',
                  StudyMateTheme.primaryBlue,
                  () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('이미지 첨부 기능을 준비 중입니다'),
                        backgroundColor: StudyMateTheme.primaryBlue,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  },
                ),
                _buildAttachmentOption(
                  Icons.file_copy,
                  '파일',
                  StudyMateTheme.accentPink,
                  () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('파일 첨부 기능을 준비 중입니다'),
                        backgroundColor: StudyMateTheme.accentPink,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  },
                ),
                _buildAttachmentOption(
                  Icons.camera_alt,
                  '카메라',
                  StudyMateTheme.accentPink,
                  () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('카메라 기능을 준비 중입니다'),
                        backgroundColor: StudyMateTheme.accentPink,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAttachmentOption(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 28,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: StudyMateTheme.darkNavy,
            ),
          ),
        ],
      ),
    );
  }
}