import 'dart:async';
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

  StreamSubscription? _sensorDataSubscription;

  void initializeData() {
    // Subscribe to real-time sensor data from Firebase
    _sensorDataSubscription = _firebaseService.getSensorDataStream().listen(
      (data) {
        waterLevel = data['water'] as double;
        humidityLevel = data['humidity'] as double;
        sunlightLevel = data['sunlight'] as double;
        temperatureLevel = data['temperature'] as double;

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
      waterLevel = data['water'] as double;
      humidityLevel = data['humidity'] as double;
      sunlightLevel = data['sunlight'] as double;
      temperatureLevel = data['temperature'] as double;

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
