import 'package:flutter/material.dart';
import '../services/chatgpt_service.dart';
import 'dart:convert';

class TestChatGPTScreen extends StatefulWidget {
  const TestChatGPTScreen({Key? key}) : super(key: key);

  @override
  State<TestChatGPTScreen> createState() => _TestChatGPTScreenState();
}

class _TestChatGPTScreenState extends State<TestChatGPTScreen> {
  final TextEditingController _controller = TextEditingController();
  final ChatGPTService _chatGPTService = ChatGPTService();
  String _response = '';
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _controller.text = 'koreahistory first grade three year'; // 테스트 입력
  }
  
  Future<void> _testChatGPT() async {
    if (_controller.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _response = '';
    });
    
    try {
      print('🚀 ChatGPT 직접 호출 테스트 시작...');
      print('입력: ${_controller.text}');
      
      // ChatGPT 직접 호출
      final result = await _chatGPTService.analyzeUserInput(_controller.text);
      
      print('📡 응답 받음: $result');
      
      if (result['success'] == true) {
        final analysis = result['analysis'];
        setState(() {
          _response = '''
✅ AI 응답 성공!

📚 과목: ${analysis['subject']}
🎯 목표: ${analysis['goal']}
📅 기간: ${analysis['daysAvailable']}일
📊 수준: ${analysis['currentLevel']}
🏷️ 유형: ${analysis['studyType']}

원본 JSON:
${const JsonEncoder.withIndent('  ').convert(analysis)}
''';
        });
        
        // 모의 응답 사용 여부 확인
        if (result['usingMock'] == true) {
          setState(() {
            _response = '⚠️ 모의 응답 사용됨 (API 호출 실패)\n\n$_response';
          });
        }
      } else {
        setState(() {
          _response = '❌ 에러: ${result['error']}';
        });
      }
    } catch (e) {
      print('❌ 예외 발생: $e');
      setState(() {
        _response = '❌ 예외 발생: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 직접 테스트'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI 직접 호출 테스트',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '이 화면은 백엔드 서버를 거치지 않고 AI를 직접 호출합니다.',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        labelText: '학습 요청 입력',
                        hintText: 'ex: toeic 900 point two month',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _testChatGPT,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('AI 테스트'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '응답 결과:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          _response.isEmpty ? '여기에 결과가 표시됩니다...' : _response,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            color: _response.isEmpty ? Colors.grey : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}