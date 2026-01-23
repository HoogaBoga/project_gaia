import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:project_gaia/app/app.locator.dart';
import 'package:stacked/stacked.dart';
import 'package:project_gaia/ui/widgets/notification/notification_item_model.dart';
import 'package:project_gaia/services/firebase_service.dart';
import 'package:project_gaia/services/gemini_service.dart';
import 'package:http/http.dart' as http;

class HomeViewModel extends BaseViewModel {
  final String plantName = 'Gaia';
  final String plantSpecies = 'Ficus pseudopalma';

  double currentHpPercent = 0.65;
  double waterLevel = 0.0;

  final String _plantId = "gaia_01";

  double layer1TargetY = 80.0;
  double layer2TargetY = 250.0;
  double layer3TargetY = 420.0;

  bool isDevMode =
      false; //so that the api wont be called over and over and get my money huhu

  // --- NEW CODE START ---

  final _firebaseService = locator<FirebaseService>();
  final _geminiService = GeminiService();
  StreamSubscription? _sensorSubscription;

  Uint8List? plantImageBytes;
  bool isGeneratingImage = false;
  String _lastVisualState = "";

  // 1. State for controlling the overlay visibility
  bool _showNotificationsOverlay = false;
  bool get showNotificationsOverlay => _showNotificationsOverlay;

  // 2. The data list for your notifications
  List<NotificationModel> _notifications = [
    NotificationModel(
      icon: Icons.water_drop,
      iconColor: Colors.blue,
      title: "You forgot to water me :(",
      time: "10:00AM",
    ),
    NotificationModel(
      icon: Icons.wb_sunny_rounded,
      iconColor: Colors.amber,
      title: "I need more sunlight sir...",
      time: "11:00AM",
    ),
  ];

  // Getter to expose the list to the View
  List<NotificationModel> get notifications => _notifications;

  // 3. Logic to toggle visibility (attached to the Bell Icon)
  void toggleNotifications() {
    _showNotificationsOverlay = !_showNotificationsOverlay;
    notifyListeners(); // This tells the UI to rebuild
  }

  // 4. Logic to clear notifications (attached to the Clear button)
  void clearNotifications() {
    _notifications.clear();
    _showNotificationsOverlay = false; // Optionally close the overlay
    notifyListeners();
  }

  Future<void> _updateDigitalTwin() async {
    if (isDevMode) {
      print("🚧 DEV MODE: Skipping AI Generation to save money.");
      return;
    }
    String currentZone = _getHealthZone(currentHpPercent);

    if (currentZone == _lastVisualState && plantImageBytes != null) return;

    final savedVisuals = await _firebaseService.getPlantVisuals();

    if (savedVisuals != null && savedVisuals['visualState'] == currentZone) {
      String? savedUrl = savedVisuals['imageUrl'];

      if (savedUrl != null) {
        print("✅ Found SAVED image in Firebase! Downloading...");

        final response = await http.get(Uri.parse(savedUrl));

        if (response.statusCode == 200) {
          plantImageBytes = response.bodyBytes;
          _lastVisualState = currentZone;
          notifyListeners();
          return;
        }
      }
    }

    isGeneratingImage = true;
    notifyListeners();

    print("Zone changed to $currentZone. Generating new Twin...");

    String prompt = _buildPrompt(currentZone);

    final newImage = await _geminiService.generateImage(prompt);

    if (newImage != null) {
      plantImageBytes = newImage;
      _lastVisualState = currentZone;
    }

    print("☁️ Uploading new image to Storage...");

    _firebaseService.uploadPlantImage(newImage!, _plantId).then((downloadUrl) {
      if (downloadUrl != null) {
        print("💾 Saving link to Database...");
        _firebaseService.updatePlantVisuals(downloadUrl, currentZone);
      }
    });

    isGeneratingImage = false;
    notifyListeners();
  }

  String _getHealthZone(double health) {
    if (health >= 0.8) return "perfect";
    if (health >= 0.4) return "warning";
    return "critical";
  }

  String _buildPrompt(String zone) {
    String visual = "";
    switch (zone) {
      case "perfect":
        visual = "glowing neon green, vibrant, upright, floating spores";
        break;
      case "warning":
        visual = "slightly drooping, matte texture, yellow edges";
        break;
      case "critical":
        visual = "withered, brown crispy leaves, drooping, red warning lights";
        break;
    }

    return "A 3D render of a $plantSpecies plant in a pot. The plant is $visual. Isometric view, dark blue background";
  }

  // --- NEW CODE END ---

  void initialise() {
    setBusy(true);

    _sensorSubscription = _firebaseService.getSensorDataStream().listen((data) {
      waterLevel = (data['water'] as num).toDouble();
      double humidity = (data['humidity'] as num).toDouble();
      double sunlight = (data['sunlight'] as num).toDouble();
      double temp = (data['temperature'] as num).toDouble();

      currentHpPercent = (waterLevel + humidity + sunlight + temp) / 4;

      _updateDigitalTwin();

      notifyListeners();
    });

    setBusy(false);
    notifyListeners();
  }
}
