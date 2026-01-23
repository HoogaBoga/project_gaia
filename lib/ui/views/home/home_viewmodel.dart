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

  bool isDevMode = true;

  final _firebaseService = locator<FirebaseService>();
  final _geminiService = locator<GeminiService>();
  StreamSubscription? _sensorSubscription;

  Uint8List? plantImageBytes;
  bool isGeneratingImage = false;
  String _lastVisualState = "";
  bool _isUpdatingDigitalTwin = false;
  bool _isInitialized = false;

  bool _showNotificationsOverlay = false;
  bool get showNotificationsOverlay => _showNotificationsOverlay;

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

  Future<void> _updateDigitalTwin() async {
    if (_isUpdatingDigitalTwin) {
      print("⏳ Already updating digital twin, skipping...");
      return;
    }

    String currentZone = _getHealthZone(currentHpPercent);

    if (currentZone == _lastVisualState && plantImageBytes != null) {
      print("✅ Same zone ($currentZone) - using existing image.");
      return;
    }

    _isUpdatingDigitalTwin = true;

    try {
      print("🔍 Checking database for $currentZone image...");
      final savedVisuals = await _firebaseService.getPlantVisuals();

      // ✅ Debug logging
      if (savedVisuals == null) {
        print("⚠️ No visuals data found in database at all");
      } else {
        print("📊 Database has: ${savedVisuals.toString()}");
        print("🎯 Current zone: $currentZone");
        print("💾 Saved zone: ${savedVisuals['visualState']}");
        print("🔗 Saved URL: ${savedVisuals['imageUrl']}");
      }

      if (savedVisuals != null && savedVisuals['visualState'] == currentZone) {
        String? savedUrl = savedVisuals['imageUrl'];

        if (savedUrl != null) {
          print("✅ Found SAVED image in Firebase! Downloading...");

          try {
            final response = await http.get(Uri.parse(savedUrl));

            if (response.statusCode == 200) {
              plantImageBytes = response.bodyBytes;
              _lastVisualState = currentZone;
              notifyListeners();
              print("✅ Using cached image from database!");
              return;
            }
          } catch (e) {
            print("❌ Failed to download cached image: $e");
          }
        }
      }

      if (isDevMode) {
        print(
            "🚧 DEV MODE: No cached image found, but skipping AI generation to save money.");
        return;
      }

      print(
          "🎨 No cached image found. Generating new image for $currentZone...");

      isGeneratingImage = true;
      notifyListeners();

      String prompt = _buildPrompt(currentZone);
      final newImage = await _geminiService.generateImage(prompt);

      if (newImage != null) {
        plantImageBytes = newImage;
        _lastVisualState = currentZone;

        isGeneratingImage = false;
        notifyListeners();

        print("☁️ Uploading new image to Storage...");
        _firebaseService
            .uploadPlantImage(newImage, _plantId)
            .then((downloadUrl) {
          if (downloadUrl != null) {
            print("💾 Saving link to Database...");
            _firebaseService.updatePlantVisuals(downloadUrl, currentZone);
          }
        }).catchError((error) {
          print("❌ Upload/save failed: $error");
        });
      } else {
        isGeneratingImage = false;
        notifyListeners();
        print("❌ Image generation failed");
      }
    } finally {
      _isUpdatingDigitalTwin = false;
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

  // ✅ This should ONLY be called from onViewModelReady
  void initialise() {
    if (_isInitialized) {
      print("⚠️ Already initialized, skipping...");
      return;
    }

    print("🚀 HomeViewModel initializing...");
    _isInitialized = true;
    setBusy(true);

    // Small delay to ensure UI is ready
    Future.delayed(Duration(milliseconds: 300), () {
      _sensorSubscription =
          _firebaseService.getSensorDataStream().listen((data) {
        waterLevel = (data['water'] as num).toDouble();
        double humidity = (data['humidity'] as num).toDouble();
        double sunlight = (data['sunlight'] as num).toDouble();
        double temp = (data['temperature'] as num).toDouble();

        double newHpPercent = (waterLevel + humidity + sunlight + temp) / 4;

        // Only update if changed significantly
        if ((newHpPercent - currentHpPercent).abs() > 0.05) {
          currentHpPercent = newHpPercent;
          _updateDigitalTwin();
        } else {
          currentHpPercent = newHpPercent;
        }

        notifyListeners();
      });

      setBusy(false);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    super.dispose();
  }
}
