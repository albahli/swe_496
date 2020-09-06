import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
     return isLoading ? showLoadingScreen : SizedBox();
  }

  Widget showLoadingScreen() {
    return Container(
      color: Colors.white,
      child: Center(
        child: SpinKitThreeBounce(
          color: Colors.red,
          size: 50,
        ),
      ),
    );
  }
}
