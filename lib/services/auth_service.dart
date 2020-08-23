import 'package:firebase_auth/firebase_auth.dart';
import 'package:swe496/services/database.dart';
import 'package:password/password.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Stream<String> get onAuthStateChanged => _firebaseAuth.onAuthStateChanged.map(
      (FirebaseUser user) => user?.uid,
  );

  // Get UID of current user
  Future<String> getUserUID() async{
    String uid = (await _firebaseAuth.currentUser()).uid;
    return uid;
  }

  // Email & Password Sign Up
  Future<String> createUserWithEmailAndPassword(String email, String password, String username, String name, String birthDate) async {

    final currentUser = await _firebaseAuth.createUserWithEmailAndPassword(email: email.trim(), password: password.trim());
    // Encrypting the password

    String hashedPassword = Password.hash(password.trim(), new PBKDF2());

    // Create a new document for the user with uid
    await DatabaseService(uid: currentUser.uid).setNewUserProfile(username.toLowerCase().trim(), email.trim(), hashedPassword, name.trim(), birthDate.trim());

    return currentUser.uid;
  }

  // Email & Password Sign In
  Future<String> signInWithEmailAndPassword(String email, String password) async{
    return (await _firebaseAuth.signInWithEmailAndPassword(email: email.trim(), password: password)).uid;
  }

  // Sign Out
  signOut(){
    return _firebaseAuth.signOut();
  }

  // Reset password
  Future sendPasswordResetEmail(String email) async{
    try {
      return _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      print(e);

    }
  }
}
class UsernameValidator {


  static String validate(String value){

    if(value.isEmpty)
      return "Username can't be empty";

    if(value.length<2)
      return"Username must be at least 2 characters long";

    if(value.length>30)
      return"Username must be 30 characters or less";
    return null;
  }
}

class NameValidator {
  static String validate(String value){

    if(value.isEmpty)
      return "Name can't be empty";

    if(value.length<2)
      return"Name must be at least 2 characters long";

    if(value.length>30)
      return"Name must be less 30 characters or less";
    return null;
  }
}

class EmailValidator {
  static String validate(String value){
    if(value.isEmpty){
      return "Email can't be empty";
    }
    return null;
  }
}

class PasswordValidator {
  static String validate(String value){
    if(value.isEmpty){
      return "Password can't be empty";
    }
    return null;
  }
}