// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// void initNitification() {
//   var android = AndroidInitializationSettings('@mipmap/ic_launcher');
//   InitializationSettings initializationSettings =
//       InitializationSettings(android: android);
//   flutterLocalNotificationsPlugin.initialize(
//     initializationSettings,
//   );
// }

// Future<void> showNotification(
//   String title,
//   String body, {
//   dynamic payload,
// }) async {
//   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//       AndroidNotificationDetails("channel_id", 'filwallet_channel',
//           'channnel for filwallet notification',
//           importance: Importance.max, priority: Priority.high, ticker: '');
//   const NotificationDetails platformChannelSpecifics =
//       NotificationDetails(android: androidPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin
//       .show(DateTime.now().millisecond, title, body, platformChannelSpecifics, payload: payload);
// }
