import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/raw_korean_field.dart';

class TestKoreanInputScreen extends StatefulWidget {
  const TestKoreanInputScreen({super.key});

  @override
  State<TestKoreanInputScreen> createState() => _TestKoreanInputScreenState();
}

class _TestKoreanInputScreenState extends State<TestKoreanInputScreen> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  final TextEditingController _controller4 = TextEditingController();
  final TextEditingController _controller5 = TextEditingController();
  
  static const platform = MethodChannel('com.studymate/korean_input');
  String _imeStatus = 'Unknown';

  @override
  void initState() {
    super.initState();
    _checkIMEStatus();
  }
  
  Future<void> _checkIMEStatus() async {
    try {
      final String result = await platform.invokeMethod('checkIME');
      setState(() {
        _imeStatus = result;
      });
    } on PlatformException catch (e) {
      setState(() {
        _imeStatus = 'Error: ${e.message}';
      });
    }
  }
  
  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    _controller5.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('한글 입력 테스트'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              '다양한 TextField 설정 테스트',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // 1. 가장 기본적인 TextField
            TextField(
              controller: _controller1,
              decoration: const InputDecoration(
                labelText: '기본 TextField',
                hintText: '한글을 입력해보세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            
            // 2. keyboardType을 text로 명시
            TextField(
              controller: _controller2,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'TextInputType.text',
                hintText: '한글을 입력해보세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            
            // 3. multiline 설정
            TextField(
              controller: _controller3,
              keyboardType: TextInputType.multiline,
              maxLines: 1,
              decoration: const InputDecoration(
                labelText: 'TextInputType.multiline',
                hintText: '한글을 입력해보세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            
            // 4. emailAddress 타입에서도 한글 입력 테스트
            TextField(
              controller: _controller4,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'TextInputType.emailAddress',
                hintText: '한글@example.com',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            
            // 5. RawKoreanField 테스트
            RawKoreanField(
              controller: _controller5,
              labelText: 'RawKoreanField',
              hintText: '한글을 입력해보세요',
              prefixIcon: const Icon(Icons.keyboard),
            ),
            const SizedBox(height: 20),
            
            // IME 상태 표시
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('IME 상태:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(_imeStatus, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // 입력된 텍스트 표시
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('입력된 텍스트:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('1: ${_controller1.text}'),
                  Text('2: ${_controller2.text}'),
                  Text('3: ${_controller3.text}'),
                  Text('4: ${_controller4.text}'),
                  Text('5: ${_controller5.text}'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // 로그인 화면으로 이동
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('로그인 화면으로 돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}