import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'PushNotification.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm;

  PushNotificationService(this._fcm);

  Future initialise() async {
    if (Platform.isIOS) {
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    // If you want to test the push notification locally,
    // you need to get the token and input to the Firebase console
    // https://console.firebase.google.com/project/YOUR_PROJECT_ID/notification/compose
    String token = await _fcm.getToken();
    print("FirebaseMessaging token: $token");

    _fcm.configure(
      // Called when the app is in the foreground and receive notification
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        PushNotificationMessage notification;
        if (Platform.isAndroid) {
           notification = PushNotificationMessage(
            title: message['notification']['title'],
            body: message['notification']['body'],
          );
        }
       Get.snackbar(notification.title, notification.body, duration: Duration(seconds: 6));
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }
}