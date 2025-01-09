import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationChannels {
  // High importance notification channel for chat notifications
  static const AndroidNotificationChannel highImportanceChannel =
      AndroidNotificationChannel(
    'high_importance_channel', // id
    'Chat Notifications', // title
    importance: Importance.max,
    description: 'Show chat notifications',
  );

  // Low importance notification channel for request notifications
  static const AndroidNotificationChannel lowImportanceChannel =
      AndroidNotificationChannel(
    'low_importance_channel', // id
    'Request Notifications', // title
    importance: Importance.min,
    description: 'Show request notifications',
  );
}