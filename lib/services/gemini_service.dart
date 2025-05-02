import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:autidetect/utils/api_keys.dart';
import 'package:autidetect/models/chat_message_model.dart';

class GeminiService {
  final String _apiKey = ApiKeys.geminiApiKey;
  final String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  final List<Map<String, dynamic>> _chatHistory = [];
  final String _systemPrompt = 'You are AutiHelp, an assistant in an autism detection app. You help parents understand autism, developmental milestones, and provide support. Be friendly, clear, and compassionate. Avoid technical jargon unless explaining a specific concept. Keep responses concise but informative.';
  bool _isInitialized = false;

  GeminiService();

  Future<String> sendMessage(String message) async {
    try {
      // If this is the first message, prepend the system prompt
      if (!_isInitialized) {
        final combinedMessage = "$_systemPrompt\n\nUser query: $message";
        _chatHistory.add({
          "role": "user",
          "parts": [{"text": combinedMessage}]
        });
        _isInitialized = true;
      } else {
        // Add user message to history
        _chatHistory.add({
          "role": "user",
          "parts": [{"text": message}]
        });
      }

      // Prepare the request payload - Gemini 2.0 format
      final payload = {
        "contents": _chatHistory,
      };

      // Make HTTP request to Gemini API
      final url = '$_baseUrl?key=$_apiKey';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final assistantMessage = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Add assistant response to history
        _chatHistory.add({
          "role": "model",
          "parts": [{"text": assistantMessage}]
        });
        
        return assistantMessage;
      } else {
        print('Error: ${response.statusCode} ${response.body}');
        return 'Error: Unable to get a response. Status code: ${response.statusCode}';
      }
    } catch (e) {
      print('Exception occurred: $e');
      return 'Error: $e. Please try again.';
    }
  }

  List<ChatMessage> getChatHistory() {
    return _chatHistory.map((message) {
      final role = message['role'] == 'user' ? MessageRole.user : MessageRole.assistant;
      final text = message['parts'][0]['text'];
      
      // For the first user message that includes system prompt, only show the actual user query
      if (role == MessageRole.user && _chatHistory.indexOf(message) == 0 && _isInitialized) {
        final fullText = text;
        final userQueryIndex = fullText.indexOf("User query:");
        if (userQueryIndex > -1) {
          return ChatMessage(
            content: fullText.substring(userQueryIndex + 12).trim(),
            role: role,
          );
        }
      }
      
      return ChatMessage(
        content: text,
        role: role,
      );
    }).toList();
  }

  void clearChat() {
    _chatHistory.clear();
    _isInitialized = false;
  }
} 