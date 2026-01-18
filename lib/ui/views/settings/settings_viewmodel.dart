import 'package:project_gaia/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:project_gaia/app/app.dialogs.dart';
import 'package:project_gaia/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';

class SettingsViewModel extends BaseViewModel {
  int currentIndex = 0;
  final _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();

  SettingsViewModel();

  void navigateToEditPlantInformation() {
    _navigationService.navigateToEditPlantView();
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

        // TODO : IMPLEMENT

        setBusy(false);
    }
  }
}
