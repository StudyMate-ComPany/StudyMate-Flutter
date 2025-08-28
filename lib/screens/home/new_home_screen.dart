import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/learning_plan_provider.dart';
import '../../theme/modern_theme.dart';
import '../learning/ai_learning_setup_screen.dart';
import 'learning_dashboard.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../subscription/subscription_screen.dart';
import '../test_chatgpt_screen.dart';

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
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
                  padding: const EdgeInsets.all(8),
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
                    Icons.school,
                    color: Colors.white,
                    size: 20,
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            const Text(
              'StudyMate',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: ModernTheme.textPrimary,
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
                color: ModernTheme.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: ModernTheme.primaryColor,
                size: 20,
              ),
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('알림이 설정되어 있습니다 (9시, 12시, 21시) 🔔'),
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
                case 'new_plan':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AILearningSetupScreen(),
                    ),
                  );
                  break;
                case 'subscription':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionScreen(),
                    ),
                  );
                  break;
                case 'profile':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                  break;
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                  break;
                case 'test_chatgpt':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TestChatGPTScreen(),
                    ),
                  );
                  break;
                case 'logout':
                  final authProvider = Provider.of<AuthProvider>(context, listen: false);
                  await authProvider.logout();
                  break;
              }
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ModernTheme.accentColor.withOpacity(0.1),
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
                value: 'new_plan',
                child: ListTile(
                  leading: Icon(Icons.add, color: ModernTheme.primaryColor),
                  title: Text('새 학습 플랜'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'subscription',
                child: ListTile(
                  leading: Icon(Icons.workspace_premium, color: ModernTheme.accentColor),
                  title: Text('프리미엄 구독'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
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
                value: 'test_chatgpt',
                child: ListTile(
                  leading: Icon(Icons.science, color: Colors.blue),
                  title: Text('AI 테스트'),
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
      body: const LearningDashboard(),
      floatingActionButton: Consumer<LearningPlanProvider>(
        builder: (context, provider, child) {
          if (provider.activePlan != null) {
            return FloatingActionButton.extended(
              onPressed: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AILearningSetupScreen(),
                  ),
                );
              },
              backgroundColor: ModernTheme.primaryColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                '새 플랜',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ).animate()
              .fadeIn(duration: 300.ms)
              .scale(delay: 100.ms);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}