import 'package:flutter/material.dart';
import '../../widgets/korean_text_field.dart';
import '../../theme/app_theme.dart';

/// 한글 입력 테스트 화면
class KoreanInputTestScreen extends StatefulWidget {
  const KoreanInputTestScreen({super.key});

  @override
  State<KoreanInputTestScreen> createState() => _KoreanInputTestScreenState();
}

class _KoreanInputTestScreenState extends State<KoreanInputTestScreen> {
  final TextEditingController _testController1 = TextEditingController();
  final TextEditingController _testController2 = TextEditingController();
  final TextEditingController _testController3 = TextEditingController();
  final TextEditingController _normalController = TextEditingController();
  
  String _inputText1 = '';
  String _inputText2 = '';
  String _inputText3 = '';
  String _normalText = '';

  @override
  void initState() {
    super.initState();
    _testController1.addListener(() {
      setState(() {
        _inputText1 = _testController1.text;
      });
    });
    _testController2.addListener(() {
      setState(() {
        _inputText2 = _testController2.text;
      });
    });
    _testController3.addListener(() {
      setState(() {
        _inputText3 = _testController3.text;
      });
    });
    _normalController.addListener(() {
      setState(() {
        _normalText = _normalController.text;
      });
    });
  }

  @override
  void dispose() {
    _testController1.dispose();
    _testController2.dispose();
    _testController3.dispose();
    _normalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('한글 입력 테스트'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 테스트 안내
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.primaryColor),
                      SizedBox(width: 8),
                      Text(
                        '한글 입력 테스트',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '아래 필드에 한글을 입력해보세요.\n"안녕하세요", "테스트", "가나다라" 등을 입력해보고 중복 입력이 발생하는지 확인하세요.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // KoreanTextField 테스트 1
            const Text(
              '1. KoreanTextField (이메일 타입)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            KoreanTextField(
              controller: _testController1,
              labelText: '이메일',
              hintText: '한글을 입력해보세요',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.email),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '입력된 텍스트: "$_inputText1" (${_inputText1.length}자)',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // KoreanTextField 테스트 2
            const Text(
              '2. KoreanTextField (일반 텍스트)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            KoreanTextField(
              controller: _testController2,
              labelText: '이름',
              hintText: '이름을 입력하세요',
              prefixIcon: const Icon(Icons.person),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '입력된 텍스트: "$_inputText2" (${_inputText2.length}자)',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // KoreanTextField 테스트 3 (여러 줄)
            const Text(
              '3. KoreanTextField (여러 줄)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            KoreanTextField(
              controller: _testController3,
              labelText: '메모',
              hintText: '여러 줄의 한글을 입력해보세요',
              maxLines: 3,
              prefixIcon: const Icon(Icons.note),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '입력된 텍스트: "$_inputText3" (${_inputText3.length}자)',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 일반 TextField (비교용)
            const Text(
              '4. 일반 TextField (비교용)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _normalController,
              decoration: InputDecoration(
                labelText: '일반 TextField',
                hintText: '한글 입력 시 중복이 발생할 수 있습니다',
                prefixIcon: const Icon(Icons.warning, color: Colors.orange),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '입력된 텍스트: "$_normalText" (${_normalText.length}자)',
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 테스트 결과
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        '테스트 가이드',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('✅ KoreanTextField는 한글 중복 입력을 방지합니다'),
                  const Text('✅ 자음과 모음 조합 시 정상 작동합니다'),
                  const Text('✅ 영문, 숫자, 특수문자도 정상 입력됩니다'),
                  const Text('❌ 일반 TextField는 한글 입력 시 중복이 발생할 수 있습니다'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 초기화 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _testController1.clear();
                  _testController2.clear();
                  _testController3.clear();
                  _normalController.clear();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('모든 필드 초기화'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}