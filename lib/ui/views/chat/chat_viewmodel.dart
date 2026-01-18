import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatViewModel extends BaseViewModel {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => _messages;

  void initialise() {
    notifyListeners();
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    _messages.add(ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    messageController.clear();
    notifyListeners();
    _scrollToBottom();
    await _getAIResponse(text);
  }

  Future<void> _getAIResponse(String userMessage) async {
    // TODO: Implement Gemini API call here
    // hardcoded for now
    await Future.delayed(const Duration(milliseconds: 500));

    _messages.add(ChatMessage(
      text: "mura kag sikinsa ba...",
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
}
