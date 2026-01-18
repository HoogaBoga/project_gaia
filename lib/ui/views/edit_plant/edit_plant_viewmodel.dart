import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:project_gaia/app/app.locator.dart';

class EditPlantViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  
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

  void initialize() {
    nameController.text = "Gaia"; 
    _selectedPersonality = "Friendly"; 
    notifyListeners();
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
    
    // TODO: IMPLEMENT
    
    setBusy(false);
    _navigationService.back();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
