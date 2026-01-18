import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:project_gaia/ui/widgets/notification/notification_item_model.dart';

class HomeViewModel extends BaseViewModel {
  final String plantName = 'Gaia';
  final String plantSpecies = 'Ficus pseudopalma';

  double currentHpPercent = 0.65;

  double layer1TargetY = 80.0;
  double layer2TargetY = 250.0;
  double layer3TargetY = 420.0;

  // --- NEW CODE START ---

  // 1. State for controlling the overlay visibility
  bool _showNotificationsOverlay = false;
  bool get showNotificationsOverlay => _showNotificationsOverlay;

  // 2. The data list for your notifications
  List<NotificationModel> _notifications = [
    NotificationModel(
      icon: Icons.water_drop,
      iconColor: Colors.blue,
      title: "You forgot to water me :(",
      time: "10:00AM",
    ),
    NotificationModel(
      icon: Icons.wb_sunny_rounded,
      iconColor: Colors.amber,
      title: "I need more sunlight sir...",
      time: "11:00AM",
    ),
  ];

  // Getter to expose the list to the View
  List<NotificationModel> get notifications => _notifications;

  // 3. Logic to toggle visibility (attached to the Bell Icon)
  void toggleNotifications() {
    _showNotificationsOverlay = !_showNotificationsOverlay;
    notifyListeners(); // This tells the UI to rebuild
  }

  // 4. Logic to clear notifications (attached to the Clear button)
  void clearNotifications() {
    _notifications.clear();
    _showNotificationsOverlay = false; // Optionally close the overlay
    notifyListeners();
  }

  // --- NEW CODE END ---

  void initialise() {
    notifyListeners();
  }
}
