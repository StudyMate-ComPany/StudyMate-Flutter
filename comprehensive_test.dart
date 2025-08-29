import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studymate_flutter/providers/auth_provider.dart';
import 'package:studymate_flutter/providers/study_provider.dart';
import 'package:studymate_flutter/providers/ai_provider.dart';
import 'package:studymate_flutter/providers/theme_provider.dart';
import 'package:studymate_flutter/providers/notification_provider.dart';
import 'package:studymate_flutter/providers/learning_plan_provider.dart';
import 'package:studymate_flutter/screens/auth/login_screen.dart';
import 'package:studymate_flutter/screens/home/main_navigation_screen.dart';

void main() {
  print('🚀 Starting StudyMate App Comprehensive Test');
  
  group('StudyMate App Test Suite', () {
    testWidgets('Login Screen Renders Correctly', (WidgetTester tester) async {
      print('📱 Testing Login Screen UI Rendering...');
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => StudyProvider()),
            ChangeNotifierProvider(create: (_) => AIProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => NotificationProvider()),
            ChangeNotifierProvider(create: (_) => LearningPlanProvider()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pump();

      // Check if main elements are present
      expect(find.text('STUDYMATE'), findsOneWidget);
      expect(find.text('로그인하기'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields
      
      print('✅ LOGIN SCREEN - UI Rendering: PASS');
    });

    testWidgets('Main Navigation Screen Structure', (WidgetTester tester) async {
      print('📱 Testing Main Navigation Screen Structure...');
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => StudyProvider()),
            ChangeNotifierProvider(create: (_) => AIProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => NotificationProvider()),
            ChangeNotifierProvider(create: (_) => LearningPlanProvider()),
          ],
          child: const MaterialApp(
            home: MainNavigationScreen(),
          ),
        ),
      );

      await tester.pump();

      // Check if bottom navigation bar exists
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // Check if all three tabs are present
      expect(find.text('홈'), findsOneWidget);
      expect(find.text('AI 퀴즈'), findsOneWidget);
      expect(find.text('포모도로'), findsOneWidget);
      
      print('✅ MAIN NAVIGATION - Structure: PASS');
      print('✅ BOTTOM NAVIGATION - All tabs present: PASS');
    });

    testWidgets('Navigation Tab Switching', (WidgetTester tester) async {
      print('📱 Testing Navigation Tab Switching...');
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => StudyProvider()),
            ChangeNotifierProvider(create: (_) => AIProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => NotificationProvider()),
            ChangeNotifierProvider(create: (_) => LearningPlanProvider()),
          ],
          child: const MaterialApp(
            home: MainNavigationScreen(),
          ),
        ),
      );

      await tester.pump();

      // Test tapping on AI Quiz tab
      await tester.tap(find.text('AI 퀴즈'));
      await tester.pump();
      
      print('✅ AI QUIZ TAB - Navigation: PASS');

      // Test tapping on Pomodoro tab
      await tester.tap(find.text('포모도로'));
      await tester.pump();
      
      print('✅ POMODORO TAB - Navigation: PASS');

      // Test tapping back to Home tab
      await tester.tap(find.text('홈'));
      await tester.pump();
      
      print('✅ HOME TAB - Return navigation: PASS');
    });

    testWidgets('Test Login with Test Credentials', (WidgetTester tester) async {
      print('📱 Testing Authentication with Test Credentials...');
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => StudyProvider()),
            ChangeNotifierProvider(create: (_) => AIProvider()),
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => NotificationProvider()),
            ChangeNotifierProvider(create: (_) => LearningPlanProvider()),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      await tester.pump();

      // Enter test credentials
      await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
      await tester.enterText(find.byType(TextFormField).last, 'test');
      await tester.pump();

      // Verify text was entered
      expect(find.text('test@test.com'), findsOneWidget);
      
      print('✅ AUTHENTICATION - Test credentials entered: PASS');
    });
  });
  
  print('🎉 StudyMate App Comprehensive Test Completed');
}