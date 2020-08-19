import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:swe496/SignIn.dart';
import 'LoadingScreens/loading.dart';
import 'package:get/get.dart';
import 'services/auth_service.dart';
import 'provider_widget.dart';
import 'Home/GroupProjects.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formKey = GlobalKey<FormState>();
  bool loading = false; // loading screen

  String _username = '';
  String _email = '';
  String _password = '';
  String _name ='';
  // birth date
  var birthDate = TextEditingController();
  // Error message
  String error;



  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
        resizeToAvoidBottomPadding: false,
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
                            validator: (value) {
                              return UsernameValidator.validate(value);
                            },
                            onSaved: (usernameVal){
                              setState(() {
                                _username = usernameVal;
                              });
                            },
                            decoration: InputDecoration(
                                labelText: 'Username',
                                hintText: 'Mohammed123',
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
                            validator: (emailVal) {
                              return EmailValidator.validate(emailVal);
                            },
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'example@example.com',
                                prefixIcon: Icon(Icons.mail_outline)),
                            onSaved: (emailVal) {
                              setState(() {
                                _email = emailVal;
                              });
                            },
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
                            validator: (value) {
                              return NameValidator.validate(value);
                            },
                            onSaved: (nameVal){
                              setState(() {
                                _name = nameVal;
                              });
                            },
                            decoration: InputDecoration(
                                labelText: 'Name',
                                hintText: 'Mohammed',
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
                              controller: birthDate,
                              validator: (birthDate) {
                                return !RegExp(r'^([0-9]{4}[-/]?((0[13-9]|1[012])[-/]?(0[1-9]|[12][0-9]|30)|(0[13578]|1[02])[-/]?31|02[-/]?(0[1-9]|1[0-9]|2[0-8]))|([0-9]{2}(([2468][048]|[02468][48])|[13579][26])|([13579][26]|[02468][048]|0[0-9]|1[0-6])00)[-/]?02[-/]?29)$').hasMatch(birthDate) ? "Enter a Valid date" : null;
                              },
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
                                          primaryColor: const Color(0xFFE53935),
                                          //Head background
                                          accentColor: const Color(
                                              0xFFE53935) //selection color
                                          ),
                                      child: child,
                                    );
                                  },
                                ).then((date) {
                                  if(date.toString().length>=10) // to avoid exception
                                  setState(() {
                                    birthDate.text =
                                        date.toString().substring(0, 10);
                                  });
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
                            validator: (passwordValue) =>
                                passwordValue.length < 6 ||
                                        passwordValue.length > 15
                                    ? 'Password must be 6 - 15 characters'
                                    : null,
                            decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'At lesat 6 characters',
                                prefixIcon: Icon(Icons.lock_outline)),
                            onSaved: (passwordVal) {
                              setState(() {
                                _password = passwordVal;
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
                                setState(() => loading = true );
                                try {
                                  final auth = Provider.of(context).auth;
                                  String uid =
                                      await auth.createUserWithEmailAndPassword(
                                          _email, _password, _username, _name, birthDate.text);
                                  print("Signed Up with New ID $uid");
                                  Get.back(result: 'Successful Registration');
                                } catch (e) {
                                  setState(() {
                                    loading = false;
                                    if(e.message=='The email address is badly formatted.')
                                    {
                                      error = 'Please provide a valid email address in the format: example@example.com';
                                      Get.snackbar(
                                        "The email addres is invalid.", // title
                                        error, // message
                                        icon: Icon(Icons.error_outline, color: Colors.redAccent,),
                                        shouldIconPulse: true,
                                        borderColor: Colors.redAccent,
                                        borderWidth: 1,
                                        barBlur: 20,
                                        isDismissible: true,
                                        duration: Duration(seconds: 15),
                                      );
                                      return;
                                    }
                                    else if(e.message=='The email address is already in use by another account.')
                                    {
                                      error = 'If you already have an account please tap here to sign in.';
                                      Get.snackbar(
                                        "The email address is registerd.", // title
                                        error, // message
                                        icon: Icon(Icons.error_outline, color: Colors.redAccent,),
                                        shouldIconPulse: true,
                                        borderColor: Colors.redAccent,
                                        borderWidth: 1,
                                        barBlur: 20,
                                        isDismissible: true,
                                        onTap: (value){
                                          Get.off(GroupProjects());
                                          return;
                                        },
                                        duration: Duration(seconds: 15),
                                      );
                                      return;
                                    }
                                    error = e.message;
                                    Get.snackbar(
                                      "Error.", // title
                                      error, // message
                                      icon: Icon(Icons.error_outline, color: Colors.redAccent,),
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
                        Get.to(SignIn());
                      }, //Open some form to register
                      child: Text(
                        "Already have an account? Sign In",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              )),
        )
    );
  }
// Not used
  Widget showAlert(){
    if(error != null){
      return Container(
        color: Colors.redAccent,
        width: double.infinity,
        padding: EdgeInsets.all(8),
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(Icons.error_outline),
            ),
            Expanded(
              child: Text(error, maxLines: 3),

            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: (){
                 setState(() {
                   error = null;
                 });
                },
              ),
            )
          ],
        ),
      );
    }
    return SizedBox();
  }
}
