import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import '../../../services/gemini_service.dart';
import '../../../services/firebase_service.dart';
import '../../../app/app.locator.dart';

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
  final FirebaseService _firebaseService = locator<FirebaseService>();

  String? _plantName;
  String? _plantPersonality;

  // Sensor values for chatbot mood (not implemented yet)
  double? _humidity;
  double? _soilMoisture;
  double? _soilRaw;
  double? _temperature;

  List<ChatMessage> get messages => _messages;

  // Sensor values are fetched but mood logic not implemented yet

  Future<void> initialise() async {
    await _loadPlantProfile();
    await _loadSensorValues(); // Load sensor values for future mood implementation
    await _generateIntroduction();
    notifyListeners();
  }

  Future<void> _generateIntroduction() async {
    try {
      // Only generate introduction if we have profile data
      if (_plantName != null || _plantPersonality != null) {
        final introduction = await _geminiService.generateChatResponse(
          'Please introduce yourself briefly (2-3 sentences). Tell me your name and show your personality.',
          plantName: _plantName,
          personality: _plantPersonality,
        );
        _messages.add(ChatMessage(
          text: introduction,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        notifyListeners();
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('Error generating introduction: $e');
      // Fallback introduction if API fails
      final name = _plantName ?? 'Gaia';
      _messages.add(ChatMessage(
        text:
            'Hello! I\'m $name, your plant companion. How can I help you today?',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    }
  }

  Future<void> _loadPlantProfile() async {
    try {
      final profile = await _firebaseService.getPlantProfile();
      _plantName = profile['name'];
      _plantPersonality = profile['personality'];
    } catch (e) {
      debugPrint('Error loading plant profile: $e');
    }
  }

  //TODO: still need to connect this to the plants attributes with the hardware
  Future<void> _loadSensorValues() async {
    try {
      final sensorData = await _firebaseService.getRawSensorValues();
      _humidity = sensorData['humidity'];
      _soilMoisture = sensorData['soil_moisture'];
      _soilRaw = sensorData['soil_raw'];
      _temperature = sensorData['temperature'];
      debugPrint(
          'Sensor values loaded - Humidity: $_humidity, Soil Moisture: $_soilMoisture, Soil Raw: $_soilRaw, Temperature: $_temperature');
    } catch (e) {
      debugPrint('Error loading sensor values: $e');
    }
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
      // Load plant profile if not already loaded
      if (_plantName == null || _plantPersonality == null) {
        await _loadPlantProfile();
      }

      //gemini api call with personality and name
      final reply = await _geminiService.generateChatResponse(
        userMessage,
        plantName: _plantName,
        personality: _plantPersonality,
      );
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
