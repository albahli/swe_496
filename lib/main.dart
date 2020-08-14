import 'package:flutter/material.dart';
import 'package:swe496/ProjectsGroup//home.dart';
import 'package:swe496/SignUp.dart';
import 'package:swe496/services/auth_service.dart';
import 'SignIn.dart';
import 'package:get/get.dart';
import 'provider_widget.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      auth: AuthService(),
      child: (
           MaterialApp(
             title: "Task management",
             navigatorKey: Get.key,
             home: HomeController(),
             routes: <String, WidgetBuilder>{
               '/SignUp': (BuildContext context) => SignUp(),
               '/home': (BuildContext context) => HomeController(),
             },
           )
      ),
    );

  }
}

class HomeController extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthService auth = Provider.of(context).auth;
    return StreamBuilder(
      stream:  auth.onAuthStateChanged,
      builder: (context, AsyncSnapshot<String> snapshot){
        if(snapshot.connectionState == ConnectionState.active){
          final bool signedIn = snapshot.hasData;
          return signedIn ? ProjectsGroups() : SignIn();
        }
        return CircularProgressIndicator();
      },
    );
  }
}




