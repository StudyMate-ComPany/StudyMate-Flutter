import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/api_service.dart';
import '../test/api_test_screen.dart';
import '../test/korean_input_test_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ApiService _apiService = ApiService();

  Future<void> _testAllEndpoints() async {
    final endpoints = [
      {'name': '연결 테스트', 'endpoint': '/'},
      {'name': 'POST 테스트', 'endpoint': '/test'},
      {'name': '인증 로그인', 'endpoint': '/auth/login'},
      {'name': '목표 가져오기', 'endpoint': '/goals'},
      {'name': '세션 가져오기', 'endpoint': '/sessions'},
      {'name': 'AI 질문', 'endpoint': '/ai/ask'},
      {'name': '통계 가져오기', 'endpoint': '/stats'},
      {'name': '대시보드', 'endpoint': '/dashboard'},
    ];

    for (final endpoint in endpoints) {
      try {
        Map<String, dynamic> response;
        
        switch (endpoint['endpoint']) {
          case '/':
            response = await _apiService.testConnection();
            break;
          case '/test':
            response = await _apiService.testPost({'test': 'data'});
            break;
          default:
            // Skip endpoints that require authentication for now
            response = {'status': '건너뜀', 'reason': '인증 필요'};
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${endpoint['name']}: 성공 - ${response.toString()}'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${endpoint['name']}: 오류 - $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
      
      // Small delay between requests
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('설정'),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // API Testing Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'API 엔드포인트 테스트',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Server: https://54.161.77.144',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Individual Test Buttons
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ApiTestScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.bug_report, size: 16),
                            label: const Text('상세 API 테스트'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const KoreanInputTestScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.keyboard, size: 16),
                            label: const Text('한글 입력 테스트'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                final response = await _apiService.testConnection();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('연결: ${response.toString()}'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('연결 오류: $e'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.wifi_tethering, size: 16),
                            label: const Text('연결 테스트'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                final response = await _apiService.testPost({
                                  'message': 'Flutter 앱에서 테스트',
                                  'timestamp': DateTime.now().toIso8601String(),
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('POST 테스트: ${response.toString()}'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('POST 오류: $e'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.upload, size: 16),
                            label: const Text('POST 테스트'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                final response = await _apiService.getStudyGoals();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('목표: ${response.length}개 발견'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('목표 오류: $e'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.flag, size: 16),
                            label: const Text('목표 테스트'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                final response = await _apiService.getStudySessions();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('세션: ${response.length}개 발견'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('세션 오류: $e'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.timer, size: 16),
                            label: const Text('세션 테스트'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                final response = await _apiService.askAI('안녕하세요, 테스트 쿼리입니다');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('AI 응답: ${response.response.substring(0, 50)}...'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('AI 오류: $e'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.psychology, size: 16),
                            label: const Text('AI 테스트'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                final response = await _apiService.getStudyStatistics();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('통계: ${response.keys.length}개 지표'),
                                    backgroundColor: Colors.green,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('통계 오류: $e'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.analytics, size: 16),
                            label: const Text('통계 테스트'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Test All Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _testAllEndpoints,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('모든 엔드포인트 테스트'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // App Settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '앱 설정',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Consumer<NotificationProvider>(
                        builder: (context, notificationProvider, child) {
                          return ListTile(
                            leading: const Icon(Icons.notifications),
                            title: const Text('알림'),
                            subtitle: const Text('학습 알림 관리'),
                            trailing: Switch(
                              value: notificationProvider.notificationsEnabled,
                              onChanged: (value) async {
                                final success = await notificationProvider.toggleNotifications();
                                if (!success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('알림 권한이 필요합니다'),
                                      action: SnackBarAction(
                                        label: '설정',
                                        onPressed: () {
                                          notificationProvider.openSettings();
                                        },
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                      
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, child) {
                          return ListTile(
                            leading: const Icon(Icons.dark_mode),
                            title: const Text('다크 모드'),
                            subtitle: const Text('다크 테마 전환'),
                            trailing: Switch(
                              value: themeProvider.isDarkMode,
                              onChanged: (value) {
                                themeProvider.toggleTheme();
                              },
                            ),
                          );
                        },
                      ),
                      
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: const Text('언어'),
                        subtitle: const Text('한국어'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // 언어 선택 구현 예정
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Account Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '계정',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      ListTile(
                        leading: const Icon(Icons.info),
                        title: const Text('정보'),
                        subtitle: const Text('버전 1.0.0'),
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: '스터디메이트',
                            applicationVersion: '1.0.0',
                            applicationIcon: const Icon(Icons.school),
                            children: const [
                              Text('스마트 학습 도우미로 학습 목표 달성을 도와드립니다.'),
                            ],
                          );
                        },
                      ),
                      
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.red),
                        title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
                        onTap: () async {
                          final shouldLogout = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('로그아웃'),
                              content: const Text('정말 로그아웃 하시겠습니까?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('취소'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('로그아웃'),
                                ),
                              ],
                            ),
                          );
                          
                          if (shouldLogout == true) {
                            await authProvider.logout();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}