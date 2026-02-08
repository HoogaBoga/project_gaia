import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:project_gaia/app/app.locator.dart';
import 'package:project_gaia/app/app.router.dart';
import 'package:project_gaia/services/firebase_service.dart';
import 'package:project_gaia/services/gemini_service.dart';
import 'package:project_gaia/services/remove_bg_service.dart';

class GeneratingViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _firebaseService = locator<FirebaseService>();
  final _geminiService = locator<GeminiService>();
  final _removeBgService = locator<RemoveBgService>();

  String generationStatus = 'Preparing your plant\'s look…';
  int generationProgress = 0; // 0-3
  bool hasError = false;

  /// Kick off image generation, then navigate to main layout.
  Future<void> startGeneration() async {
    try {
      // Read profile that was already saved by SplashViewModel
      final profile = await _firebaseService.getPlantProfile();
      final species = profile['species'] ?? 'plant';
      final personality = profile['personality'] ?? 'Friendly';

      await _generateAllPlantImages(species, personality);

      // Done – navigate to main app, clearing the nav stack
      _navigationService.clearStackAndShow(Routes.mainLayout);
    } catch (e) {
      hasError = true;
      generationStatus = 'Something went wrong. Please restart the app.';
      debugPrint('❌ Generation error: $e');
      notifyListeners();
    }
  }

  /// Generate all 3 plant images (perfect, warning, critical) in one go.
  Future<void> _generateAllPlantImages(
      String species, String personality) async {
    // Check if images already exist
    final alreadyGenerated = await _firebaseService.hasAllVisuals();
    if (alreadyGenerated) {
      debugPrint('✅ All 3 visuals already exist, skipping generation.');
      return;
    }

    generationProgress = 0;
    generationStatus = 'Preparing your plant\'s look…';
    notifyListeners();

    const String plantId = 'gaia_01';

    // Shared style prefix for consistency across all 3 zones
    final String styleBase =
        'A clean 2D pixel-art sprite of a $species plant in a terracotta pot. '
        'Consistent pixel-art style, same pot shape and size across all variants. '
        'Transparent background, no shadows, no text, no icons, no labels, no floating elements, no UI. '
        'Only the plant and pot, centered, clean edges.';

    final zones = ['perfect', 'warning', 'critical'];
    final Map<String, String> prompts = {
      'perfect': '$styleBase '
          'The plant is vibrant, lush green leaves, upright and healthy. '
          'The pot has ${_getFaceForZone('perfect', personality)} drawn on it.',
      'warning': '$styleBase '
          'The plant is slightly drooping, some yellow leaf edges, looks tired. '
          'The pot has ${_getFaceForZone('warning', personality)} drawn on it.',
      'critical': '$styleBase '
          'The plant is withered, brown crispy leaves, heavily drooping, looks sick. '
          'The pot has ${_getFaceForZone('critical', personality)} drawn on it.',
    };

    final Map<String, String> uploadedUrls = {};

    for (final zone in zones) {
      generationStatus =
          'Generating ${zone} image (${generationProgress + 1}/3)…';
      notifyListeners();

      try {
        debugPrint('🎨 Generating $zone image…');
        final rawImage = await _geminiService.generateImage(prompts[zone]!);

        if (rawImage != null) {
          generationStatus = 'Cleaning up ${zone} image…';
          notifyListeners();

          final cleanImage = await _removeBgService.removeBackground(rawImage);
          final Uint8List finalImage = cleanImage ?? rawImage;

          generationStatus = 'Uploading ${zone} image…';
          notifyListeners();

          final url =
              await _firebaseService.uploadPlantImage(finalImage, plantId);
          if (url != null) {
            uploadedUrls[zone] = url;
            debugPrint('✅ $zone image uploaded: $url');
          }
        } else {
          debugPrint('❌ Failed to generate $zone image');
        }
      } catch (e) {
        debugPrint('❌ Error generating $zone image: $e');
      }

      generationProgress++;
      notifyListeners();
    }

    // Save all 3 URLs to the database
    if (uploadedUrls.length == 3) {
      await _firebaseService.updateAllPlantVisuals(
        perfectUrl: uploadedUrls['perfect']!,
        warningUrl: uploadedUrls['warning']!,
        criticalUrl: uploadedUrls['critical']!,
      );
      debugPrint('✅ All 3 visuals saved to database!');
    } else {
      for (final entry in uploadedUrls.entries) {
        await _firebaseService.updatePlantVisuals(entry.value, entry.key);
      }
      debugPrint('⚠️ Only ${uploadedUrls.length}/3 visuals generated.');
    }
  }

  String _getFaceForZone(String zone, String personality) {
    switch (personality.toLowerCase()) {
      case 'friendly':
        return zone == 'perfect'
            ? 'a warm smiling face with round happy eyes'
            : zone == 'warning'
                ? 'a worried but brave face with concerned round eyes and a wobbly smile'
                : 'a sad face with teary round eyes and a trembling frown';
      case 'calm':
        return zone == 'perfect'
            ? 'a serene peaceful face with half-closed relaxed eyes and a gentle smile'
            : zone == 'warning'
                ? 'a slightly uneasy face with half-open eyes and a flat mouth'
                : 'a sad face with droopy tired eyes and a small sad frown';
      case 'energetic':
        return zone == 'perfect'
            ? 'an excited face with wide sparkling eyes and a big open grin'
            : zone == 'warning'
                ? 'a tired face with half-lidded eyes and a weak smile'
                : 'an exhausted face with X-shaped dizzy eyes and an open frown';
      case 'wise':
        return zone == 'perfect'
            ? 'a thoughtful face with small wise eyes and a gentle knowing smile'
            : zone == 'warning'
                ? 'a contemplative concerned face with furrowed brows and a thin frown'
                : 'a weary face with heavy-lidded eyes and a pained grimace';
      case 'playful':
        return zone == 'perfect'
            ? 'a cheeky face with a winking eye and a mischievous grin'
            : zone == 'warning'
                ? 'a nervous face with one squinted eye and an awkward smile'
                : 'a face with swirly dizzy eyes and a wobbly crying mouth';
      default:
        return zone == 'perfect'
            ? 'a cute simple face with dot eyes and a small smile'
            : zone == 'warning'
                ? 'a face with dot eyes and a flat worried mouth'
                : 'a face with dot eyes and a sad downturned mouth';
    }
  }
}
