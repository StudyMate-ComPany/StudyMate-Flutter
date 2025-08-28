import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/study_provider.dart';
import '../../providers/ai_provider.dart';
import '../../theme/modern_theme.dart';
import '../../widgets/common/loading_overlay.dart';
import '../study/modern_study_goals_screen.dart';
import '../study/modern_study_session_screen.dart';
import '../study/modern_ai_assistant_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import 'modern_dashboard.dart';
import 'goals_tab.dart';
import 'sessions_tab.dart';
import 'ai_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late TabController _tabController;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final studyProvider = Provider.of<StudyProvider>(context, listen: false);
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    
    // Short delay to ensure auth token is set
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Initialize providers with auth
    await studyProvider.initializeWithAuth();
    
    try {
      await Future.wait([
        studyProvider.loadGoals(),
        studyProvider.loadSessions(),
        aiProvider.loadHistory(limit: 10),
      ]);
    } catch (e) {
      debugPrint('Failed to load initial data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, StudyProvider, AIProvider>(
      builder: (context, authProvider, studyProvider, aiProvider, child) {
        return Scaffold(
          backgroundColor: ModernTheme.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: ModernTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '스터디메이트',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ModernTheme.primaryColor,
                  ),
                ),
              ],
            ).animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.3, end: 0),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ModernTheme.secondaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: ModernTheme.primaryColor,
                    size: 20,
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('알림 기능이 곧 추가됩니다! 🔔'),
                      backgroundColor: ModernTheme.primaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              ).animate()
                .fadeIn(delay: 200.ms)
                .scale(),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  switch (value) {
                    case 'profile':
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ProfileScreen()),
                      );
                      break;
                    case 'settings':
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                      break;
                    case 'logout':
                      await authProvider.logout();
                      break;
                  }
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ModernTheme.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    color: ModernTheme.primaryColor,
                    size: 20,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.person, color: ModernTheme.primaryColor),
                      title: Text('프로필'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings, color: ModernTheme.primaryColor),
                      title: Text('설정'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout, color: ModernTheme.errorColor),
                      title: Text('로그아웃', style: TextStyle(color: ModernTheme.errorColor)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ).animate()
                .fadeIn(delay: 400.ms)
                .scale(),
            ],
          ),
          body: LoadingOverlay(
            isLoading: studyProvider.state == StudyState.loading && 
                      studyProvider.goals.isEmpty && 
                      studyProvider.sessions.isEmpty,
            loadingText: '학습 데이터를 불러오는 중...',
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                ModernDashboard(),
                GoalsTab(),
                SessionsTab(),
                AITab(),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                  _tabController.animateTo(index);
                });
                _fabAnimationController.forward().then((_) {
                  _fabAnimationController.reverse();
                });
              },
              selectedItemColor: ModernTheme.primaryColor,
              unselectedItemColor: Colors.grey,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11,
              ),
              items: [
                _buildBottomNavItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: '대시보드',
                  index: 0,
                ),
                _buildBottomNavItem(
                  icon: Icons.flag_outlined,
                  activeIcon: Icons.flag,
                  label: '학습목표',
                  index: 1,
                ),
                _buildBottomNavItem(
                  icon: Icons.timer_outlined,
                  activeIcon: Icons.timer,
                  label: '학습세션',
                  index: 2,
                ),
                _buildBottomNavItem(
                  icon: Icons.smart_toy_outlined,
                  activeIcon: Icons.smart_toy,
                  label: 'AI 도우미',
                  index: 3,
                ),
              ],
            ),
          ),
          floatingActionButton: _buildFloatingActionButton(),
        );
      },
    );
  }

  BottomNavigationBarItem _buildBottomNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(isSelected ? 8 : 4),
        decoration: BoxDecoration(
          color: isSelected ? ModernTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          size: isSelected ? 26 : 24,
        ),
      ),
      label: label,
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_currentIndex == 1) {
      // 학습목표 탭
      return AnimatedBuilder(
        animation: _fabAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_fabAnimationController.value * 0.1),
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ModernStudyGoalsScreen(),
                  ),
                );
              },
              backgroundColor: ModernTheme.primaryColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                '목표 추가',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ).animate()
        .fadeIn(duration: 300.ms)
        .scale(delay: 100.ms);
    } else if (_currentIndex == 2) {
      // 학습세션 탭
      return AnimatedBuilder(
        animation: _fabAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_fabAnimationController.value * 0.1),
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ModernStudySessionScreen(),
                  ),
                );
              },
              backgroundColor: ModernTheme.secondaryColor,
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const Text(
                '학습 시작',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ).animate()
        .fadeIn(duration: 300.ms)
        .scale(delay: 100.ms);
    } else if (_currentIndex == 3) {
      // AI 도우미 탭
      return AnimatedBuilder(
        animation: _fabAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_fabAnimationController.value * 0.1),
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ModernAIAssistantScreen(),
                  ),
                );
              },
              backgroundColor: ModernTheme.accentColor,
              icon: const Icon(Icons.chat, color: Colors.white),
              label: const Text(
                'AI와 대화',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ).animate()
        .fadeIn(duration: 300.ms)
        .scale(delay: 100.ms);
    }
    return null;
  }
}