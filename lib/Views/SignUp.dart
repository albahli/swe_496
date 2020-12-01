import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:swe496/Views/SignIn.dart';
import 'package:swe496/Database/Validators.dart';
import 'package:get/get.dart';
import 'package:swe496/controllers/UserControllers/authController.dart';

class SignUp extends GetWidget<AuthController> {
  final formKey = GlobalKey<FormState>();
  bool loading = false; // loading screen

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  // Error message
  String error;

  @override
  Widget build(BuildContext context) {
    return loading
        ? CircularProgressIndicator()
        : Scaffold(
            resizeToAvoidBottomPadding: false,
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: Theme(
                  data: ThemeData(
                  ),
                  child: Form(
                    key: formKey,
                    // track the state of the form and help to validate it
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
                            Container(), // App's Logo should be placed here
                            SizedBox(
                              width: 300,
                              child: TextFormField(
                                controller: _usernameController,
                                validator: (usernameVal) =>
                                    Validate.validateUsername(usernameVal),
                                onSaved: (usernameVal) =>
                                    _usernameController.text = usernameVal,
                                decoration: InputDecoration(
                                    labelText: 'Username',
                                    hintText: 'Mohammad123',
                                    prefixIcon: Icon(Icons.alternate_email)),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: 300,
                              child: TextFormField(
                                controller: _emailController,
                                validator: (emailVal) =>
                                    Validate.validateEmail(emailVal),
                                onSaved: (emailVal) =>
                                    _emailController.text = emailVal,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'example@example.com',
                                    prefixIcon: Icon(Icons.mail_outline)),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: 300,
                              child: TextFormField(
                                controller: _nameController,
                                validator: (nameVal) =>
                                    Validate.validateName(nameVal),
                                onSaved: (nameVal) =>
                                    _nameController.text = nameVal,
                                decoration: InputDecoration(
                                    labelText: 'Name',
                                    hintText: 'Mohammad',
                                    prefixIcon: Icon(Icons.person_outline)),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                                width: 300,
                                child: TextFormField(
                                  controller: _birthDateController,
                                  validator: (birthDateVal) =>
                                      Validate.validateBirthDate(birthDateVal),
                                  decoration: InputDecoration(
                                      labelText: 'Birth Date',
                                      hintText: '1999-01-01',
                                      fillColor: Colors.black,
                                      prefixIcon: Icon(Icons.date_range)),
                                  onTap: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: DateTime(2000),
                                      firstDate: DateTime(1970),
                                      lastDate: DateTime.now(),
                                      builder:
                                          (BuildContext context, Widget child) {
                                        return Theme(
                                          data: ThemeData.light().copyWith(
                                              primaryColor:
                                                  const Color(0xFFE53935),
                                              //Head background
                                              accentColor: const Color(
                                                  0xFFE53935) //selection color
                                              ),
                                          child: child,
                                        );
                                      },
                                    ).then((date) {
                                      if (date.toString().length >=
                                          10) // to avoid exception
                                        _birthDateController.text =
                                            date.toString().substring(0, 10);
                                    });
                                  },
                                )),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: 300,
                              child: TextFormField(
                                obscureText: true,
                                maxLength: 15,
                                validator: (passwordVal) =>
                                    Validate.validatePassword(passwordVal),
                                decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'At least 6 characters',
                                    prefixIcon: Icon(Icons.lock_outline)),
                                onSaved: (passwordVal) =>
                                    _passwordController.text = passwordVal,
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
                                onPressed: () {
                                  formKey.currentState.save();
                                  if (formKey.currentState.validate()) {
                                    controller.signUp(
                                        _emailController.text,
                                        _passwordController.text,
                                        _usernameController.text,
                                        _nameController.text,
                                        _birthDateController.text);
                                  }
                                },
                                child: Row(
                                  children: <Widget>[
                                    const Text('Sign Up',
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
                          onTap: () {
                            Get.offAll(SignIn(), transition: Transition.fade);
                          }, //Open some form to register
                          child: Text(
                            "Already have an account? Sign In",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  )),
            ));
  }
}
