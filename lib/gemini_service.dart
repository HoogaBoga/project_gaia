import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../env.dart';


class GeminiService {
  // 1. Get this from Google AI Studio (aistudio.google.com)
  static const String apiKey = Env.googleGeminiApiKey; 
  
  // 2. Use the "Flash" model for speed
  static const String model = "gemini-3-flash-preview"; 

  //identify plant specie using image
  static Future<String> identifyPlantSpecies(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final url = Uri.parse(
          "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey");

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {
                  "inline_data": {
                    "mime_type": "image/jpeg",
                    "data": base64Encode(bytes),
                  }
                },
                {
                  "text":
                      "Identify the plant species in this photo. Respond with a short species name only."
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        if (text is String && text.trim().isNotEmpty) {
          return text.trim();
        }
        return "Unknown species";
      }

      return "Unknown species";
    } catch (e) {
      return "Unknown species";
    }
  }

  static Future<String> getPlantThoughts(double temp, int moisture) async {
    final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey");

    // 3. The "Personality" Prompt
    final prompt = """
      You are Gaia, a sentient plant.
      Sensors: Temp=$temp°C, Moisture=$moisture% (0% is dry, 100% is wet).
      
      Task: Write a 1-sentence reaction. 
      - If moisture < 30%, beg for water.
      - If temp > 30°C, complain about heat.
      - Otherwise, be philosophical.
    """;

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [{"parts": [{"text": prompt}]}]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      }
      return "Gaia is sleeping... (API Error)";
    } catch (e) {
      return "Gaia can't speak right now.";
    }
  }
}
