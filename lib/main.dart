import 'package:flutter/material.dart';
import 'package:swe496/controllers/bindings/AuthBinding.dart';
import 'package:get/get.dart';
import 'package:swe496/utils/root.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: AuthBinding(),
      theme: ThemeData.light(),
      defaultTransition: Transition.noTransition,
      title: "Task", // Name of the app
      home: Root(),
    );
  }
}
