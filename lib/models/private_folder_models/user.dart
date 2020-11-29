import 'package:cloud_firestore/cloud_firestore.dart';

// 6 This is the model from where we're going to put our users models from Firebase authentication service
// ? might you change attributes to public?
class UserModel {
  // 7 we should have the data we need to use in the app from Firebase auth service
  String id;
  String name;
  String email;

  UserModel([this.name, this.id, this.email]);

  // 8 here we inject our Firebase auth service data into Firestore documents of the same name (collection 'users)
  UserModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    this.id = doc.documentID;
    this.name = doc['name'];
    this.email = doc['email'];
  }

  // 9 Then we need a controller for this data, so we created UserController in user_controller.dart file
}
