import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_provider.dart';
import '../../services/api_service.dart';
import '../../models/ai_response.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _testAIEndpoint() async {
    try {
      final response = await _apiService.testConnection();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('서버 응답: ${response.toString()}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AIProvider>(
      builder: (context, aiProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('AI 도우미'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.wifi_tethering),
                onPressed: _testAIEndpoint,
                tooltip: '서버 연결 테스트',
              ),
            ],
          ),
          body: Column(
            children: [
              // Test Buttons Section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API 테스트 버튼',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _testAIEndpoint,
                          icon: const Icon(Icons.cloud, size: 16),
                          label: const Text('연결 테스트'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await aiProvider.askQuestion(
                              '수학 학습 계획을 만들어주세요',
                              type: AIResponseType.studyPlan,
                            );
                          },
                          icon: const Icon(Icons.schedule, size: 16),
                          label: const Text('학습 계획 테스트'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await aiProvider.generateQuiz(
                              subject: '물리학',
                              questionCount: 5,
                            );
                          },
                          icon: const Icon(Icons.quiz, size: 16),
                          label: const Text('퀴즈 테스트'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await aiProvider.explainConcept(
                              concept: '광합성',
                              subject: '생물학',
                            );
                          },
                          icon: const Icon(Icons.lightbulb, size: 16),
                          label: const Text('설명 테스트'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Chat Interface
              Expanded(
                child: Column(
                  children: [
                    // Messages List
                    Expanded(
                      child: aiProvider.history.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.psychology_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    '학습에 대해 무엇이든 물어보세요!',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '학습 계획, 설명, 퀴즈를 요청해보세요',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: aiProvider.history.length,
                              reverse: true,
                              itemBuilder: (context, index) {
                                final response = aiProvider.history[index];
                                return Column(
                                  children: [
                                    // User Message
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          response.query,
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    // AI Response
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(response.response),
                                            if (response.confidence != null) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                '신뢰도: ${(response.confidence! * 100).toStringAsFixed(1)}%',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                    
                    // Loading Indicator
                    if (aiProvider.state == AIState.loading)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(width: 16),
                            Text('AI가 생각 중입니다...'),
                          ],
                        ),
                      ),
                    
                    // Input Area
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: '학습에 대해 무엇이든 물어보세요...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              textInputAction: TextInputAction.send,
                              onSubmitted: (message) => _sendMessage(aiProvider),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FloatingActionButton(
                            onPressed: () => _sendMessage(aiProvider),
                            mini: true,
                            child: const Icon(Icons.send),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendMessage(AIProvider aiProvider) async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    
    await aiProvider.askQuestion(message);
    
    // Scroll to bottom
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}