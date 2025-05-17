import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:autidetect/constants/colors.dart';
import 'package:autidetect/models/chat_message_model.dart';
import 'package:autidetect/providers/chat_provider.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DateFormat _timeFormat = DateFormat('h:mm a');

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AutiHelp Assistant'),
        backgroundColor: AppColors.primaryDark,
        centerTitle: true,
        actions: [
          Consumer<ChatProvider>(
            builder: (context, chatProvider, _) {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  chatProvider.clearChat();
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                final messages = chatProvider.messages;
                
                if (messages.isEmpty) {
                  return _buildEmptyChatView();
                }
                
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return _buildMessageBubble(message);
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyChatView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: AppColors.primaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Ask AutiHelp anything',
            style: TextStyle(
              fontSize: 20,
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              'Get information about autism, developmental milestones, or parenting tips',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.role == MessageRole.user;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(isUser),
          const SizedBox(width: 8),
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser 
                          ? AppColors.primaryDark
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: message.isLoading
                        ? SizedBox(
                            width: 40,
                            height: 20,
                            child: Center(
                              child: LinearProgressIndicator(
                                backgroundColor: AppColors.accent1.withOpacity(0.3),
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                              ),
                            ),
                          )
                        : isUser
                            ? Text(
                                message.content,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              )
                            : MarkdownBody(
                                data: message.content,
                                styleSheet: MarkdownStyleSheet(
                                  p: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                  ),
                                  h1: TextStyle(
                                    color: AppColors.primaryDark,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  h2: TextStyle(
                                    color: AppColors.primaryDark,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  h3: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  a: TextStyle(
                                    color: AppColors.accent2,
                                  ),
                                  listBullet: TextStyle(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 4.0, right: 4.0),
                    child: Text(
                      _timeFormat.format(message.timestamp),
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isUser) _buildAvatar(isUser),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: isUser ? AppColors.primaryLight : AppColors.accent2,
      child: Icon(
        isUser ? Icons.person : Icons.psychology_alt,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildInputArea() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        return Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask a question...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 5,
                    minLines: 1,
                    textInputAction: TextInputAction.newline,
                    enabled: !chatProvider.isLoading,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        chatProvider.sendMessage(value);
                        _messageController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      chatProvider.isLoading ? Icons.hourglass_top : Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: chatProvider.isLoading
                        ? null
                        : () {
                            final message = _messageController.text;
                            if (message.trim().isNotEmpty) {
                              chatProvider.sendMessage(message);
                              _messageController.clear();
                            }
                          },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 