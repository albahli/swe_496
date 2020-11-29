import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:swe496/Views/GroupProjectsView.dart';
import 'package:swe496/controllers/userController.dart';
import 'package:swe496/models/User.dart';
import 'package:flutter/material.dart';
import 'package:password/password.dart';
import 'package:swe496/Database/UserProfileCollection.dart';

class AuthController extends GetxController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<FirebaseUser> _firebaseUser = Rx<FirebaseUser>();

  FirebaseUser get user => _firebaseUser.value;

  // Initialize stream from firebase
  @override
  void onInit() {
    _firebaseUser.bindStream(_auth.onAuthStateChanged);
  }

  void signUp(String email, String password, String username, String name,
      String birthDate) async {
    try {
      // Check first if username is taken
      bool usernameIsTaken = await UserProfileCollection()
          .checkIfUsernameIsTaken(username.toLowerCase().trim());
      if (usernameIsTaken) throw FormatException("Username is taken");

      // Create the user in the Authentication first
      final firebaseUser = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password.trim());

      // Encrypting the password
      String hashedPassword = Password.hash(password.trim(), new PBKDF2());

      // Create new list of project for the user
      List<String> userProjects = new List<String>();

      // Create new list of friends for the user
      List<String> friends = new List<String>();

      // Creating user object and assigning the parameters
      User _user = new User(
        userID: firebaseUser.uid,
        userName: username.toLowerCase().trim(),
        email: email.trim(),
        password: hashedPassword,
        name: name,
        birthDate: birthDate.trim(),
        userAvatar: '',
        userProjectsIDs: userProjects,
        friendsIDs: friends,
      );

      // Create a new user in the fire store database
      await UserProfileCollection().createNewUser(_user);
      // User created successfully
      Get.find<UserController>().user = _user;
      Get.back();
    } catch (e) {
      Get.snackbar(
        "Error", // title
        e.message, // message
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
    }
  }

  void signIn(String email, String password) async {
    try {
      // Signing in
      FirebaseUser firebaseUser = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());

      // Getting user document form firebase

      // Converting the json data to user object
      Get.find<UserController>().user =
          await UserProfileCollection().getUser(firebaseUser.uid);
      print(Get.find<UserController>().user.userName);
    } catch (e) {
      Get.snackbar(
        "Error.", // title
        e.toString(), // message
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
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      Get.find<UserController>().clear();
    } catch (e) {
      Get.snackbar(
        "Error.", // title
        e.toString(), // message
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
    }
  }

  Future sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      Get.back();
      Get.snackbar('Successful',
          'An email sent to you containing a link to reset your password.');
    } catch (e) {
      print(e);
    }
  }
}
