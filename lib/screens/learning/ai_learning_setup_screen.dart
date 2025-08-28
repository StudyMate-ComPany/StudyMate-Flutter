import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/learning_plan_provider.dart';
import '../../theme/modern_theme.dart';
import '../../models/learning_plan.dart';
import '../../services/chatgpt_service.dart';
import '../home/new_home_screen.dart';

class AILearningSetupScreen extends StatefulWidget {
  const AILearningSetupScreen({super.key});

  @override
  State<AILearningSetupScreen> createState() => _AILearningSetupScreenState();
}

class _AILearningSetupScreenState extends State<AILearningSetupScreen> 
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  
  late AnimationController _animationController;
  late AnimationController _typingAnimationController;
  
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _planGenerated = false;
  Map<String, dynamic>? _generatedPlan;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    // 초기 환영 메시지
    _addAIMessage(
      '안녕하세요! 스마트 학습 플래너입니다 📚\n\n'
      '무엇을 공부하고 싶으신가요? 목표와 기간을 자유롭게 말씀해주세요.\n\n'
      '예시:\n'
      '• "토익 900점을 2달 안에 달성하고 싶어요"\n'
      '• "한국사능력검정시험 1급을 한달 동안 공부해서 합격하고 싶어"\n'
      '• "파이썬 프로그래밍을 3주 안에 마스터하고 싶습니다"',
      isInitial: true,
    );
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }
  
  void _addAIMessage(String message, {bool isInitial = false}) {
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    
    if (!isInitial) {
      _scrollToBottom();
    }
  }
  
  void _addUserMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }
  
  void _scrollToBottom() {
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
  
  Future<void> _processUserInput() async {
    if (_messageController.text.trim().isEmpty) return;
    
    final userInput = _messageController.text.trim();
    _messageController.clear();
    
    HapticFeedback.lightImpact();
    
    _addUserMessage(userInput);
    
    setState(() {
      _isTyping = true;
    });
    
    // ChatGPT로 사용자 입력 분석
    final chatGPTService = ChatGPTService();
    Map<String, dynamic> analysis;
    
    try {
      print('\n' + '🎯' * 30);
      print('🎯 ChatGPT 분석 시작!');
      print('사용자 입력: "$userInput"');
      print('🎯' * 30);
      
      // ChatGPT의 analyzeUserInput으로 과목/기간/수준 파싱
      final result = await chatGPTService.analyzeUserInput(userInput);
      
      print('\n📊 ChatGPT 분석 결과:');
      print(result);
      
      if (result['success'] == true && result['analysis'] != null) {
        final analysisResult = result['analysis'];
        
        // ChatGPT가 분석한 결과를 그대로 사용
        analysis = {
          'subject': analysisResult['subject'] ?? '일반 학습',
          'goal': analysisResult['goal'] ?? userInput,
          'level': analysisResult['currentLevel'] ?? 'beginner',
          'duration': analysisResult['daysAvailable'] ?? 30,
          'hoursPerDay': analysisResult['hoursPerDay'] ?? 2,
          'studyType': analysisResult['studyType'] ?? 'general',
          'additionalInfo': analysisResult['additionalInfo'] ?? '',
        };
        
        print('\n✅ ChatGPT 분석 성공!');
        print('  - 과목: ${analysis['subject']}');
        print('  - 목표: ${analysis['goal']}');
        print('  - 기간: ${analysis['duration']}일');
        print('  - 수준: ${analysis['level']}');
      } else {
        // ChatGPT 실패 시 기본값 사용
        print('\n⚠️ ChatGPT 분석 실패 - 기본값 사용');
        analysis = {
          'subject': '자유 학습',
          'goal': userInput,
          'level': 'beginner',
          'duration': 30,
          'hoursPerDay': 2,
          'studyType': 'general',
        };
      }
    } catch (e) {
      print('\n❌ analyzeUserInput 예외 발생!');
      print('예외: $e');
      print('📎 기본 분석 결과로 대체합니다.');
      
      // 오류 시 사용자 입력 그대로 사용하되, 필요한 필드를 모두 포함
      analysis = {
        'goal': userInput,
        'subject': '자유 학습',
        'level': 'beginner',
        'duration': 30,
        'hoursPerDay': 2,
        'studyType': 'general',
        'additionalInfo': '기본 설정으로 생성됨 (ChatGPT 분석 실패)',
      };
    }
    
    setState(() {
      _isTyping = false;
      _generatedPlan = analysis;
      _planGenerated = true;
    });
    
    print('\n🎯 UI 상태 업데이트 완료!');
    print('━' * 40);
    print('📊 현재 상태:');
    print('  - _planGenerated: $_planGenerated');
    print('  - _generatedPlan != null: ${_generatedPlan != null}');
    print('  - _isTyping: $_isTyping');
    print('  - analysis 키들: ${analysis.keys.toList()}');
    print('━' * 40);
    
    // UI 강제 새로고침 (필요시)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        print('🔄 UI 강제 새로고침 실행됨');
      }
    });
    
    // AI 응답 - ChatGPT가 분석한 결과를 명확하게 표시
    _addAIMessage(
      '입력하신 내용을 AI로 분석한 결과입니다:\n\n'
      '━━━━━━━━━━━━━━━━━━━━━━━━━━\n'
      '📖 **과목**: ${analysis['subject']}\n'
      '🎯 **목표**: ${analysis['goal']}\n'
      '📅 **학습 기간**: ${analysis['duration']}일\n'
      '📊 **현재 수준**: ${_getLevelKorean(analysis['level'])}\n'
      '⏰ **하루 학습 시간**: ${analysis['hoursPerDay']}시간\n'
      '📚 **학습 유형**: ${_getStudyTypeKorean(analysis['studyType'])}\n'
      '━━━━━━━━━━━━━━━━━━━━━━━━━━\n\n'
      '이 정보를 바탕으로 맞춤형 학습 플랜을 생성하고 있습니다...\n'
      '잠시 후 메인 화면으로 자동 이동됩니다! 🚀',
    );

    // 자동으로 학습 플랜 생성 및 메인 화면 이동
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _planGenerated && _generatedPlan != null) {
        _startLearningPlan();
      }
    });
  }
  
  String _getLevelKorean(String level) {
    switch(level?.toLowerCase()) {
      case 'beginner': return '초급';
      case 'intermediate': return '중급';
      case 'advanced': return '고급';
      default: return level ?? '초급';
    }
  }
  
  String _getStudyTypeKorean(String type) {
    switch(type) {
      case 'exam_prep': return '시험 준비';
      case 'certification': return '자격증 취득';
      case 'hobby': return '취미 학습';
      case 'professional': return '전문 역량 개발';
      case 'general': return '일반 학습';
      default: return type ?? '일반 학습';
    }
  }
  
  Map<String, dynamic> _analyzeUserInput(String input) {
    final lowerInput = input.toLowerCase();
    String goal = input;
    String subject = '일반 학습';
    String level = '초급';
    int duration = 30;
    
    // 과목 자동 감지 (확장된 키워드)
    final subjectPatterns = {
      '한국사': ['한국사', '역사', 'korean history'],
      '영어': ['영어', 'english', '영문법', 'grammar'],
      '토익': ['toeic', '토익', 'toefl', '토플'],
      '토스': ['toeic speaking', '토익스피킹', '토스', 'opic', '오픽'],
      '수학': ['수학', 'math', 'mathematics', '미적분', '기하', '대수', 'calculus', 'algebra', 'geometry'],
      '과학': ['과학', 'science', '물리', '화학', '생물', 'physics', 'chemistry', 'biology'],
      '프로그래밍': ['프로그래밍', 'programming', '코딩', 'coding', 'development', '개발'],
      '파이썬': ['python', '파이썬', 'django', '장고'],
      '자바': ['java', '자바', 'spring', '스프링'],
      '자바스크립트': ['javascript', 'js', '자바스크립트', 'react', '리액트', 'vue', 'angular'],
      '일본어': ['일본어', 'japanese', 'jlpt', '일어'],
      '중국어': ['중국어', 'chinese', 'hsk', '중어'],
      '스페인어': ['스페인어', 'spanish', 'dele'],
      '프랑스어': ['프랑스어', 'french', 'delf'],
      '독일어': ['독일어', 'german', '독어'],
      'SQL': ['sql', 'database', '데이터베이스', 'mysql', 'postgresql'],
      '데이터분석': ['데이터분석', 'data analysis', '통계', 'statistics', 'r언어', 'tableau'],
      '머신러닝': ['머신러닝', 'machine learning', 'ml', 'ai', '인공지능', 'deep learning', '딥러닝'],
      '회계': ['회계', 'accounting', '부기', '재무', 'finance'],
      '경제': ['경제', 'economics', '경제학'],
      '경영': ['경영', 'business', 'management', 'mba'],
      '마케팅': ['마케팅', 'marketing', '광고', 'advertising'],
      'UI/UX': ['ui', 'ux', '디자인', 'design', 'figma', 'sketch'],
      '운전': ['운전', 'driving', '운전면허', '1종', '2종'],
      '요리': ['요리', 'cooking', '조리', '제빵', 'baking'],
      '음악': ['음악', 'music', '피아노', '기타', 'guitar', 'piano'],
      '미술': ['미술', 'art', '그림', '드로잉', 'drawing', 'painting'],
    };
    
    // 과목 감지
    for (final entry in subjectPatterns.entries) {
      for (final keyword in entry.value) {
        if (lowerInput.contains(keyword)) {
          subject = entry.key;
          break;
        }
      }
      if (subject != '일반 학습') break;
    }
    
    // 기간 감지 (영어 지원 추가)
    // lowerInput 이미 선언되어 있음
    if (lowerInput.contains('year')) {
      // "one year", "two years", "3 year" 등 처리
      if (lowerInput.contains('two') || lowerInput.contains('2')) {
        duration = 730;  // 2년
      } else if (lowerInput.contains('three') || lowerInput.contains('3')) {
        duration = 1095;  // 3년
      } else {
        duration = 365;  // 1년
      }
    } else if (lowerInput.contains('month')) {
      // "two month", "2 month", "3 months" 등 처리
      if (lowerInput.contains('two') || lowerInput.contains('2')) {
        duration = 60;
      } else if (lowerInput.contains('three') || lowerInput.contains('3')) {
        duration = 90;
      } else if (lowerInput.contains('six') || lowerInput.contains('6')) {
        duration = 180;
      } else {
        duration = 30; // 기본 1개월
      }
    } else if (lowerInput.contains('week')) {
      if (lowerInput.contains('two') || lowerInput.contains('2')) {
        duration = 14;
      } else if (lowerInput.contains('three') || lowerInput.contains('3')) {
        duration = 21;
      } else {
        duration = 7;
      }
    } else if (input.contains('한달') || input.contains('1달') || input.contains('한 달')) {
      duration = 30;
    } else if (input.contains('2달') || input.contains('두달')) {
      duration = 60;
    } else if (input.contains('3달') || input.contains('세달')) {
      duration = 90;
    } else if (input.contains('3주')) {
      duration = 21;
    } else if (input.contains('2주')) {
      duration = 14;
    }
    
    return {
      'goal': goal,
      'subject': subject,
      'level': level,
      'duration': duration,
      'curriculum': _generateCurriculum(subject, level, duration),
    };
  }
  
  Map<String, dynamic> _generateCurriculum(String subject, String level, int days) {
    // 커리큘럼 생성 (실제로는 AI API가 생성)
    final weeks = (days / 7).ceil();
    final curriculum = <String, dynamic>{};
    
    for (int week = 1; week <= weeks; week++) {
      curriculum['week_$week'] = {
        'focus': '${week}주차 학습 목표',
        'topics': _getWeeklyTopics(subject, week, weeks),
        'milestones': ['주간 테스트', '복습'],
      };
    }
    
    return curriculum;
  }
  
  List<String> _getWeeklyTopics(String subject, int week, int totalWeeks) {
    if (subject == '한국사') {
      switch (week) {
        case 1:
          return ['선사시대와 고조선', '삼국시대', '남북국시대'];
        case 2:
          return ['고려시대', '조선 전기', '조선 후기'];
        case 3:
          return ['개항기', '일제강점기', '독립운동'];
        case 4:
          return ['현대사', '경제성장', '민주화'];
        default:
          return ['종합복습', '모의고사', '오답노트'];
      }
    }
    return ['기초', '심화', '응용'];
  }
  
  Future<void> _startLearningPlan() async {
    print('\n🚀 _startLearningPlan() 메서드 시작!');
    print('━' * 60);
    
    try {
      // 사전 검증
      if (_generatedPlan == null) {
        print('❌ _generatedPlan이 null입니다. 함수를 종료합니다.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('학습 플랜 데이터가 없습니다. 다시 시도해주세요.')),
          );
        }
        return;
      }
      
      // 필수 필드 검증
      final requiredFields = ['goal', 'subject', 'level', 'duration'];
      for (final field in requiredFields) {
        if (!_generatedPlan!.containsKey(field) || _generatedPlan![field] == null) {
          print('❌ 필수 필드 "$field"가 누락되었습니다.');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('학습 플랜 데이터가 불완전합니다. ($field 누락)')),
            );
          }
          return;
        }
      }
      
      print('📋 학습 플랜 데이터 검증 완료:');
      print('  - goal: ${_generatedPlan!['goal']}');
      print('  - subject: ${_generatedPlan!['subject']}');
      print('  - level: ${_generatedPlan!['level']}');
      print('  - duration: ${_generatedPlan!['duration']}');
      print('  - 전체 데이터: ${_generatedPlan.toString()}');
      
      HapticFeedback.mediumImpact();
      
      final provider = Provider.of<LearningPlanProvider>(context, listen: false);
      
      // 학습 플랜 생성
      print('\n📝 Provider로 학습 플랜 생성 시도...');
      final success = await provider.createLearningPlan(
        goal: _generatedPlan!['goal']?.toString() ?? '',
        subject: _generatedPlan!['subject']?.toString() ?? '',
        level: _generatedPlan!['level']?.toString() ?? 'beginner',
        durationDays: (_generatedPlan!['duration'] is int) 
            ? _generatedPlan!['duration'] 
            : int.tryParse(_generatedPlan!['duration']?.toString() ?? '30') ?? 30,
        curriculum: _generatedPlan!['curriculum'] ?? {},
      );
      
      print('📊 학습 플랜 생성 결과: ${success ? '✅ 성공' : '❌ 실패'}');
      
      if (mounted) {
        if (success) {
          print('🏠 메인 화면으로 이동...');
          // 현재 화면을 닫고 이전 화면(홈 화면)으로 돌아감
          Navigator.of(context).pop();
          
          // 성공 메시지 표시
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ 학습 플랜이 성공적으로 생성되었습니다!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // 실패 메시지
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('학습 플랜 생성에 실패했습니다. 다시 시도해주세요.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('❌ _startLearningPlan() 예외 발생!');
      print('예외: $e');
      print('스택 추적: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      print('━' * 60);
      print('🏁 _startLearningPlan() 메서드 종료');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
                        ModernTheme.primaryColor,
                        ModernTheme.secondaryColor,
                      ],
                      transform: GradientRotation(_animationController.value * 3.14),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 20,
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            const Text(
              '스마트 학습 플래너',
              style: TextStyle(
                color: ModernTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 채팅 메시지 영역
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator();
                }
                
                final message = _messages[index];
                return _buildMessageBubble(message)
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.1, end: 0);
              },
            ),
          ),
          
          // 학습 시작 버튼 (플랜이 생성된 경우)
          if (_planGenerated && _generatedPlan != null)
            Material(
              elevation: 8,
              color: Colors.transparent,
              child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: ModernTheme.primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_planGenerated && _generatedPlan != null && !_isTyping) ? () {
                      print('\n🎯 [학습 시작하기] 버튼이 눌렸습니다!');
                      print('━' * 50);
                      print('📊 버튼 클릭 시 상태 체크:');
                      print('  - _planGenerated: $_planGenerated');
                      print('  - _generatedPlan != null: ${_generatedPlan != null}');
                      print('  - _isTyping: $_isTyping');
                      print('  - mounted: $mounted');
                      
                      if (_generatedPlan != null) {
                        print('  - 플랜 데이터 키들: ${_generatedPlan!.keys.toList()}');
                        print('  - 플랜 과목: ${_generatedPlan!['subject']}');
                        print('  - 플랜 목표: ${_generatedPlan!['goal']}');
                      }
                      print('━' * 50);
                      
                      if (!_isTyping && _planGenerated && _generatedPlan != null && mounted) {
                        print('✅ 모든 조건 만족 - _startLearningPlan() 실행');
                        _startLearningPlan();
                      } else {
                        print('❌ 조건 불만족 - 실행 중단');
                        if (_isTyping) print('  ↳ 아직 타이핑 중');
                        if (!_planGenerated) print('  ↳ 플랜이 생성되지 않음');
                        if (_generatedPlan == null) print('  ↳ 플랜 데이터가 null');
                        if (!mounted) print('  ↳ 위젯이 mounted되지 않음');
                      }
                    } : () {
                      print('\n⚠️ 버튼이 비활성 상태에서 눌림');
                      print('조건: _planGenerated($_planGenerated) && _generatedPlan!=null(${_generatedPlan != null}) && !_isTyping(!$_isTyping)');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ModernTheme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor: ModernTheme.primaryColor.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      tapTargetSize: MaterialTapTargetSize.padded,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rocket_launch, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          '학습 시작하기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ),
            ).animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
          
          // 입력 필드
          _buildInputField(),
        ],
      ),
    );
  }
  
  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: message.isUser 
            ? ModernTheme.primaryGradient
            : null,
          color: message.isUser ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(message.isUser ? 20 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 20),
          ),
          boxShadow: ModernTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      gradient: ModernTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'AI 플래너',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: ModernTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            if (!message.isUser) const SizedBox(height: 8),
            Text(
              message.text,
              style: TextStyle(
                fontSize: 14,
                color: message.isUser ? Colors.white : ModernTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: ModernTheme.cardShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                gradient: ModernTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome,
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
                      color: ModernTheme.primaryColor,
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
  
  Widget _buildInputField() {
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
                  color: ModernTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _processUserInput(),
                  decoration: InputDecoration(
                    hintText: '학습 목표를 자유롭게 입력하세요...',
                    hintStyle: const TextStyle(
                      color: ModernTheme.textLight,
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
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: ModernTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ModernTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _isTyping ? null : _processUserInput,
                icon: const Icon(
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
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  
  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}