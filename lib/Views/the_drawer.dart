import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swe496/controllers/userController.dart';
import 'package:swe496/controllers/authController.dart';
import 'package:multilevel_drawer/multilevel_drawer.dart';

import '../Database/UserProfileCollection.dart';
import '../controllers/authController.dart';
import '../controllers/userController.dart';
import '../utils/root.dart';

class TheDrawer extends StatelessWidget {
  TheDrawer({
    @required this.authController,
  });

  final AuthController authController;

  @override
  Widget build(BuildContext context) {
    return GetX<UserController>(initState: (_) async {
      Get.find<UserController>().user = await UserProfileCollection()
          .getUser(Get.find<AuthController>().user.uid);
    }, builder: (UserController userController) {
      return MultiLevelDrawer(
        header: Container(
          // Header for Drawer
          height: MediaQuery.of(context).size.height * 0.25,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.account_circle,
                    size: 90,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  userController.user.userName == null
                      ? CircularProgressIndicator()
                      : Text('${userController.user.userName}'),
                ],
              ),
            ),
          ),
        ),
        children: [
          // Child Elements for Each Drawer Item
          MLMenuItem(
              leading: Icon(
                Icons.person,
              ),
              content: Text("My Profile"),
              onClick: () {}),
          MLMenuItem(
            leading: Icon(
              Icons.settings,
            ),
            content: Text("Settings"),
            onClick: () {},
          ),
          MLMenuItem(
              leading: Icon(
                Icons.power_settings_new,
              ),
              content: Text(
                "Log out",
              ),
              onClick: () async {
                await authController.signOut();
                Get.offAll(Root());
                print("Signed Out");
              }),
        ],
      );
    });
  }
}
