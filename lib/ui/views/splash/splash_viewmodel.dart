import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_gaia/app/app.locator.dart';
import 'package:project_gaia/app/app.router.dart';
import 'package:project_gaia/services/firebase_service.dart';
import 'package:project_gaia/services/gemini_service.dart';

enum OnboardingStep {
  plantSpecies,
  plantName,
  plantPersonality,
}

class SplashViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _imagePicker = ImagePicker();
  final _geminiService = locator<GeminiService>();
  final _firebaseService = locator<FirebaseService>();

  final plantSpeciesController = TextEditingController();
  final plantNameController = TextEditingController();

  OnboardingStep _currentStep = OnboardingStep.plantSpecies;
  String _plantSpecies = '';
  String _plantName = '';
  String? _plantPersonality;

  OnboardingStep get currentStep => _currentStep;
  String get plantSpecies => _plantSpecies;
  String get plantName => _plantName;
  String? get plantPersonality => _plantPersonality;

  bool get canProceed {
    switch (_currentStep) {
      case OnboardingStep.plantSpecies:
        return _plantSpecies.isNotEmpty;
      case OnboardingStep.plantName:
        return _plantName.isNotEmpty;
      case OnboardingStep.plantPersonality:
        return _plantPersonality != null;
    }
  }

  void onPlantSpeciesChanged(String value) {
    _plantSpecies = value.trim();
    notifyListeners();
  }

  void onPlantNameChanged(String value) {
    _plantName = value.trim();
    notifyListeners();
  }

  void onPersonalityChanged(String? value) {
    _plantPersonality = value;
    notifyListeners();
  }

  Future<void> openCamera() async {
    setBusy(true);
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        try {
          final species = await _geminiService.identifyPlantSpecies(image.path);
          _plantSpecies = species;
          plantSpeciesController.text = species;
        } catch (e) {
          debugPrint('Error identifying plant species: $e');
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error opening camera: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> navigateToNext() async {
    if (!canProceed) return;

    setBusy(true);

    switch (_currentStep) {
      case OnboardingStep.plantSpecies:
        _currentStep = OnboardingStep.plantName;
        break;

      case OnboardingStep.plantName:
        _currentStep = OnboardingStep.plantPersonality;
        break;

      case OnboardingStep.plantPersonality:
        await _saveOnboardingData();
        // Navigate to the dedicated generation page
        _navigationService.navigateTo(Routes.generatingView);
        break;
    }

    setBusy(false);
    notifyListeners();
  }

  Future<void> _saveOnboardingData() async {
    try {
      await _firebaseService.savePlantProfile(
        species: _plantSpecies,
        name: _plantName,
        personality: _plantPersonality ?? '',
      );
    } catch (e) {
      debugPrint('Failed to save onboarding data: $e');
    }
  }

  @override
  void dispose() {
    plantSpeciesController.dispose();
    plantNameController.dispose();
    super.dispose();
  }
}
