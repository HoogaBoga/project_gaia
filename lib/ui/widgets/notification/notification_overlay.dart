import 'package:flutter/material.dart';
import 'notification_item.dart';
import 'package:project_gaia/ui/widgets/notification/notification_item_model.dart';

class NotificationsOverlayContainer extends StatelessWidget {
  final List<NotificationModel> notifications;
  final VoidCallback onClearTapped;

  const NotificationsOverlayContainer({
    Key? key,
    required this.notifications,
    required this.onClearTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Material(
      color: Colors.white,
      elevation: 8,
      borderRadius: BorderRadius.circular(24.0),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: screenWidth * 0.85,
        // FIX 1: Use 'height' instead of 'constraints'. 
        // This forces the container to be exactly 70% of the screen height, 
        // regardless of whether it is empty or full.
        height: screenHeight * 0.7, 
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          // FIX 2: Use MainAxisSize.max so the column fills the Container's height
          mainAxisSize: MainAxisSize.max,
          children: [
            // FIX 3: Use Expanded instead of Flexible. 
            // This forces the ListView to take up all available space, 
            // pushing the "Clear" button to the very bottom.
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                // FIX 4: Remove shrinkWrap (default is false) so it expands to fill the Expanded widget
                children: notifications.map((notification) => NotificationItem(
                      iconData: notification.icon,
                      iconColor: notification.iconColor,
                      title: notification.title,
                      time: notification.time,
                    )).toList(),
              ),
            ),
            
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
