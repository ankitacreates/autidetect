import 'package:flutter/material.dart';

enum MessageRole {
  user,
  assistant,
}

class ChatMessage {
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.content,
    required this.role,
    DateTime? timestamp,
    this.isLoading = false,
  }) : timestamp = timestamp ?? DateTime.now();
} 