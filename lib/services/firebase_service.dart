import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instanceFor(
      bucket: "gs://project-gaia-d7b6e.firebasestorage.app");

  // upload image to database
  Future<String?> uploadPlantImage(Uint8List imageBytes, String plantId) async {
    try {
      debugPrint("☁️ [FirebaseService] Starting upload for $plantId...");
      debugPrint("☁️ [FirebaseService] Image size: ${imageBytes.length} bytes");

      final String fileName =
          "visual_${DateTime.now().millisecondsSinceEpoch}.png";

      final ref = _firebaseStorage.ref().child('plants/$plantId/$fileName');

      final metaData = SettableMetadata(contentType: 'image/png');

      debugPrint("☁️ [FirebaseService] Uploading to: ${ref.fullPath}");
      await ref.putData(imageBytes, metaData);

      final downloadUrl = await ref.getDownloadURL();
      debugPrint("✅ [FirebaseService] Upload success: $downloadUrl");
      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint("❌ [FirebaseService] Firebase error: ${e.code}");
      debugPrint("❌ [FirebaseService] Error message: ${e.message}");
      debugPrint("❌ [FirebaseService] Error details: ${e.stackTrace}");
      return null;
    } catch (e) {
      debugPrint("❌ [FirebaseService] Upload failed: $e");
      return null;
    }
  }

  // get saved visual state
  // get saved visual state
  // get saved visual state
  Future<Map<String, dynamic>?> getPlantVisuals() async {
    try {
      debugPrint('🔍 Reading from: plants/gaia_01/visuals');
      final snapshot = await _databaseRef.child('plants/gaia_01/visuals').get();

      debugPrint('📊 Snapshot exists: ${snapshot.exists}');

      if (snapshot.exists && snapshot.value != null) {
        final dynamic rawData = snapshot.value;

        // Handle both Map<Object?, Object?> and Map<dynamic, dynamic>
        Map<String, dynamic> data;
        if (rawData is Map) {
          data = Map<String, dynamic>.from(rawData as Map);
        } else {
          debugPrint('❌ Unexpected data type: ${rawData.runtimeType}');
          return null;
        }

        // ✅ FIX: Check if we need to access nested 'visuals' object
        Map<String, dynamic> visualsData;
        if (data.containsKey('visuals')) {
          // Data is nested (we got the parent node by mistake)
          debugPrint('⚠️ Data is nested, extracting visuals...');
          visualsData = Map<String, dynamic>.from(data['visuals'] as Map);
        } else {
          // Data is already at the correct level
          visualsData = data;
        }

        final imageUrl = visualsData['imageUrl'];
        final visualState = visualsData['visualState'];

        debugPrint('🔗 imageUrl: $imageUrl');
        debugPrint('🎯 visualState: $visualState');

        final result = {
          'imageUrl': imageUrl?.toString(),
          'visualState': visualState?.toString(),
        };

        debugPrint('✅ Parsed result: $result');
        return result;
      }

      debugPrint('⚠️ No data found');
      return null;
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting plant visuals: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      return null;
    }
  }

  // update visual state for a single zone
  Future<void> updatePlantVisuals(String imageUrl, String zone) async {
    try {
      await _databaseRef.child('plants/gaia_01/visuals/$zone').set({
        'imageUrl': imageUrl,
        'updated_at': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint('Error updating plant visuals: $e');
    }
  }

  // Save all 3 zone image URLs at once
  Future<void> updateAllPlantVisuals({
    required String perfectUrl,
    required String warningUrl,
    required String criticalUrl,
  }) async {
    try {
      await _databaseRef.child('plants/gaia_01/visuals').set({
        'perfect': {
          'imageUrl': perfectUrl,
          'updated_at': ServerValue.timestamp
        },
        'warning': {
          'imageUrl': warningUrl,
          'updated_at': ServerValue.timestamp
        },
        'critical': {
          'imageUrl': criticalUrl,
          'updated_at': ServerValue.timestamp
        },
        'generated': true,
      });
    } catch (e) {
      debugPrint('Error updating all plant visuals: $e');
    }
  }

  // Get image URL for a specific health zone
  Future<String?> getPlantVisualForZone(String zone) async {
    try {
      final snapshot = await _databaseRef
          .child('plants/gaia_01/visuals/$zone/imageUrl')
          .get();
      if (snapshot.exists && snapshot.value != null) {
        return snapshot.value.toString();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting visual for zone $zone: $e');
      return null;
    }
  }

  // Check if all 3 visuals have been generated
  Future<bool> hasAllVisuals() async {
    try {
      final snapshot =
          await _databaseRef.child('plants/gaia_01/visuals/generated').get();
      return snapshot.exists && snapshot.value == true;
    } catch (e) {
      return false;
    }
  }

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

  // Get plant profile (name, personality, species)
  Future<Map<String, String?>> getPlantProfile() async {
    try {
      final snapshot = await _databaseRef.child('plants/gaia_01/profile').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return {
          'name': data['name']?.toString(),
          'personality': data['personality']?.toString(),
          'species': data['species']?.toString(),
        };
      }
      return {'name': null, 'personality': null, 'species': null};
    } catch (e) {
      debugPrint('Error fetching plant profile: $e');
      return {'name': null, 'personality': null, 'species': null};
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

  // Get raw sensor values for chatbot mood (humidity, soil_moisture, soil_raw, temperature)
  Future<Map<String, double?>> getRawSensorValues() async {
    try {
      final snapshot = await _databaseRef.child('plants/gaia_01').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return {
          'humidity': _parseDouble(data['humidity']),
          'soil_moisture': _parseDouble(data['soil_moisture']),
          'soil_raw': _parseDouble(data['soil_raw']),
          'temperature': _parseDouble(data['temperature']),
        };
      }
      return {
        'humidity': null,
        'soil_moisture': null,
        'soil_raw': null,
        'temperature': null,
      };
    } catch (e) {
      debugPrint('Error fetching raw sensor values: $e');
      return {
        'humidity': null,
        'soil_moisture': null,
        'soil_raw': null,
        'temperature': null,
      };
    }
  }

  // Convert ESP32 raw data to normalized 0-1 scale
  Map<String, dynamic> _convertToNormalizedData(Map<dynamic, dynamic> data) {
    // soil_moisture is already a 0-100 percentage from the sensor
    final soilRaw = _parseDouble(data['soil_raw'] ?? 4095);
    final soilMoisture = _parseDouble(data['soil_moisture'] ?? 0);

    // Use soil_moisture directly (0-100%) as the water level
    final waterLevel = (soilMoisture / 100).clamp(0.0, 1.0);

    // humidity: optimised for houseplants (50-80% is ideal)
    final humRaw = _parseDouble(data['humidity'] ?? 0);
    final humidity = _normalizeHumidity(humRaw);

    // temperature: optimised for houseplants (20-28°C is ideal)
    final temp = _parseDouble(data['temperature'] ?? 0);
    final temperatureLevel = _normalizeTemperature(temp);

    // light_intensity: optimised for houseplants (200-800 lux ideal)
    final lightRaw = _parseDouble(data['light_intensity'] ?? 0);
    final sunlight = _normalizeLight(lightRaw);

    return {
      'water': waterLevel,
      'humidity': humidity,
      'sunlight': sunlight,
      'temperature': temperatureLevel,
      'timestamp': data['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      'raw_data': {
        'soil_raw': soilRaw,
        'soil_moisture': soilMoisture,
        'humidity_raw': humRaw,
        'temperature_raw': temp,
        'light_intensity_raw': lightRaw,
      }
    };
  }

  /// Houseplant-friendly temperature normalisation.
  /// 20-28 °C  →  1.0  (optimal zone)
  /// 0 °C      →  0.0  |  40 °C  →  0.0
  double _normalizeTemperature(double temp) {
    if (temp >= 20 && temp <= 28) return 1.0;
    if (temp < 20) return (temp / 20).clamp(0.0, 1.0);
    // 28→1.0 … 40→0.0
    return ((40 - temp) / 12).clamp(0.0, 1.0);
  }

  /// Houseplant-friendly humidity normalisation.
  /// 50-80 %  →  1.0 | <50 ramps down | >80 ramps down
  double _normalizeHumidity(double hum) {
    if (hum >= 50 && hum <= 80) return 1.0;
    if (hum < 50) return (hum / 50).clamp(0.0, 1.0);
    return ((100 - hum) / 20).clamp(0.0, 1.0);
  }

  /// Houseplant-friendly light normalisation.
  /// 200-800 lux  →  1.0 | <200 ramps down | >800 ramps down
  double _normalizeLight(double lux) {
    if (lux >= 200 && lux <= 800) return 1.0;
    if (lux < 200) return (lux / 200).clamp(0.0, 1.0);
    return ((1500 - lux) / 700).clamp(0.0, 1.0);
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
