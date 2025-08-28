import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Load .env file
  await dotenv.load(fileName: ".env");
  
  final apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  print('API Key loaded: ${apiKey.isNotEmpty ? "YES (${apiKey.substring(0, 20)}...)" : "NO"}');
  
  if (apiKey.isEmpty) {
    print('ERROR: No API key found');
    return;
  }
  
  final dio = Dio();
  
  try {
    print('Calling ChatGPT API...');
    final response = await dio.post(
      'https://api.openai.com/v1/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'user',
            'content': 'Analyze: "koreahistory first grade three year" and extract subject, goal, and duration in JSON format',
          },
        ],
        'temperature': 0.7,
        'max_completion_tokens': 200,
      },
    );
    
    print('Success! Response:');
    print(response.data);
  } catch (e) {
    print('Error calling API: $e');
    if (e is DioError) {
      print('Response: ${e.response?.data}');
    }
  }
}
