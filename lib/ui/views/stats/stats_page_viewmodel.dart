import 'dart:async';
import 'dart:ui';
import 'package:stacked/stacked.dart';
import 'package:project_gaia/app/app.locator.dart';
import 'package:project_gaia/services/firebase_service.dart';
import 'package:project_gaia/services/gemini_service.dart';

class StatsPageViewmodel extends BaseViewModel {
  final _firebaseService = locator<FirebaseService>();
  final _geminiService = locator<GeminiService>();

  double waterLevel = 0.0;
  double humidityLevel = 0.0;
  double sunlightLevel = 0.0;
  double temperatureLevel = 0.0;
  double overallHealth = 0.0;

  // Raw values for display
  double rawTemperature = 0.0;
  double rawHumidity = 0.0;
  double rawSoilMoisture = 0.0;
  double rawLightIntensity = 0.0;

  // Plant profile
  String plantName = 'Gaia';
  String plantSpecies = 'Unknown';
  String plantPersonality = 'Friendly';

  // Gemini analysis
  String analysisText = '';
  bool isLoadingAnalysis = true;
  bool _hasGeneratedAnalysis = false;

  String get conditionLabel {
    if (overallHealth >= 0.8) return 'Excellent';
    if (overallHealth >= 0.6) return 'Good';
    if (overallHealth >= 0.4) return 'Fair';
    if (overallHealth >= 0.2) return 'Poor';
    return 'Critical';
  }

  Color get conditionColor {
    if (overallHealth >= 0.8) return const Color(0xFF4CAF50);
    if (overallHealth >= 0.6) return const Color(0xFF66BB6A);
    if (overallHealth >= 0.4) return const Color(0xFFFFA726);
    if (overallHealth >= 0.2) return const Color(0xFFEF5350);
    return const Color(0xFFD32F2F);
  }

  StreamSubscription? _sensorDataSubscription;

  void initializeData() {
    // Fetch plant profile first, then start sensor stream
    _loadProfileAndData();
  }

  Future<void> _loadProfileAndData() async {
    try {
      final profile = await _firebaseService.getPlantProfile();
      if (profile['name'] != null) plantName = profile['name']!;
      if (profile['species'] != null) plantSpecies = profile['species']!;
      if (profile['personality'] != null) {
        plantPersonality = profile['personality']!;
      }
    } catch (e) {
      print('Error loading plant profile: $e');
    }

    // Subscribe to real-time sensor data from Firebase
    _sensorDataSubscription = _firebaseService.getSensorDataStream().listen(
      (data) {
        _updateFromData(data);

        // Generate analysis once after we have sensor data
        if (!_hasGeneratedAnalysis) {
          _hasGeneratedAnalysis = true;
          _generateAnalysis();
        }

        notifyListeners();
      },
      onError: (error) {
        print('Error fetching sensor data: $error');
        _setDefaultValues();
      },
    );

    // Also fetch initial data
    _fetchInitialData();
  }

  void _updateFromData(Map<String, dynamic> data) {
    waterLevel = (data['water'] as num).toDouble();
    humidityLevel = (data['humidity'] as num).toDouble();
    sunlightLevel = (data['sunlight'] as num).toDouble();
    temperatureLevel = (data['temperature'] as num).toDouble();

    final rawData = data['raw_data'] as Map?;
    if (rawData != null) {
      rawTemperature = (rawData['temperature_raw'] as num?)?.toDouble() ?? 0.0;
      rawHumidity = (rawData['humidity_raw'] as num?)?.toDouble() ?? 0.0;
      rawSoilMoisture = (rawData['soil_moisture'] as num?)?.toDouble() ?? 0.0;
      rawLightIntensity =
          (rawData['light_intensity_raw'] as num?)?.toDouble() ?? 0.0;
    }

    overallHealth =
        (waterLevel + humidityLevel + sunlightLevel + temperatureLevel) / 4;
  }

  Future<void> _generateAnalysis() async {
    isLoadingAnalysis = true;
    notifyListeners();

    try {
      final result = await _geminiService.getPlantAnalysis(
        plantName: plantName,
        species: plantSpecies,
        personality: plantPersonality,
        temperature: rawTemperature,
        humidity: rawHumidity,
        soilMoisture: rawSoilMoisture,
        lightIntensity: rawLightIntensity,
        overallHealth: overallHealth,
        conditionLabel: conditionLabel,
      );

      if (result.isNotEmpty) {
        analysisText = result;
      } else {
        analysisText = "$plantName is thinking…";
      }
    } catch (e) {
      analysisText = "$plantName couldn't gather its thoughts right now.";
      print('Error generating analysis: $e');
    }

    isLoadingAnalysis = false;
    notifyListeners();
  }

  Future<void> _fetchInitialData() async {
    setBusy(true);
    try {
      final data = await _firebaseService.getSensorData();
      _updateFromData(data);
      notifyListeners();
    } catch (e) {
      print('Error fetching initial sensor data: $e');
      _setDefaultValues();
    } finally {
      setBusy(false);
    }
  }

  void _setDefaultValues() {
    waterLevel = 0.0;
    humidityLevel = 0.0;
    sunlightLevel = 0.0;
    temperatureLevel = 0.0;
    overallHealth = 0.0;
    notifyListeners();
  }

  @override
  void dispose() {
    _sensorDataSubscription?.cancel();
    super.dispose();
  }
}
