import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:swe496/Views/SignUp.dart';
import 'package:flutter/services.dart';
import 'package:swe496/LoadingScreens/loading.dart';
import 'package:swe496/Database/Validators.dart';
import 'package:swe496/controllers/UserControllers/authController.dart';

class SignIn extends GetWidget<AuthController> {
  final formKey = GlobalKey<FormState>(); // for login
  bool loading = false; // loading screen

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final formAccountResetKey = GlobalKey<FormState>(); // for reset dialog
  final String emailReset = '';

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Theme(
                data: ThemeData(
                ),
                child: Form(
                  key: formKey,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.075,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                  width: 300,
                                  child: TextFormField(
                                    keyboardType: TextInputType.emailAddress,
                                    controller: emailController,
                                    onSaved: (emailVal) =>
                                        emailController.text = emailVal,
                                    validator: (emailVal) =>
                                        Validate.validateEmail(emailVal),
                                    decoration: InputDecoration(
                                        labelText: 'Email',
                                        hintText: 'example@example.com',
                                        prefixIcon: Icon(Icons.mail_outline)),
                                  ))
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
                                width: 300,
                                child: TextFormField(
                                  obscureText: true,
                                  controller: passwordController,
                                  onSaved: (passwordVal) =>
                                      passwordController.text = passwordVal,
                                  validator: (passValue) => passValue.isEmpty
                                      ? "Password can't be empty"
                                      : null,
                                  decoration: InputDecoration(
                                      labelText: 'Password',
                                      hintText: '••••••',
                                      prefixIcon: Icon(Icons.lock_outline)),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              ButtonTheme(
                                minWidth: 300,
                                height: 50.0,
                                child: RaisedButton(
                                  textColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.horizontal(
                                          left: Radius.circular(30.0),
                                          right: Radius.circular(30.0)),
                                      ),
                                  onPressed: () async {
                                    formKey.currentState.save();
                                    if (formKey.currentState.validate()) {
                                      controller.signIn(emailController.text,
                                          passwordController.text);
                                    }
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      const Text('Sign In',
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w300)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            onTap: () => showPasswordAlert(context),
                            // Open some form to reset password,
                            child: Text(
                              "Forgot password?",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          InkWell(
                            onTap: () async {
                              var registerStatus = await Get.to(SignUp(), transition: Transition.fade);
                              if (registerStatus == 'Successful Registration') {
                                Get.snackbar(
                                  "Registered Successfully !", // title
                                  'You can now sign in to your account.', // message
                                  icon: Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                  ),
                                  shouldIconPulse: true,
                                  borderColor: Colors.green,
                                  borderWidth: 1,
                                  barBlur: 20,
                                  isDismissible: true,
                                  duration: Duration(seconds: 15),
                                );
                              }
                            }, //Open some form to register
                            child: Text(
                              "Don't have an account? Sign Up",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  void showPasswordAlert(BuildContext context) {
    TextEditingController restedEmail = new TextEditingController();
    Alert(
        context: context,
        title: 'Reset your password',
        desc:
            "We will send you a link to your account's email to reset your password.",
        closeFunction: () => null,
        style: AlertStyle(
            animationType: AnimationType.fromBottom,
            animationDuration: Duration(milliseconds: 300),
            descStyle: TextStyle(
              fontSize: 12,
            )),
        content: Theme(
          data: ThemeData(
            primaryColor: Colors.red,
          ),
          child: Form(
            key: formAccountResetKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  validator: (emailVal) => Validate.validateEmail(emailVal),
                  onSaved: (emailVal) => restedEmail.text = emailVal,
                  decoration: InputDecoration(
                    icon: Icon(Icons.mail_outline),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    hintText: 'example@example.com',
                    labelText: 'Email',
                  ),
                ),
              ],
            ),
          ),
        ),
        buttons: [
          DialogButton(
            color: Colors.red,
            radius: BorderRadius.circular(30),
            onPressed: () async {
              formAccountResetKey.currentState.save();
              if (formAccountResetKey.currentState.validate()) {
                await controller.sendPasswordResetEmail(restedEmail.text);
              }
            },
            child: Text(
              "Submit",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w300),
            ),
          )

        ]).show();
  }
}
