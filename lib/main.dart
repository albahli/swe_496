import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:swe496/controllers/bindings/AuthBinding.dart';
import 'package:get/get.dart';
import 'package:swe496/utils/Notificatoins/NotificationService.dart';
import 'package:swe496/utils/root.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  Widget build(BuildContext context) {
    final pushNotificationService = PushNotificationService(_firebaseMessaging);
    pushNotificationService.initialise();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialBinding: AuthBinding(),
      theme: ThemeData.light(),
      defaultTransition: Transition.noTransition,
      title: "Task", // Name of the app
      home: Root(),
    );
  }
}
