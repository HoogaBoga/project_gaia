import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:project_gaia/app/app.locator.dart';
import 'package:stacked/stacked.dart';
import 'package:project_gaia/ui/widgets/notification/notification_item_model.dart';
import 'package:project_gaia/services/firebase_service.dart';
import 'package:project_gaia/services/gemini_service.dart';
import 'package:project_gaia/services/gemini_notification_service.dart';

class HomeViewModel extends BaseViewModel {
  // Safe Defaults
  String plantName = 'Gaia'; 
  String plantSpecies = 'Waiting for data...';
  
  // Default HP
  double currentHpPercent = 0.5; 
  
  // Visual Levels (0.0 - 1.0)
  double waterLevel = 0.0;
  double humidity = 0.0;
  double sunlight = 0.0;
  double temp = 0.0;
  
  // Raw Values for AI
  double _rawTemp = 0.0;
  double _rawHumidity = 0.0;
  double _rawSoil = 0.0;

  double layer1TargetY = 80.0;
  double layer2TargetY = 250.0;
  double layer3TargetY = 420.0;

  // ⚠️ SAVING CREDITS: Set to TRUE by default. Change to FALSE to test AI.
  bool isDevMode = true; 

  final _firebaseService = locator<FirebaseService>();
  final _geminiService = GeminiService();
  final _notificationService = GeminiNotificationService();
  
  StreamSubscription? _sensorSubscription;
  DateTime? _lastAiCheckTime;

  Uint8List? plantImageBytes;
  bool isGeneratingImage = false;
  String _lastVisualState = "";

  // Notifications
  bool _showNotificationsOverlay = false;
  bool get showNotificationsOverlay => _showNotificationsOverlay;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  void toggleNotifications() {
    _showNotificationsOverlay = !_showNotificationsOverlay;
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    _showNotificationsOverlay = false;
    notifyListeners();
  }

  void initialise() {
    _sensorSubscription = _firebaseService.getSensorDataStream().listen((data) {
      if (data.isEmpty) return;

      // --- 1. NAME & SPECIES FIX ---
      if (data['profile'] != null) {
        try {
          final profile = data['profile'];
          plantName = profile['name']?.toString() ?? 'Gaia';
          plantSpecies = profile['species']?.toString() ?? 'Unknown Species';
        } catch (e) {
          print("Error parsing profile: $e");
        }
      }

      // --- 2. VISUAL DATA FIX (Already Normalized 0-1) ---
      waterLevel = (data['water'] as num?)?.toDouble() ?? 0.0;
      humidity = (data['humidity'] as num?)?.toDouble() ?? 0.0;
      temp = (data['temperature'] as num?)?.toDouble() ?? 0.0;
      sunlight = (data['sunlight'] as num?)?.toDouble() ?? 0.0;

      // --- 3. RAW DATA extraction (For AI) ---
      if (data['raw_data'] != null) {
        final raw = data['raw_data'];
        _rawSoil = (raw['soil_moisture'] as num?)?.toDouble() ?? 0.0;
        _rawHumidity = (raw['humidity'] as num?)?.toDouble() ?? 0.0;
        _rawTemp = (raw['temperature'] as num?)?.toDouble() ?? 0.0;
      }

      // --- 4. HEALTH BAR FIX ---
      // Do NOT divide by 100 here. The service already gave us 0.0-1.0
      currentHpPercent = (waterLevel + humidity) / 2;
      currentHpPercent = currentHpPercent.clamp(0.0, 1.0);

      notifyListeners(); 

      // Trigger AI (only if not dev mode)
      if (!isDevMode) {
        _updateDigitalTwin();
        _checkPlantNeedsWithAI();
      }
    });
  }

  /// AI Logic 
  Future<void> _checkPlantNeedsWithAI() async {
    // 15-min Throttle
    if (_lastAiCheckTime != null && 
        DateTime.now().difference(_lastAiCheckTime!) < const Duration(minutes: 15)) {
      return;
    }

    try {
      // We pass the RAW values to the AI so it knows "35°C" vs "20°C"
      // instead of just "0.8" which is meaningless to it.
      final alerts = await _notificationService.analyzePlantNeeds(
        species: plantSpecies,
        temp: _rawTemp, 
        humidity: _rawHumidity,
        soilMoisture: _rawSoil,
        sunlight: sunlight, // Sunlight usually has no unit in this setup
      );

      if (alerts.isNotEmpty) {
        _notifications.clear();
        for (var alert in alerts) {
          _notifications.add(NotificationModel(
            icon: _mapIcon(alert['type']),
            iconColor: _mapColor(alert['type']),
            title: alert['title'] ?? "Alert",
            time: "${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}",
          ));
        }
        _showNotificationsOverlay = true;
        notifyListeners();
      }
      _lastAiCheckTime = DateTime.now();
    } catch (e) {
      print("AI Error: $e");
    }
  }

  // ... (Keep existing _mapIcon, _mapColor, _updateDigitalTwin helpers) ...
  
  IconData _mapIcon(String? type) {
    switch (type) {
      case 'water': return Icons.water_drop;
      case 'sun': return Icons.wb_sunny;
      case 'temp': return Icons.thermostat;
      case 'humidity': return Icons.cloud;
      default: return Icons.notifications;
    }
  }

  Color _mapColor(String? type) {
    switch (type) {
      case 'water': return Colors.blue;
      case 'sun': return Colors.amber;
      case 'temp': return Colors.red;
      default: return Colors.green;
    }
  }

  Future<void> _updateDigitalTwin() async {
    String currentZone = _getHealthZone(currentHpPercent);
    if (currentZone == _lastVisualState && plantImageBytes != null) return;

    try {
      isGeneratingImage = true;
      notifyListeners();

      String prompt = _buildPrompt(currentZone);
      final newImage = await _geminiService.generateImage(prompt);

      if (newImage != null) {
        plantImageBytes = newImage;
        _lastVisualState = currentZone;
      }
    } catch (e) {
      print("Image Gen Error: $e");
    } finally {
      isGeneratingImage = false;
      notifyListeners();
    }
  }

  String _getHealthZone(double health) {
    if (health >= 0.8) return "perfect";
    if (health >= 0.4) return "warning";
    return "critical";
  }

  String _buildPrompt(String zone) {
    String visual = "";
    switch (zone) {
      case "perfect": visual = "glowing neon green, vibrant"; break;
      case "warning": visual = "slightly drooping, yellow edges"; break;
      case "critical": visual = "withered, brown leaves"; break;
    }
    return "3D render of $plantSpecies, $visual, isometric view.";
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    super.dispose();
  }
}
