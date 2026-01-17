import 'package:stacked/stacked.dart';

class HomeViewModel extends BaseViewModel {
  final String plantName = 'Gaia';
  final String plantSpecies = 'Ficus pseudopalma';

  double currentHpPercent = 0.65;

  double layer1TargetY = 80.0;
  double layer2TargetY = 250.0;
  double layer3TargetY = 420.0;

  void initialise() {
    // Initialization logic (e.g., starting animations) would go here.
    notifyListeners();
  }
}
