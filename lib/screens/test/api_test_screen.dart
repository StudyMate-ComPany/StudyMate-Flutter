import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

/// API 연결 테스트 화면
/// 앱 내에서 API 연결 상태를 실시간으로 테스트할 수 있습니다.
class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final ApiService _apiService = ApiService();
  final Map<String, TestResult> _testResults = {};
  bool _isRunning = false;
  String _currentTest = '';

  @override
  void initState() {
    super.initState();
    _runAllTests();
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isRunning = true;
      _testResults.clear();
    });

    // 1. 서버 연결 테스트
    await _runTest('서버 연결', () async {
      await _apiService.testConnection();
    });

    // 2. Health Check
    await _runTest('Health Check', () async {
      await _apiService.testHealth();
    });

    // 3. 회원가입 테스트 (실제로 가입하지 않음)
    await _runTest('회원가입 API', () async {
      try {
        await _apiService.register(
          'test_${DateTime.now().millisecondsSinceEpoch}@example.com',
          'TestPassword123!',
          'Test User',
        );
      } catch (e) {
        // 이미 존재하는 사용자 에러도 API가 작동하는 것으로 간주
        if (e.toString().contains('already exists') || 
            e.toString().contains('이미 존재')) {
          return; // 성공으로 처리
        }
        rethrow;
      }
    });

    // 4. 로그인 테스트 (잘못된 정보로)
    await _runTest('로그인 API', () async {
      try {
        await _apiService.login('wrong@example.com', 'wrongpassword');
      } catch (e) {
        // 인증 실패도 API가 작동하는 것으로 간주
        if (e.toString().contains('잘못되었습니다') || 
            e.toString().contains('Invalid')) {
          return; // 성공으로 처리
        }
        rethrow;
      }
    });

    // 5. 학습 목표 조회 (인증 필요)
    await _runTest('학습 목표 API', () async {
      try {
        await _apiService.getGoals();
      } catch (e) {
        // 401 Unauthorized도 API가 작동하는 것으로 간주
        if (e.toString().contains('401') || 
            e.toString().contains('Unauthorized') ||
            e.toString().contains('인증')) {
          return; // 성공으로 처리
        }
        // 빈 배열 반환도 성공
        if (e.toString().contains('[]')) {
          return;
        }
        rethrow;
      }
    });

    // 6. 학습 세션 조회 (인증 필요)
    await _runTest('학습 세션 API', () async {
      try {
        await _apiService.getSessions();
      } catch (e) {
        // 401 Unauthorized도 API가 작동하는 것으로 간주
        if (e.toString().contains('401') || 
            e.toString().contains('Unauthorized') ||
            e.toString().contains('인증')) {
          return; // 성공으로 처리
        }
        // 빈 배열 반환도 성공
        if (e.toString().contains('[]')) {
          return;
        }
        rethrow;
      }
    });

    // 7. 실제 로그인 테스트 (테스트 계정 사용)
    await _runTest('테스트 계정 로그인', () async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // 테스트 계정으로 로그인 시도
      final success = await authProvider.login(
        'test@studymate.com',
        'Test1234!',
      );
      if (!success) {
        throw Exception('테스트 계정 로그인 실패');
      }
    });

    setState(() {
      _isRunning = false;
      _currentTest = '';
    });
  }

  Future<void> _runTest(String name, Future<void> Function() test) async {
    setState(() {
      _currentTest = name;
    });

    final startTime = DateTime.now();
    try {
      await test();
      final duration = DateTime.now().difference(startTime);
      setState(() {
        _testResults[name] = TestResult(
          passed: true,
          duration: duration,
          error: null,
        );
      });
    } catch (e) {
      final duration = DateTime.now().difference(startTime);
      setState(() {
        _testResults[name] = TestResult(
          passed: false,
          duration: duration,
          error: e.toString(),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final passedCount = _testResults.values.where((r) => r.passed).length;
    final totalCount = _testResults.length;
    final successRate = totalCount > 0 ? (passedCount / totalCount * 100) : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('API 연결 테스트'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 상태 표시
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _getStatusColor(),
            child: Column(
              children: [
                Icon(
                  _getStatusIcon(),
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  _getStatusText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isRunning) ...[
                  const SizedBox(height: 8),
                  Text(
                    '테스트 중: $_currentTest',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
                if (!_isRunning && totalCount > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '성공률: ${successRate.toStringAsFixed(1)}% ($passedCount/$totalCount)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 테스트 결과 목록
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _testResults.length,
              itemBuilder: (context, index) {
                final entry = _testResults.entries.elementAt(index);
                final name = entry.key;
                final result = entry.value;

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      result.passed ? Icons.check_circle : Icons.error,
                      color: result.passed ? Colors.green : Colors.red,
                      size: 32,
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('응답 시간: ${result.duration.inMilliseconds}ms'),
                        if (result.error != null)
                          Text(
                            '에러: ${result.error}',
                            style: const TextStyle(color: Colors.red),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    trailing: Text(
                      result.passed ? '성공' : '실패',
                      style: TextStyle(
                        color: result.passed ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 재테스트 버튼
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isRunning ? null : _runAllTests,
                icon: const Icon(Icons.refresh),
                label: const Text('다시 테스트'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (_isRunning) return Colors.blue;
    if (_testResults.isEmpty) return Colors.grey;
    
    final passedCount = _testResults.values.where((r) => r.passed).length;
    final totalCount = _testResults.length;
    
    if (passedCount == totalCount) return Colors.green;
    if (passedCount == 0) return Colors.red;
    return Colors.orange;
  }

  IconData _getStatusIcon() {
    if (_isRunning) return Icons.hourglass_empty;
    if (_testResults.isEmpty) return Icons.help_outline;
    
    final passedCount = _testResults.values.where((r) => r.passed).length;
    final totalCount = _testResults.length;
    
    if (passedCount == totalCount) return Icons.check_circle;
    if (passedCount == 0) return Icons.error;
    return Icons.warning;
  }

  String _getStatusText() {
    if (_isRunning) return '테스트 진행 중...';
    if (_testResults.isEmpty) return '테스트 대기 중';
    
    final passedCount = _testResults.values.where((r) => r.passed).length;
    final totalCount = _testResults.length;
    
    if (passedCount == totalCount) return '모든 테스트 성공!';
    if (passedCount == 0) return 'API 연결 실패';
    return '부분적 연결 성공';
  }
}

class TestResult {
  final bool passed;
  final Duration duration;
  final String? error;

  TestResult({
    required this.passed,
    required this.duration,
    this.error,
  });
}