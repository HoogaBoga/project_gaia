import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../env.dart';

class GeminiNotificationService {
  static const String apiKey = Env.googleGeminiApiKey;

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _model =
      'gemini-3-flash-preview'; // Updated to standard flash model

  // ... existing identifyPlantSpecies method ...

  /// Analyzes sensor data based on species traits and returns a list of notifications.
  Future<List<Map<String, String>>> analyzePlantNeeds({
    required String species,
    required double temp,
    required double humidity,
    required double soilMoisture,
    required double sunlight,
  }) async {
    final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey");

    // We ask for JSON specifically to make parsing easier
    final prompt = """
      You are a smart plant monitoring system for a "$species". 
      
      Current Sensors:
      - Temperature: $temp°C
      - Soil Moisture: $soilMoisture%
      - Humidity: $humidity%
      - Sunlight Level: $sunlight (arbitrary unit)

      Task: 
      1. Analyze if these values are healthy for a SPECIFIC "$species". (e.g., Cacti need low moisture, Ferns need high).
      2. If a value is critically bad, generate a notification.
      3. If all values are acceptable, return an empty list.

      Return ONLY raw JSON (no markdown formatting) in this format:
      [
        {
          "type": "water" | "sun" | "temp" | "humidity" | "general",
          "title": "Short alert title (max 5 words)",
          "severity": "low" | "high"
        }
      ]
    """;

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [{"text": prompt}]
            }
          ],
          "generationConfig": {"response_mime_type": "application/json"}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String text = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Parse the JSON string from Gemini
        final List<dynamic> jsonList = jsonDecode(text);
        return jsonList.map((e) => Map<String, String>.from(e)).toList();
      }
      return [];
    } catch (e) {
      print("Gemini Error: $e");
      return [];
    }
  }

  // ... existing getPlantThoughts method ...
}
