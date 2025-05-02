import 'package:flutter/material.dart';
import 'package:autidetect/models/chat_message_model.dart';
import 'package:autidetect/services/gemini_service.dart';

class ChatProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  // Add a user message and get a response
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      content: message,
      role: MessageRole.user,
    );
    _messages.add(userMessage);
    notifyListeners();

    // Add loading message from assistant
    _isLoading = true;
    final loadingMessage = ChatMessage(
      content: '...',
      role: MessageRole.assistant,
      isLoading: true,
    );
    _messages.add(loadingMessage);
    notifyListeners();

    try {
      // Get response from Gemini
      final response = await _geminiService.sendMessage(message);

      // Replace loading message with actual response
      _messages.removeWhere((msg) => msg.isLoading);
      final assistantMessage = ChatMessage(
        content: response,
        role: MessageRole.assistant,
      );
      _messages.add(assistantMessage);
    } catch (e) {
      // Replace loading message with error message
      _messages.removeWhere((msg) => msg.isLoading);
      final errorMessage = ChatMessage(
        content: 'Sorry, I encountered an error. Please try again.',
        role: MessageRole.assistant,
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear all messages
  void clearChat() {
    _messages = [];
    _geminiService.clearChat();
    notifyListeners();
  }
} 