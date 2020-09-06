import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:swe496/Views/GroupProjectsView.dart';
import 'package:swe496/controllers/authController.dart';
import 'package:swe496/Views/SignIn.dart';
import 'package:swe496/controllers/userController.dart';

class Root extends GetWidget<AuthController> {
  @override
  Widget build(BuildContext context) {
    return GetX(
      initState: (_) async {
        Get.put<UserController>(UserController());
      },
      builder: (_) {
        if (Get.find<AuthController>().user?.uid != null) {
          return GroupProjects();
        } else {
          return SignIn();
        }
      },
    );
  }
}