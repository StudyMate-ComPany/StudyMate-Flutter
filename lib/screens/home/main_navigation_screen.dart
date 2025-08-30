import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../theme/studymate_theme.dart';
import '../../providers/auth_provider.dart';
import 'learning_dashboard.dart';
import '../study/quiz_screen.dart';
import '../study/pomodoro_timer_screen.dart';
import '../auth/login_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> 
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;

  final List<Widget> _screens = [
    const LearningDashboard(),
    const QuizScreen(subject: 'AI 생성 퀴즈'),
    const PomodoroTimerScreen(subject: '집중 학습'),
  ];

  final List<String> _titles = [
    'StudyMate',
    'AI 퀴즈',
    '포모도로',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // 학습 플래너(index 0) 접근 시 로그인 체크
    if (index == 0 && !authProvider.isAuthenticated) {
      _showLoginRequiredDialog();
      return;
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그인 필요'),
          content: const Text('학습 플래너를 사용하려면 로그인이 필요합니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text('로그인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('🏠 MainNavigationScreen build() 호출됨 - selectedIndex: $_selectedIndex');
    
    return Scaffold(
      backgroundColor: StudyMateTheme.lightBlue,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.all(8),
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
                    Icons.school,
                    color: Colors.white,
                    size: 20,
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            Text(
              _titles[_selectedIndex],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: StudyMateTheme.darkNavy,
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
                color: StudyMateTheme.accentPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: StudyMateTheme.primaryBlue,
                size: 20,
              ),
            ),
            onPressed: () {
              print('🔔 알림 버튼 클릭');
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: StudyMateTheme.accentPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.more_vert,
                color: StudyMateTheme.primaryBlue,
                size: 20,
              ),
            ),
            onPressed: () {
              print('📋 더보기 버튼 클릭');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
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
        child: SafeArea(
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_rounded,
                  label: '홈',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.quiz_rounded,
                  label: 'AI 퀴즈',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.timer_rounded,
                  label: '포모도로',
                  index: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
            ? StudyMateTheme.primaryBlue.withOpacity(0.1)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected 
                ? StudyMateTheme.primaryBlue 
                : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                  ? StudyMateTheme.primaryBlue 
                  : Colors.grey.shade400,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ).animate()
        .fadeIn(duration: 300.ms, delay: (index * 100).ms)
        .slideY(begin: 0.3, end: 0),
    );
  }
}