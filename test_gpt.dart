import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'lib/services/chatgpt_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file
  await dotenv.load(fileName: ".env");
  
  print('Testing ChatGPT Service...');
  print('OPENAI_API_KEY: ${dotenv.env['OPENAI_API_KEY']?.substring(0, 30)}...');
  
  final service = ChatGPTService();
  
  // Test analyzeUserInput
  print('\n--- Testing analyzeUserInput ---');
  final result = await service.analyzeUserInput('koreahistory first grade three year');
  print('Result: $result');
  
  // Test generateAdaptiveStudyPlan
  print('\n--- Testing generateAdaptiveStudyPlan ---');
  final planResult = await service.generateAdaptiveStudyPlan('toeic 900 point two month');
  print('Plan Result: $planResult');
}