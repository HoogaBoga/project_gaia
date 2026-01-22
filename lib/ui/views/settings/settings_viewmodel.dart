import 'package:project_gaia/app/app.router.dart';
import 'package:project_gaia/services/firebase_service.dart';
import 'package:stacked/stacked.dart';
import 'package:project_gaia/app/app.dialogs.dart';
import 'package:project_gaia/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';

class SettingsViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _firebaseService = locator<FirebaseService>();

  String plantName = 'Loading...';
  String species = '';
  String personality = '';

  Future<void> initialize() async {
    setBusy(true);
    final profile = await _firebaseService.getPlantProfile();
    if (profile != null) {
      plantName = profile['name'] ?? 'Gaia';
      species = profile['species'] ?? 'Unknown';
      personality = profile['personality'] ?? 'Friendly';
    } else {
      plantName = 'No Profile Found';
      species = '-';
      personality = 'Default';
    }
    notifyListeners();
    setBusy(false);
  }

  void navigateToEditPlantInformation() async {
    await _navigationService.navigateToEditPlantView();
    await initialize();
  }

  Future<void> openDeletePlantDialog() async {
    final DialogResponse? response = await _dialogService.showCustomDialog(
      variant: DialogType.deletePlant,
      title: 'Delete Plant Permanently?',
      description: "This data will be lost immediately. You won't be unable to undo this action.",
      mainButtonTitle: 'Delete',
      secondaryButtonTitle: 'Cancel',
    );

    if (response?.confirmed == true) {
        setBusy(true);

        await _firebaseService.deletePlantData();

        setBusy(false);

        _navigationService.clearStackAndShow(Routes.splashView);
    }
  }
}
