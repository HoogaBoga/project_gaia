import 'package:flutter/material.dart';
import 'package:project_gaia/services/firebase_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:project_gaia/app/app.locator.dart';

class EditPlantViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _firebaseService = locator<FirebaseService>();
  
  final nameController = TextEditingController();
  
  final List<String> personalities = [
    'Calm',
    'Friendly',
    'Playful',
    'Energetic',
    'Wise',
  ];

  String? _selectedPersonality;
  String? get selectedPersonality => _selectedPersonality;

  String _currentSpecies = 'Unknown';

  void initialize() async {
    setBusy(true);
    final profile = await _firebaseService.getPlantProfile();

    if (profile != null) {
      nameController.text = profile['name'] ?? '';
      _selectedPersonality = profile['personality'];
      _currentSpecies = profile['species'] ?? 'Unknown';
    } else {
      nameController.text = "Name Unknown";
      _selectedPersonality = "Unknown";
    }

    notifyListeners();
    setBusy(false);
  }

  void onPersonalityChanged(String? value) {
    if (value != null) {
      _selectedPersonality = value;
      notifyListeners();
    }
  }

  Future<void> saveChanges() async {
    if (nameController.text.isEmpty || _selectedPersonality == null) return;

    setBusy(true);
    
    try {
      await _firebaseService.savePlantProfile(
        species: _currentSpecies,
        name: nameController.text,
        personality: _selectedPersonality!,
      );

      _navigationService.back();
    } catch (e) {
      print("Error saving: $e");
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
