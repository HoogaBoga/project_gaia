import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  // Save plant data
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

  // Stream for real-time sensor data
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

  // --- FIX: Preserves Profile & Correctly Normalizes ---
  Map<String, dynamic> _convertToNormalizedData(Map<dynamic, dynamic> data) {
    // 1. Extract Raw Values
    final soilRaw = _parseDouble(data['soil_raw'] ?? 4095);
    // Some sensors send soil_moisture as 0-100, others as raw ADC. 
    // We'll trust your logic here but ensure we capture the raw value for AI.
    final soilMoistureRaw = _parseDouble(data['soil_moisture'] ?? 0); 
    
    // 2. Normalize (0.0 to 1.0) for UI Progress Bars
    // Invert logic: 4095 is dry (0.0), 0 is wet (1.0)
    final waterLevel = soilRaw > 0 
        ? (1 - (soilRaw / 4095)).clamp(0.0, 1.0) 
        : (soilMoistureRaw / 100).clamp(0.0, 1.0);

    final humidityRaw = _parseDouble(data['humidity'] ?? 0);
    final humidity = (humidityRaw / 100).clamp(0.0, 1.0);

    final tempRaw = _parseDouble(data['temperature'] ?? 0);
    // Assuming comfortable range 15-35°C for the progress bar visual
    final temperatureLevel = ((tempRaw - 15) / 20).clamp(0.0, 1.0);

    final sunlight = _parseDouble(data['sunlight'] ?? 0.5);

    return {
      // VISUAL DATA (0.0 - 1.0)
      'water': waterLevel,
      'humidity': humidity,
      'sunlight': sunlight,
      'temperature': temperatureLevel,
      
      // META DATA
      'timestamp': data['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      
      // *** CRITICAL FIX: PASS THE PROFILE THROUGH ***
      'profile': data['profile'], 

      // RAW DATA (For AI Analysis)
      'raw_data': {
        'soil_moisture': soilMoistureRaw, 
        'soil_raw': soilRaw,
        'humidity': humidityRaw,
        'temperature': tempRaw,
        'sunlight': sunlight,
      }
    };
  }

  // Update sensor data (for ESP32 simulation)
  Future<void> updateSensorData({
    required double water,
    required double humidity,
    required double sunlight,
    required double temperature,
  }) async {
    try {
      await _databaseRef.child('plants/gaia_01').update({
        'soil_moisture': water,
        'humidity': humidity,
        'sunlight': sunlight,
        'temperature': temperature,
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint('Error updating sensor data: $e');
    }
  }

  double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> _getDefaultSensorData() {
    return {
      'water': 0.0,
      'humidity': 0.0,
      'sunlight': 0.0,
      'temperature': 0.0,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'raw_data': {
        'soil_moisture': 0.0,
        'humidity': 0.0,
        'temperature': 0.0,
      }
    };
  }
}
