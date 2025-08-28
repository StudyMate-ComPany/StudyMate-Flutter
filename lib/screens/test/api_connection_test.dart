import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/logger.dart';

class ApiConnectionTest extends StatefulWidget {
  const ApiConnectionTest({super.key});

  @override
  State<ApiConnectionTest> createState() => _ApiConnectionTestState();
}

class _ApiConnectionTestState extends State<ApiConnectionTest> {
  final ApiService _apiService = ApiService();
  final List<TestResult> _testResults = [];
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

    // Test definitions
    final tests = [
      TestCase(
        name: '서버 연결 테스트',
        endpoint: '/',
        method: 'GET',
        requiresAuth: false,
        test: () => _apiService.testConnection(),
      ),
      TestCase(
        name: 'Health Check',
        endpoint: '/api/health/',
        method: 'GET',
        requiresAuth: false,
        test: () => _apiService.testHealth(),
      ),
      TestCase(
        name: '로그인 테스트',
        endpoint: '/api/auth/login/',
        method: 'POST',
        requiresAuth: false,
        test: () => _testLogin(),
      ),
      TestCase(
        name: '사용자 프로필',
        endpoint: '/api/user/profile/',
        method: 'GET',
        requiresAuth: true,
        test: () => _apiService.getCurrentUser().then((user) => user.toJson()),
      ),
      TestCase(
        name: '학습 목표 조회',
        endpoint: '/api/study/goals/',
        method: 'GET',
        requiresAuth: true,
        test: () => _apiService.getGoals().then((goals) => {'count': goals.length}),
      ),
      TestCase(
        name: '학습 세션 조회',
        endpoint: '/api/study/sessions/',
        method: 'GET',
        requiresAuth: true,
        test: () => _apiService.getSessions().then((sessions) => {'count': sessions.length}),
      ),
      TestCase(
        name: '통계 조회',
        endpoint: '/api/study/stats/overview/',
        method: 'GET',
        requiresAuth: true,
        test: () => _apiService.getStatistics(),
      ),
      TestCase(
        name: 'AI 채팅 테스트',
        endpoint: '/api/study/ai/chat/',
        method: 'POST',
        requiresAuth: true,
        test: () => _apiService.chatWithAI('테스트 메시지').then((response) => response.toJson()),
      ),
    ];

    // Run each test
    for (final test in tests) {
      setState(() {
        _currentTest = test.name;
      });

      final startTime = DateTime.now();
      TestResult result;

      try {
        // Setup auth if needed
        if (test.requiresAuth && !_hasAuth()) {
          await _setupTestAuth();
        }

        final response = await test.test();
        final duration = DateTime.now().difference(startTime);
        
        result = TestResult(
          name: test.name,
          endpoint: test.endpoint,
          method: test.method,
          success: true,
          responseTime: duration.inMilliseconds,
          response: response,
          requiresAuth: test.requiresAuth,
        );
        
        Logger.info('✅ ${test.name} 성공 (${duration.inMilliseconds}ms)');
      } catch (e) {
        final duration = DateTime.now().difference(startTime);
        
        result = TestResult(
          name: test.name,
          endpoint: test.endpoint,
          method: test.method,
          success: false,
          responseTime: duration.inMilliseconds,
          error: e.toString(),
          requiresAuth: test.requiresAuth,
        );
        
        Logger.error('❌ ${test.name} 실패', error: e);
      }

      setState(() {
        _testResults.add(result);
      });
      
      // Small delay between tests
      await Future.delayed(const Duration(milliseconds: 200));
    }

    setState(() {
      _isRunning = false;
      _currentTest = '';
    });
  }

  Future<Map<String, dynamic>> _testLogin() async {
    // Test with demo credentials
    final response = await _apiService.login('test@example.com', 'Test123!@#');
    if (response.containsKey('token')) {
      _apiService.setAuthToken(response['token']);
    }
    return response;
  }

  bool _hasAuth() {
    final authProvider = context.read<AuthProvider>();
    return authProvider.isAuthenticated;
  }

  Future<void> _setupTestAuth() async {
    try {
      // Try to login with test credentials
      await _testLogin();
    } catch (e) {
      Logger.warning('Test auth setup failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalTests = _testResults.length;
    final successfulTests = _testResults.where((r) => r.success).length;
    final failedTests = totalTests - successfulTests;
    final successRate = totalTests > 0 ? (successfulTests / totalTests * 100) : 0;
    final averageResponseTime = totalTests > 0
        ? _testResults.fold(0, (sum, r) => sum + r.responseTime) / totalTests
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('API 연결 테스트'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRunning ? null : _runAllTests,
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Card
          Container(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_isRunning)
                  Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 8),
                      Text('테스트 중: $_currentTest'),
                      const SizedBox(height: 16),
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatCard(
                      title: '성공률',
                      value: '${successRate.toStringAsFixed(1)}%',
                      color: successRate > 80 ? Colors.green : Colors.orange,
                    ),
                    _StatCard(
                      title: '성공',
                      value: '$successfulTests',
                      color: Colors.green,
                    ),
                    _StatCard(
                      title: '실패',
                      value: '$failedTests',
                      color: Colors.red,
                    ),
                    _StatCard(
                      title: '평균 응답',
                      value: '${averageResponseTime.toStringAsFixed(0)}ms',
                      color: Colors.blue,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Test Results List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _testResults.length,
              itemBuilder: (context, index) {
                final result = _testResults[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ExpansionTile(
                    leading: Icon(
                      result.success ? Icons.check_circle : Icons.error,
                      color: result.success ? Colors.green : Colors.red,
                    ),
                    title: Text(result.name),
                    subtitle: Text(
                      '${result.method} ${result.endpoint} • ${result.responseTime}ms',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (result.requiresAuth)
                          const Icon(Icons.lock, size: 16, color: Colors.orange),
                        const SizedBox(width: 8),
                        Icon(
                          result.success ? Icons.expand_more : Icons.expand_more,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result.success ? '응답 데이터:' : '오류 메시지:',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SelectableText(
                                result.success
                                    ? _formatJson(result.response ?? {})
                                    : result.error ?? 'Unknown error',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: result.success ? Colors.black87 : Colors.red[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatJson(Map<String, dynamic> json) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    } catch (e) {
      return json.toString();
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class TestCase {
  final String name;
  final String endpoint;
  final String method;
  final bool requiresAuth;
  final Future<Map<String, dynamic>> Function() test;

  TestCase({
    required this.name,
    required this.endpoint,
    required this.method,
    required this.requiresAuth,
    required this.test,
  });
}

class TestResult {
  final String name;
  final String endpoint;
  final String method;
  final bool success;
  final int responseTime;
  final Map<String, dynamic>? response;
  final String? error;
  final bool requiresAuth;

  TestResult({
    required this.name,
    required this.endpoint,
    required this.method,
    required this.success,
    required this.responseTime,
    this.response,
    this.error,
    required this.requiresAuth,
  });
}