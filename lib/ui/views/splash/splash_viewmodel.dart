import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_gaia/app/app.locator.dart';
import 'package:project_gaia/app/app.router.dart';

enum OnboardingStep {
  plantSpecies,
  plantName,
  plantPersonality,
}

class SplashViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _imagePicker = ImagePicker();
  final plantSpeciesController = TextEditingController();
  final plantNameController = TextEditingController();

  OnboardingStep _currentStep = OnboardingStep.plantSpecies;
  String _plantSpecies = '';
  String _plantName = '';
  String? _plantPersonality;
  String? _capturedImagePath;

  OnboardingStep get currentStep => _currentStep;
  String get plantSpecies => _plantSpecies;
  String get plantName => _plantName;
  String? get plantPersonality => _plantPersonality;
  String? get capturedImagePath => _capturedImagePath;

  bool get canProceed {
    switch (_currentStep) {
      case OnboardingStep.plantSpecies:
        return _plantSpecies.isNotEmpty || _capturedImagePath != null;
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
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        _capturedImagePath = image.path;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error opening camera: $e');
    }
  }

  Future<void> navigateToNext() async {
    if (!canProceed) return;

    setBusy(true);

    switch (_currentStep) {
      case OnboardingStep.plantSpecies:
        _currentStep = OnboardingStep.plantName;
        setBusy(false);
        notifyListeners();
        break;
      case OnboardingStep.plantName:
        _currentStep = OnboardingStep.plantPersonality;
        setBusy(false);
        notifyListeners();
        break;
      case OnboardingStep.plantPersonality:
        //actual process plant data wapa koy idea though
        await _navigationService.navigateToHomeView();
        setBusy(false);
        break;
    }
  }

  @override
  void dispose() {
    plantSpeciesController.dispose();
    plantNameController.dispose();
    super.dispose();
  }
}
