import 'package:stacked/stacked.dart';

class StatsPageViewmodel extends BaseViewModel {
  double waterLevel = 0.0;
  double humidityLevel = 0.0;
  double sunlightLevel = 0.0;
  double temperatureLevel = 0.0;
  double overallHealth = 0.0;

  void initializeData() {
    waterLevel = 0.2;
    humidityLevel = 0.5;
    sunlightLevel = 0.9;
    temperatureLevel = 0.7;

    overallHealth =
        (waterLevel + humidityLevel + sunlightLevel + temperatureLevel) / 4;

    notifyListeners();
  }
}
