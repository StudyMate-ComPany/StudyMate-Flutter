// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:studymate/main.dart';
import 'package:studymate/providers/auth_provider.dart';
import 'package:studymate/providers/study_provider.dart';
import 'package:studymate/providers/ai_provider.dart';

void main() {
  testWidgets('스터디메이트 앱 스모크 테스트', (WidgetTester tester) async {
    // 앱 빌드 및 프레임 트리거
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => StudyProvider()),
          ChangeNotifierProvider(create: (_) => AIProvider()),
        ],
        child: const StudyMateApp(),
      ),
    );

    // 로그인 화면이 로드되는지 확인
    expect(find.text('스터디메이트'), findsOneWidget);
    expect(find.text('AI 기반 학습 도우미'), findsOneWidget);
  });
}
