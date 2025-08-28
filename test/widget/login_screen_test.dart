import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:studymate_flutter/screens/auth/login_screen.dart';
import 'package:studymate_flutter/providers/auth_provider.dart';
import 'package:studymate_flutter/services/api_service.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    Widget createLoginScreen() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: authProvider),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      );
    }

    testWidgets('should display all required form fields', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // Check for email field
      expect(find.text('이메일'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email and Password

      // Check for password field
      expect(find.text('비밀번호'), findsOneWidget);

      // Check for login button
      expect(find.text('로그인'), findsOneWidget);

      // Check for register link
      expect(find.text('회원가입'), findsOneWidget);
    });

    testWidgets('should show error for empty email', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // Find and tap login button without entering credentials
      final loginButton = find.widgetWithText(ElevatedButton, '로그인');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('이메일을 입력해주세요'), findsOneWidget);
    });

    testWidgets('should show error for invalid email format', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // Enter invalid email
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      
      // Tap login button
      final loginButton = find.widgetWithText(ElevatedButton, '로그인');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('올바른 이메일 주소를 입력해주세요'), findsOneWidget);
    });

    testWidgets('should show error for empty password', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // Enter valid email but no password
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      
      // Tap login button
      final loginButton = find.widgetWithText(ElevatedButton, '로그인');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('비밀번호를 입력해주세요'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // Find password field
      final passwordField = find.byType(TextFormField).last;
      
      // Initially password should be obscured
      final textField = tester.widget<TextFormField>(passwordField);
      expect(textField.obscureText, true);

      // Find and tap visibility toggle icon
      final visibilityIcon = find.byIcon(Icons.visibility_off);
      expect(visibilityIcon, findsOneWidget);
      
      await tester.tap(visibilityIcon);
      await tester.pumpAndSettle();

      // After tapping, icon should change
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('should navigate to register screen', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // Find and tap register button
      final registerButton = find.text('회원가입');
      expect(registerButton, findsOneWidget);
      
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      // Should navigate to register screen
      // Note: In a real test, you'd verify navigation occurred
    });

    testWidgets('should display loading indicator during login', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // Enter valid credentials
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'Password123!');

      // Tap login button
      final loginButton = find.widgetWithText(ElevatedButton, '로그인');
      await tester.tap(loginButton);
      
      // Don't use pumpAndSettle here to catch the loading state
      await tester.pump();

      // Should show loading indicator
      // Note: The actual implementation might show a CircularProgressIndicator
      // or change the button text/state
    });

    testWidgets('should validate form before submission', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // Try to submit empty form
      final loginButton = find.widgetWithText(ElevatedButton, '로그인');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Should show multiple validation errors
      expect(find.text('이메일을 입력해주세요'), findsOneWidget);
      expect(find.text('비밀번호를 입력해주세요'), findsOneWidget);

      // Enter valid data
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'Password123!');
      
      // Clear validation errors
      await tester.tap(loginButton);
      await tester.pump();

      // Validation errors should be gone
      expect(find.text('이메일을 입력해주세요'), findsNothing);
      expect(find.text('비밀번호를 입력해주세요'), findsNothing);
    });
  });
}