import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../services/gemini_service.dart';

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

  final GeminiService _geminiService = GeminiService();

  List<ChatMessage> get messages => _messages;

  void initialise() {
    notifyListeners();
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

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
    setBusy(true);

    try {
      //gemini api call

      final reply = await _geminiService.generateChatResponse(userMessage);
      _messages.add(ChatMessage(
        text: reply,
        isUser: false,
        timestamp: DateTime.now(),
      ));

      //hardcoded for now
      // await Future.delayed(const Duration(milliseconds: 400));
      // _messages.add(ChatMessage(
      //   text: 'mura kag sikinsa b...',
      //   isUser: false,
      //   timestamp: DateTime.now(),
      // ));
    } catch (e) {
      _messages.add(ChatMessage(
        text: 'Error talking to Gaia: $e',
        isUser: false,
        timestamp: DateTime.now(),
      ));
    } finally {
      setBusy(false);
      notifyListeners();
      _scrollToBottom();
    }
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
