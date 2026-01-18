import 'package:flutter/material.dart';
import 'notification_item.dart';
import 'package:project_gaia/ui/widgets/notification/notification_item_model.dart';
// TODO: Import your NotificationModel path here, e.g.:
// import 'package:your_app/core/models/notification_model.dart'; 

class NotificationsOverlayContainer extends StatelessWidget {
  final List<NotificationModel> notifications; // Accepts data now
  final VoidCallback onClearTapped;

  const NotificationsOverlayContainer({
    Key? key,
    required this.notifications,
    required this.onClearTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 8,
      borderRadius: BorderRadius.circular(24.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dynamically generate widgets from the data list
            ...notifications.map((notification) => NotificationItem(
                  iconData: notification.icon,
                  iconColor: notification.iconColor,
                  title: notification.title,
                  time: notification.time,
                )),
            
            const SizedBox(height: 24),

            TextButton(
              onPressed: onClearTapped,
              child: const Text(
                "Clear",
                style: TextStyle(
                  color: Color(0xFFff5722),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
