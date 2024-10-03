import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    // initializationSettings  for Android
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    );

    _notificationsPlugin.initialize(
      initializationSettings,

      // onSelectNotification: (String? id) async {
      //   print("onSelectNotification");
      //   if (id != null && id.isNotEmpty) {
      //     print("Router Value1234 $id");

      //    // Assuming you have access to the Navigator's context here
      //     // you can uncomment and use the navigation code as follows:
      //
      //      Navigator.of(context).push(
      //        MaterialPageRoute(
      //         builder: (context) => DemoScreen(
      //            id: id,
      //         ),
      //        ),
      //      );
      //   }
      // },
    );
  }

  static void createanddisplaynotification(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "OnRide",
          "OnRidechannel",
          importance: Importance.max,
          priority: Priority.high,
        ),
      );

      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: message.data['_id'],
      );
    } on Exception catch (e) {
      print('trefd:  $e');
    }
  }
}
