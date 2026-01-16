import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_gaia/app/app.locator.dart';
import 'package:project_gaia/app/app.router.dart';

class SplashViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _imagePicker = ImagePicker();
  
  final plantSpeciesController = TextEditingController();
  String _plantSpecies = '';
  String? _capturedImagePath;

  String get plantSpecies => _plantSpecies;
  String? get capturedImagePath => _capturedImagePath;
  
  bool get canProceed => _plantSpecies.isNotEmpty || _capturedImagePath != null;

  void onPlantSpeciesChanged(String value) {
    _plantSpecies = value.trim();
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
    
    // Process plant data here
    // Example: await processPlantData();
    
    // Navigate to home view (or whichever view you need)
    await _navigationService.navigateToHomeView();
    
    setBusy(false);
  }

  @override
  void dispose() {
    plantSpeciesController.dispose();
    super.dispose();
  }
}