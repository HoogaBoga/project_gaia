import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  //save plant data(specie,name,personality)
  Future<void> savePlantProfile({
    required String species,
    required String name,
    required String personality,
  }) async {
    try {
      await _databaseRef.child('plants/gaia_01/profile').set({
        'species': species,
        'name': name,
        'personality': personality,
        'updated_at': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint('Error saving plant profile: $e');
      rethrow;
    }
  }

  // Stream for real-time sensor data from plants/gaia_01
  Stream<Map<String, dynamic>> getSensorDataStream() {
    return _databaseRef.child('plants/gaia_01').onValue.map((event) {
      if (event.snapshot.value != null) {
        try {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          return _convertToNormalizedData(data);
        } catch (e) {
          debugPrint('Error parsing sensor data: $e');
          return _getDefaultSensorData();
        }
      }
      return _getDefaultSensorData();
    });
  }

  // Get latest sensor data (one-time read)
  Future<Map<String, dynamic>> getSensorData() async {
    try {
      final snapshot = await _databaseRef.child('plants/gaia_01').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return _convertToNormalizedData(data);
      }
      return _getDefaultSensorData();
    } catch (e) {
      debugPrint('Error fetching sensor data: $e');
      return _getDefaultSensorData();
    }
  }

  // Convert ESP32 raw data to normalized 0-1 scale
  Map<String, dynamic> _convertToNormalizedData(Map<dynamic, dynamic> data) {
    // soil_moisture: 0-4095 (higher = drier, so we invert)
    // soil_raw is the raw ADC value (4095 = dry, 0 = wet)
    final soilRaw = _parseDouble(data['soil_raw'] ?? 4095);
    final soilMoisture = _parseDouble(data['soil_moisture'] ?? 0);

    // Convert soil moisture: invert so 0 (dry) becomes low, wet becomes high
    // Assuming dry = 4095, wet = 0-1500 range
    final waterLevel =
        soilRaw > 0 ? (1 - (soilRaw / 4095)).clamp(0.0, 1.0) : soilMoisture;

    // humidity: typically 0-100%, convert to 0-1
    final humidity =
        (_parseDouble(data['humidity'] ?? 0) / 100).clamp(0.0, 1.0);

    // temperature: 0-50°C range, convert to 0-1 (assuming comfortable range is 15-35°C)
    final temp = _parseDouble(data['temperature'] ?? 0);
    final temperatureLevel = ((temp - 15) / 20).clamp(0.0, 1.0);

    // sunlight: not in current data, using default 0.5 or you can add light sensor
    final sunlight = _parseDouble(data['sunlight'] ?? 0.5);

    return {
      'water': waterLevel,
      'humidity': humidity,
      'sunlight': sunlight,
      'temperature': temperatureLevel,
      'timestamp': data['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      'raw_data': {
        'soil_raw': soilRaw,
        'soil_moisture': soilMoisture,
        'humidity_raw': _parseDouble(data['humidity'] ?? 0),
        'temperature_raw': temp,
      }
    };
  }

  // Update sensor data (for ESP32 to call)
  Future<void> updateSensorData({
    required double water,
    required double humidity,
    required double sunlight,
    required double temperature,
  }) async {
    try {
      await _databaseRef.child('sensorData').set({
        'water': water,
        'humidity': humidity,
        'sunlight': sunlight,
        'temperature': temperature,
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint('Error updating sensor data: $e');
    }
  }

  // Helper method to parse double values
  double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Default sensor data when no data is available
  Map<String, dynamic> _getDefaultSensorData() {
    return {
      'water': 0.0,
      'humidity': 0.0,
      'sunlight': 0.0,
      'temperature': 0.0,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  Future<Map<String, dynamic>?> getPlantProfile() async {
    try {
      final snapshot = await _databaseRef.child('plants/gaia_01/profile').get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching plant profile: $e');
      return null;
    }
  }

  Future<void> deletePlantData() async {
    try {
      await _databaseRef.child('plants/gaia_01/profile').remove();
    } catch (e) {
      debugPrint('Error deleting plant data: $e');
      rethrow;
    }
  }

  // Dispose method if needed for cleanup
  void dispose() {
    // Clean up any listeners if necessary
  }
}
