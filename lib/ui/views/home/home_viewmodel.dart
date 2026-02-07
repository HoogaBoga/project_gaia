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
  String plantName = 'Gaia';
  String plantSpecies = 'Unknown Species';

  Map<String, dynamic>? _idealConditions;

  double currentHpPercent = 0.65;
  double waterLevel = 0.0;

  final String _plantId = "gaia_01";

  double layer1TargetY = 80.0;
  double layer2TargetY = 250.0;
  double layer3TargetY = 420.0;

  bool isDevMode = false;

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

  // Initial dummy notifications (optional: you can clear these in initialise if preferred)
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

  // 3. New: Logic to check raw sensor data against ideal conditions
  void _checkPlantHealth(Map<String, dynamic> data) {
    if (_idealConditions == null) return;

    // Extract RAW real-world values (not the 0.0-1.0 normalized ones)
    // Note: 'raw_data' comes from the updated FirebaseService structure
    final rawData = data['raw_data'] as Map;
    final double currentTemp = (rawData['temperature_raw'] as num).toDouble();
    final double currentHumidity = (rawData['humidity_raw'] as num).toDouble();

    // Calculate soil percentage from normalized water level (0.0 - 1.0)
    final double currentSoilPercent = (data['water'] as num).toDouble() * 100;

    // Clear old auto-generated warnings to avoid duplicates
    _notifications.removeWhere((n) => n.title.contains("Warning:"));

    // --- Temperature Check ---
    double minTemp = (_idealConditions!['min_temp_c'] as num).toDouble();
    double maxTemp = (_idealConditions!['max_temp_c'] as num).toDouble();

    if (currentTemp < minTemp) {
      _addNotification(
          icon: Icons.ac_unit,
          color: Colors.blue,
          title: "Warning: It's too cold!",
          subtitle:
              "$plantName needs at least ${minTemp.toInt()}°C (Current: ${currentTemp.toStringAsFixed(1)}°C)");
    } else if (currentTemp > maxTemp) {
      _addNotification(
          icon: Icons.local_fire_department,
          color: Colors.red,
          title: "Warning: It's too hot!",
          subtitle:
              "$plantName prefers under ${maxTemp.toInt()}°C (Current: ${currentTemp.toStringAsFixed(1)}°C)");
    }

    // --- Humidity Check ---
    double minHum = (_idealConditions!['min_humidity'] as num).toDouble();
    if (currentHumidity < minHum) {
      _addNotification(
          icon: Icons.water_drop_outlined,
          color: Colors.orange,
          title: "Warning: Air is too dry",
          subtitle:
              "$plantSpecies needs >${minHum.toInt()}% humidity (Current: ${currentHumidity.toInt()}%)");
    }

    // --- Soil Moisture Check ---
    double minSoil = (_idealConditions!['min_soil_moisture'] as num).toDouble();
    if (currentSoilPercent < minSoil) {
      _addNotification(
          icon: Icons.water_drop,
          color: Colors.blueAccent,
          title: "Warning: Thirsty!",
          subtitle:
              "Soil moisture is low (${currentSoilPercent.toInt()}%). Please water me.");
    }
  }

  void _addNotification(
      {required IconData icon,
      required Color color,
      required String title,
      required String subtitle}) {
    // Prevent duplicate entries for the exact same issue
    if (_notifications.any((n) => n.title == title)) return;

    _notifications.insert(
        0,
        NotificationModel(
          icon: icon,
          iconColor: color,
          title: title,
          time: subtitle, // Using 'time' field for the description text
        ));

    // If overlay is closed, trigger UI update so the red dot (if you have one) or state updates
    notifyListeners();
  }

  Future<void> _updateDigitalTwin() async {
    if (_isUpdatingDigitalTwin) {
      print("⏳ Already updating digital twin, skipping...");
      return;
    }

    String currentZone = _getHealthZone(currentHpPercent);

    if (currentZone == _lastVisualState && plantImageBytes != null) {
      // print("✅ Same zone ($currentZone) - using existing image.");
      return;
    }

    _isUpdatingDigitalTwin = true;

    try {
      print("🔍 Checking database for $currentZone image...");
      final savedVisuals = await _firebaseService.getPlantVisuals();

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

    return "A 3D render of a $plantSpecies plant in a pot. The plant is $visual. Isometric view, transparent background";
  }

  // 4. Updated: Initialize now fetches profile and ideal conditions
  void initialise() {
    if (_isInitialized) {
      print("⚠️ Already initialized, skipping...");
      return;
    }

    print("🚀 HomeViewModel initializing...");
    _isInitialized = true;
    setBusy(true);

    // Run startup logic
    Future(() async {
      try {
        // A. Fetch Plant Profile
        final profile = await _firebaseService.getPlantProfile();
        if (profile['name'] != null) plantName = profile['name']!;
        if (profile['species'] != null) {
          plantSpecies = profile['species']!;
          print("🌿 Identified Species: $plantSpecies");

          // B. Get Ideal Conditions from Gemini
          // Note: Ensure you have added getPlantCareProfile to your GeminiService
          _idealConditions =
              await _geminiService.getPlantCareProfile(plantSpecies);
          if (_idealConditions != null) {
            print("✅ Ideal conditions loaded: $_idealConditions");
          }
        }
      } catch (e) {
        print("❌ Error fetching plant profile: $e");
      }

      // C. Start Sensor Stream
      _sensorSubscription =
          _firebaseService.getSensorDataStream().listen((data) {
        waterLevel = (data['water'] as num).toDouble();
        double humidity = (data['humidity'] as num).toDouble();
        double sunlight = (data['sunlight'] as num).toDouble();
        double temp = (data['temperature'] as num).toDouble();

        double newHpPercent = (waterLevel + humidity + sunlight + temp) / 4;

        // D. Check Health Stats (Notifications)
        _checkPlantHealth(data);

        // Only update Digital Twin if changed significantly
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
