import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:swe496/controllers/userController.dart';
import 'package:swe496/models/User.dart';
import 'package:flutter/material.dart';
import 'package:password/password.dart';
import 'package:swe496/services/database.dart';

class AuthController extends GetxController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Rx<FirebaseUser> _firebaseUser = Rx<FirebaseUser>();

  FirebaseUser get user => _firebaseUser.value;

  // Initialize stream from firebase
  @override
  void onInit() {
    _firebaseUser.bindStream(_auth.onAuthStateChanged);
  }

  void createUser(String email, String password, String username, String name,
      String birthDate) async {
    try {
      // Check first if username is taken
      bool userTaken = await Database()
          .checkIfUsernameIsTaken(username.toLowerCase().trim());
      if (userTaken) throw FormatException("Username is taken");

      // Create the user in the Authentication first
      final firebaseUser = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password.trim());

      // Encrypting the password
      String hashedPassword = Password.hash(password.trim(), new PBKDF2());

      // Create new list of project for the user
      List<String> listOfProjects = new List();

      // Create new list of friends for the user
      List<String> listOfFriends = new List();

      // Creating user object and assigning the parameters
      User _user = new User(
        userID: firebaseUser.uid,
        userName: username.toLowerCase().trim(),
        email: email.trim(),
        password: hashedPassword,
        name: name,
        birthDate: birthDate.trim(),
        userAvatar: '',
        listOfProjects: listOfProjects,
        listOfFriends: listOfFriends,
      );

      // Create a new user in the fire store database
      if (await Database().createNewUser(_user)) {
        // User created successfully
        Get.find<UserController>().user = _user;
        Get.back();
      }
    } catch (e) {
      Get.snackbar(
        "Error.", // title
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
      FirebaseUser firebaseUser = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      Get.find<UserController>().user = await Database().getUser(firebaseUser.uid);
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

  void signOut() async {
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
}
