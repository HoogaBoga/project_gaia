import 'package:stacked/stacked.dart';

class HomeViewModel extends BaseViewModel {
  // Placeholder data assumed to be passed from the previous splash/setup screen.
  final String plantName = 'Gaia';
  final String plantSpecies = 'Ficus pseudopalma';

  // Current HP percentage (0.0 to 1.0).
  double currentHpPercent = 0.65;

  // Y-axis offsets for the background circle layers.
  // These variables are set up here so they can be easily animated later
  // by an AnimationController in the View updating these values.
  double layer1Offset = -150.0;
  double layer2Offset = 50.0;
  double layer3Offset = 250.0;

  void initialise() {
    // Initialization logic (e.g., starting animations) would go here.
    notifyListeners();
  }
}
