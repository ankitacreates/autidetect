import 'package:flutter_dotenv/flutter_dotenv.dart';

// This is a placeholder for your Gemini API key
// In a production app, you should use secure methods to store API keys
// like environment variables, flutter_dotenv, or a backend service
class ApiKeys {
  // Get Gemini API key from environment variables
  static String get geminiApiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in environment variables');
    }
    return key;
  }
} 