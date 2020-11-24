import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:get/get.dart';
import 'package:swe496/Database/UserProfileCollection.dart';
import 'package:password/password.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swe496/controllers/UserControllers/authController.dart';
import 'package:swe496/controllers/UserControllers/userController.dart';




class AccountSettings extends StatefulWidget {
  @override
  _AccountSettingsState createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {

  DateTime _dateTime;

  
    AuthController authController = Get.find<AuthController>();
   UserController userController = Get.find<UserController>();

   File _image;
   final formKeyEmail = GlobalKey<FormState>();
   final formKeyPassword = GlobalKey<FormState>();
  final TextEditingController _newEmail =TextEditingController();
  final TextEditingController _name =TextEditingController();

  final TextEditingController _currentPassword = TextEditingController();
  final TextEditingController _newPassword =TextEditingController();
  final TextEditingController _confirmNewPassword =TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();   

  

 _imgFromGallery() async {
  File image = await  ImagePicker.pickImage(
      source: ImageSource.gallery, imageQuality: 50
  );

  setState(() {
    _image = image;
  });
}


  void editUsername() {
     Alert(
        context: context,
        title: "Edit",
        content: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                icon: Icon(Icons.account_circle),
                labelText: 'Username',
              ),
            ),
          ],
        ),
        buttons: [
          DialogButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "submit",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  void editEmail() {
     Alert(
        context: context,
        title: "Edit",
        content: Form(
                  key: formKeyEmail,
                  child: Column(
            children: <Widget>[
             TextFormField(
                    validator: (value) => 
                    value.isEmpty ? "email can't be empty" : null,
                    controller: _newEmail,
                    onSaved: (newEmailVal) =>
                        _newEmail.text = newEmailVal,
                    decoration: InputDecoration(
                      icon: Icon(Icons.edit),
                      focusedBorder: UnderlineInputBorder(),
                      hintText: 'enter new email',
                      labelText: 'Email',
                    ),
                  ),
             
            ],
          ),
        ),
        buttons: [
          DialogButton(
            onPressed: () async{
              formKeyEmail.currentState.save();
              if (formKeyEmail.currentState.validate()) {
                try{
                  await UserProfileCollection().updateEmail(_newEmail.text, userController.user);
                  await AuthController().updateEmail(_newEmail.text);
                   _newEmail.clear();
                   Navigator.pop(context);
                }catch(e){
                  Get.snackbar('Error', 'error');
                  print("error");
                }
              }
              

            },
            child: Text(
              "submit",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  void editPassword() {
     Alert(
        context: context,
        title: "Edit",
        content: Form(
                  key: formKeyPassword,
                  child: Column(
            children: <Widget>[
               TextFormField(
                    validator: (value) =>
                        value.isEmpty ? "password can't be empty" : null,
                    controller: _currentPassword,
                    onSaved: (currentpassVal) =>
                        _currentPassword.text = currentpassVal,
                    decoration: InputDecoration(
                      icon: Icon(Icons.account_circle),
                      focusedBorder: UnderlineInputBorder(),
                      hintText: 'current password',
                      labelText: 'current password',
                    ),
                    obscureText: true,
                  ),
               TextFormField(
                    validator: (value) =>
                        value.isEmpty ? "password can't be empty" : null,
                    controller: _newPassword,
                    onSaved: (newpassVal) =>
                        _newPassword.text = newpassVal,
                    decoration: InputDecoration(
                      icon: Icon(Icons.account_circle),
                      focusedBorder: UnderlineInputBorder(),
                      hintText: 'new password',
                      labelText: 'new password',
                    ),
                    obscureText: true,
                  ),
              TextFormField(
                    validator: (value) =>
                        value.isEmpty ? "password can't be empty" : null,
                    controller: _confirmNewPassword,
                    onSaved: (confirmpassVal) =>
                        _confirmNewPassword.text = confirmpassVal,
                    decoration: InputDecoration(
                      icon: Icon(Icons.account_circle),
                      focusedBorder: UnderlineInputBorder(),
                      hintText: 'confirm new password',
                      labelText: 'confirm new password',
                    ),
                    obscureText: true,
                  ),
            ],
          ),
        ),
        buttons: [
          DialogButton(
            onPressed: () async {
              
              formKeyPassword.currentState.save();
              if(formKeyPassword.currentState.validate() && _newPassword.text==_confirmNewPassword.text && Password.verify(_currentPassword.text, userController.user.password)){
                try{
                await UserProfileCollection().updatepassword(_newPassword.text,userController.user);
                await AuthController().updatePassword(_newPassword.text);
                _currentPassword.clear();
                _newPassword.clear();
                _confirmNewPassword.clear();
                Navigator.pop(context);
                }catch(e){
                  print(e.toString());
                }
              }else{
                print("error");

              }
              
            } ,
            child: Text(
              "submit",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
                
        ]).show();
        
  }

  void editName() {
     Alert(
        context: context,
        title: "Edit",
        content: Form(
                  key: formKeyEmail,
                  child: Column(
            children: <Widget>[
             TextFormField(
                    validator: (value) => 
                    value.isEmpty ? "Name can't be empty" : null,
                    controller: _name,
                    onSaved: (nameVal) =>
                        _name.text = nameVal,
                    decoration: InputDecoration(
                      icon: Icon(Icons.edit),
                      focusedBorder: UnderlineInputBorder(),
                      hintText: 'Enter new name',
                      labelText: 'Mohammad',
                    ),
                  ),
             
            ],
          ),
        ),
        buttons: [
          DialogButton(
            onPressed: () async{
              formKeyEmail.currentState.save();
              if (formKeyEmail.currentState.validate()) {
                try{
                  await UserProfileCollection().updateName(_name.text, userController.user);
                 
                   _name.clear();
                   Navigator.pop(context);
                }catch(e){
                  print("error");
                }
              }
              

            },
            child: Text(
              "submit",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
          leading:IconButton(
            icon:Icon(Icons.arrow_back),
            onPressed: () {
              Get.back();
            },
          ),
          title: Text('Account settings'),
      ),
      body:Column(
        children: <Widget>[
           Container(
              padding: EdgeInsets.fromLTRB(25, 25, 0, 0),
              child: Row(
              children: <Widget>[
                GestureDetector(
                                  child:  Icon(
                    Icons.account_circle,
                    size: 90,
                  ),
                 onTap: () {
                    _imgFromGallery();
                                
           
                 },
                ),
              SizedBox(width:20),
              
    
              ],
              
            ),
            ),
            SizedBox(height:25.0),
                 
                  ListTile(
                     title: Text('UserName'),
                     subtitle: Text('${userController.user.userName}'),
                     onTap: (){},
                   ),

                   ListTile(
                     title: Text('name'),
                     subtitle: Text('${userController.user.name}'),
                     onTap: () => editName(),
                   ),   
             
                  ListTile(
                     title: Text('Email'),
                     subtitle: Text('${userController.user.email}'),
                     onTap: () => editEmail(),

                  ),
      
                  ListTile(
                     title: Text('Password'),
                     onTap: () => editPassword() ,
                  ),
           
            
                  ListTile(
                     title: Text('Date of birth'),
                     subtitle: Text('${userController.user.birthDate}'),
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
                                            UserProfileCollection().updatBirthDate(_birthDateController.text, userController.user);
                                    });  
                     },
                   ),
            
                  
            
           ],
      ),

      
        
        
      
      
    );
  }
}