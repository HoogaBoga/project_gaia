import 'dart:convert';
import 'package:http/http.dart' as http;
import '../env.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _model =
      'gemini-3-flash-preview'; //change this to try other models

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
}
