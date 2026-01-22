import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../env.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _model =
      'gemini-3-flash-preview'; //change this to try other models

  static const String _imageModel = "gemini-2.5-flash-image";

  final String apiKey;

  GeminiService({String? apiKey}) : apiKey = apiKey ?? Env.googleGeminiApiKey;

  Future<String> generateChatResponse(String userMessage) async {
    final uri = Uri.parse(
      '$_baseUrl/$_model:generateContent?key=$apiKey',
    );

    final body = {
      'contents': [
        {
          'parts': [
            {
              'text': userMessage,
            }
          ]
        }
      ]
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gemini API error: ${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    // Basic extraction of the text response
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      return 'Sorry, I could not think of a response.';
    }

    final content = candidates[0]['content'];
    if (content == null) {
      return 'Sorry, I could not think of a response.';
    }

    final parts = content['parts'] as List?;
    if (parts == null || parts.isEmpty) {
      return 'Sorry, I could not think of a response.';
    }

    final text = parts[0]['text'] as String?;
    return text ?? 'Sorry, I could not think of a response.';
  }

  Future<Uint8List?> generateImage(String prompt) async {
    // LOG 1: Prove the function was actually called
    print("🚀 [GeminiService] Starting Image Generation...");
    print("🎯 [GeminiService] Model: $_imageModel");
    print("📝 [GeminiService] Prompt: $prompt");

    final uri = Uri.parse('$_baseUrl/$_imageModel:generateContent?key=$apiKey');

    final body = {
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ],
      "generationConfig": {
        // If you are using gemini-3-pro-image-preview, try capitalizing this to "IMAGE" just in case
        "responseModalities": ["IMAGE"]
      }
    };

    try {
      // LOG 2: Prove we are about to send data
      print("Rx [GeminiService] Sending request to Google...");

      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(body),
          )
          .timeout(
              const Duration(seconds: 15)); // << FORCE FAIL after 15 seconds

      // LOG 3: We got a response! Print the code.
      print(
          "✅ [GeminiService] Response Received! Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Optional: Print a snippet of the JSON to prove it's real
        // print("📄 [GeminiService] JSON preview: ${response.body.substring(0, 100)}...");

        final candidates = data["candidates"] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final parts = candidates[0]["content"]["parts"] as List;
          final imagePart = parts.firstWhere(
            (p) => p.containsKey("inlineData"),
            orElse: () => null,
          );
          if (imagePart != null) {
            print("🎉 [GeminiService] Image Data Found! Decoding...");
            return base64Decode(imagePart["inlineData"]["data"]);
          } else {
            print(
                "⚠️ [GeminiService] Candidates found, but NO 'inlineData' (image) present.");
          }
        } else {
          print(
              "⚠️ [GeminiService] Response valid (200), but 'candidates' list is empty.");
        }
      } else {
        // LOG 4: The server rejected us. Print WHY.
        print("❌ [GeminiService] API Error: ${response.body}");
      }
    } catch (e) {
      // LOG 5: We crashed (Network error, Timeout, etc)
      print("🔥 [GeminiService] CRITICAL EXCEPTION: $e");
    }

    return null;
  }

  Future<String> identifyPlantSpecies(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final url = Uri.parse(
          "https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey");

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

  Future<String> getPlantThoughts(double temp, int moisture) async {
    final url = Uri.parse(
        "https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$apiKey");

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
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
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
