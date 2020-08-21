import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:swe496/Home/GroupProjectsView.dart';
import 'SignUp.dart';
import 'services/auth_service.dart';
import 'provider_widget.dart';
import 'package:flutter/services.dart';
import 'LoadingScreens/loading.dart';



class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final formKey = GlobalKey<FormState>(); // for login
  bool loading = false; // loading screen

  String email = '';
  String password = '';

  final formAccountResetKey = GlobalKey<FormState>(); // for reset dialog
  String emailReset = '';

  // Error to be displayed
  String error;

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Theme(
          data: ThemeData(
            primaryColor: Colors.red,
          ),
          child: Form(
            key: formKey,
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
                          validator: (emailVal) {
                            return EmailValidator.validate(emailVal);
                          },
                          decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'example@example.com',
                              prefixIcon: Icon(Icons.mail_outline)),
                          onSaved: (val) {
                            setState(() {
                              email = val;
                            });
                          }),
                    )
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
                        validator: (passValue) {
                          return PasswordValidator.validate(passValue);
                        },
                        decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: '••••••',
                            prefixIcon: Icon(Icons.lock_outline)),
                        onSaved: (val) {
                          setState(() {
                            password = val;
                          });
                        },
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
                        color: Colors.red,
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(30.0),
                                right: Radius.circular(30.0)),
                            side: BorderSide(color: Colors.red)),
                        onPressed: () async {
                          formKey.currentState.save();
                          if (formKey.currentState.validate()) {
                            setState(() =>  loading = true );
                            try {
                              final auth = Provider.of(context).auth;
                              String uid = await auth
                                  .signInWithEmailAndPassword(email, password);
                              print("Signed In with ID $uid");
                              Get.off(GroupProjects());
                            } catch (e) {
                              setState(() {
                                loading = false;
                                if (e.message ==
                                    'The email address is badly formatted.') {
                                  error =
                                      'Please provide a valid email address in the format: example@example.com.';
                                  Get.snackbar(
                                    "The email addres is invalid.", // title
                                    error, // message
                                    icon: Icon(
                                      Icons.error_outline,
                                      color: Colors.redAccent,
                                    ),
                                    shouldIconPulse: true,
                                    borderColor: Colors.redAccent,
                                    borderWidth: 1,
                                    barBlur: 20,
                                    isDismissible: true,
                                    duration: Duration(seconds: 15),
                                  );
                                  return;
                                } else if (e.message ==
                                    'There is no user record corresponding to this identifier. The user may have been deleted.') {
                                  error =
                                      'If you are new user please tap here to sign up.';
                                  Get.snackbar(
                                    "The email address is not registerd.",
                                    // title
                                    error, // message
                                    icon: Icon(
                                      Icons.error_outline,
                                      color: Colors.redAccent,
                                    ),
                                    shouldIconPulse: true,
                                    borderColor: Colors.redAccent,
                                    borderWidth: 1,
                                    barBlur: 20,
                                    isDismissible: true,
                                    onTap: (value) {
                                      Get.to(SignUp());
                                      return;
                                    },
                                    duration: Duration(seconds: 15),
                                  );
                                  return;
                                } else if (e.message ==
                                    'The password is invalid or the user does not have a password.') {
                                  error =
                                      'The email or the password is incorrect.';
                                  Get.snackbar(
                                    "Sign In failed.", // title
                                    error, // message
                                    icon: Icon(
                                      Icons.error_outline,
                                      color: Colors.redAccent,
                                    ),
                                    shouldIconPulse: true,
                                    borderColor: Colors.redAccent,
                                    borderWidth: 1,
                                    barBlur: 20,
                                    isDismissible: true,
                                    duration: Duration(seconds: 15),
                                  );
                                  return;
                                }
                                error = e.message;
                                Get.snackbar(
                                  "Error.", // title
                                  error, // message
                                  icon: Icon(
                                    Icons.error_outline,
                                    color: Colors.redAccent,
                                  ),
                                  shouldIconPulse: true,
                                  borderColor: Colors.redAccent,
                                  borderWidth: 1,
                                  barBlur: 20,
                                  isDismissible: true,
                                  duration: Duration(seconds: 15),
                                );
                              });
                              print(e.toString());
                              return;
                            }
                          }
                        },
                        child: Row(
                          children: <Widget>[
                            const Text('Sign In',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.w300)),
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
                  onTap: () => showPasswordAlert(context), // Open some form to reset password,
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
                    var registerStatus = await Get.to(SignUp());
                    if(registerStatus == 'Successful Registration')
                      {
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
    );
  }

  void showPasswordAlert(BuildContext context) {
    Alert(
        context: context,
        title: 'Reset your password',
        desc: "We will send you a link to your account's email to reset your password.",
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
                  validator: (value) {
                    return EmailValidator.validate(value);
                  },
                  onSaved: (value) {
                    setState(() {
                      emailReset = value;
                    });
                  },
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

                try {
                  final auth = Provider.of(context).auth;
                  await auth.sendPasswordResetEmail(emailReset);
                  Navigator.pop(context);
                  Get.snackbar(
                    "Success !", // title
                    'We have sent you an email containing a link to reset your password.', // message
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
                }catch(e){
                  print(e);
                  if (e.message ==
                      'The email address is badly formatted.') {
                    error =
                    'Please provide a valid email address in the format: example@example.com.';
                    Get.snackbar(
                      "The email addres is invalid.", // title
                      error, // message
                      icon: Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                      ),
                      backgroundColor: Colors.white70,
                      shouldIconPulse: true,
                      borderColor: Colors.redAccent,
                      borderWidth: 1,
                      barBlur: 20,
                      isDismissible: true,
                      duration: Duration(seconds: 15),
                    );
                    return;
                  } else if (e.message ==
                      'There is no user record corresponding to this identifier. The user may have been deleted.') {
                    error =
                    'If you are new user please tap here to sign up.';
                    Get.snackbar(
                      "The email address is not registerd.",
                      // title
                      error, // message
                      icon: Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                      ),
                      backgroundColor: Colors.white70,
                      shouldIconPulse: true,
                      borderColor: Colors.redAccent,
                      borderWidth: 1,
                      barBlur: 20,
                      isDismissible: true,
                      onTap: (value) {
                        Get.off(SignUp());
                        return;
                      },
                      duration: Duration(seconds: 15),
                    );
                    return;
                  }
                  else{
                    error = e.message;
                    Get.snackbar(
                      "Error !",
                      // title
                      error, // message
                      icon: Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                      ),
                      backgroundColor: Colors.white70,
                      shouldIconPulse: true,
                      borderColor: Colors.redAccent,
                      borderWidth: 1,
                      barBlur: 20,
                      isDismissible: true,
                      duration: Duration(seconds: 15),
                    );
                    return;
                  }
                }
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
