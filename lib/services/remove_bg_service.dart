import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../env.dart';

/// Service for removing image backgrounds using the remove.bg API.
///
/// Uses the HTTP API directly — the most optimal approach since:
/// - Images from Gemini are already in-memory as Uint8List (no disk I/O)
/// - The `http` package is already a project dependency
/// - No CLI binaries to bundle or platform-specific setup needed
class RemoveBgService {
  static const String _apiUrl = 'https://api.remove.bg/v1.0/removebg';

  final String apiKey;

  RemoveBgService({String? apiKey}) : apiKey = apiKey ?? Env.removeBgApiKey;

  /// Removes the background from an in-memory image.
  ///
  /// [imageBytes] — raw image bytes (e.g. PNG/JPEG from Gemini).
  /// [fileName]   — optional filename hint for the API (default: 'image.png').
  /// [size]       — output size: 'auto', 'preview' (up to 0.25 MP, free),
  ///                'small' (up to 0.25 MP), 'medium' (up to 1.5 MP),
  ///                'hd' (up to 4 MP), '4k' (up to 16 MP).
  /// [format]     — 'auto', 'png', or 'zip'.
  ///
  /// Returns the resulting image bytes (PNG with transparent background),
  /// or `null` if the request fails.
  Future<Uint8List?> removeBackground(
    Uint8List imageBytes, {
    String fileName = 'image.png',
    String size = 'auto',
    String format = 'png',
  }) async {
    print(
        '🖼️ [RemoveBgService] Removing background (${imageBytes.length} bytes)...');

    try {
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl))
        ..headers['X-Api-Key'] = apiKey
        ..fields['size'] = size
        ..fields['format'] = format
        ..files.add(
          http.MultipartFile.fromBytes(
            'image_file',
            imageBytes,
            filename: fileName,
          ),
        );

      final streamedResponse = await request.send().timeout(
            const Duration(seconds: 30),
          );

      if (streamedResponse.statusCode == 200) {
        final resultBytes = await streamedResponse.stream.toBytes();
        print(
            '✅ [RemoveBgService] Background removed! Result: ${resultBytes.length} bytes');
        return resultBytes;
      } else {
        final body = await streamedResponse.stream.bytesToString();
        print(
            '❌ [RemoveBgService] API error ${streamedResponse.statusCode}: $body');
        return null;
      }
    } catch (e) {
      print('🔥 [RemoveBgService] Exception: $e');
      return null;
    }
  }
}
