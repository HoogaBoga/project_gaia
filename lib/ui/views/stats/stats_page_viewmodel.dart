import 'dart:async';
import 'dart:ui';
import 'package:stacked/stacked.dart';
import 'package:project_gaia/app/app.locator.dart';
import 'package:project_gaia/services/firebase_service.dart';

class StatsPageViewmodel extends BaseViewModel {
  final _firebaseService = locator<FirebaseService>();

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
    // Subscribe to real-time sensor data from Firebase
    _sensorDataSubscription = _firebaseService.getSensorDataStream().listen(
      (data) {
        waterLevel = (data['water'] as num).toDouble();
        humidityLevel = (data['humidity'] as num).toDouble();
        sunlightLevel = (data['sunlight'] as num).toDouble();
        temperatureLevel = (data['temperature'] as num).toDouble();

        // Extract raw values for display
        final rawData = data['raw_data'] as Map?;
        if (rawData != null) {
          rawTemperature =
              (rawData['temperature_raw'] as num?)?.toDouble() ?? 0.0;
          rawHumidity = (rawData['humidity_raw'] as num?)?.toDouble() ?? 0.0;
          rawSoilMoisture =
              (rawData['soil_moisture'] as num?)?.toDouble() ?? 0.0;
          rawLightIntensity =
              (rawData['light_intensity_raw'] as num?)?.toDouble() ?? 0.0;
        }

        overallHealth =
            (waterLevel + humidityLevel + sunlightLevel + temperatureLevel) / 4;

        notifyListeners();
      },
      onError: (error) {
        // Handle error - could show a snackbar or log
        print('Error fetching sensor data: $error');
        // Set default values on error
        _setDefaultValues();
      },
    );

    // Also fetch initial data
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setBusy(true);
    try {
      final data = await _firebaseService.getSensorData();
      waterLevel = (data['water'] as num).toDouble();
      humidityLevel = (data['humidity'] as num).toDouble();
      sunlightLevel = (data['sunlight'] as num).toDouble();
      temperatureLevel = (data['temperature'] as num).toDouble();

      final rawData = data['raw_data'] as Map?;
      if (rawData != null) {
        rawTemperature =
            (rawData['temperature_raw'] as num?)?.toDouble() ?? 0.0;
        rawHumidity = (rawData['humidity_raw'] as num?)?.toDouble() ?? 0.0;
        rawSoilMoisture = (rawData['soil_moisture'] as num?)?.toDouble() ?? 0.0;
        rawLightIntensity =
            (rawData['light_intensity_raw'] as num?)?.toDouble() ?? 0.0;
      }

      overallHealth =
          (waterLevel + humidityLevel + sunlightLevel + temperatureLevel) / 4;

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
