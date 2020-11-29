import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swe496/Database/private_folder_collection.dart';
import 'package:swe496/models/User.dart';

import 'package:uuid/uuid.dart';

import '../models/User.dart';

class UserProfileCollection {
  final Firestore _firestore = Firestore.instance;

  Future<bool> createNewUser(User user) async {
    try {
      await Firestore.instance
          .collection('userProfile')
          .document(user.userID)
          .setData(user.toJson());

      // Create the default category of the private folder
      await PrivateFolderCollection()
          .createCategory(user.userID, 'Tasks List:');
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<User> getUser(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('userProfile').document(uid).get();

      return User.fromJson(userDoc.data);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<bool> checkIfUsernameIsTaken(String username) async {
    bool userNameIsTaken = false;
    await Firestore.instance
        .collection('userProfile')
        .getDocuments()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.documents.forEach((doc) {
                String usr = doc["userName"];
                print("searching in profiles => $usr");
                print("my user is => $username");
                if (username.toLowerCase().trim() == usr) {
                  print('username is taken : $usr');
                  userNameIsTaken = true;
                  return;
                }
              })
            });
    return userNameIsTaken;
  }

  Stream<QuerySnapshot> checkUserProjectsIDs(String projectID) {
    return Firestore.instance
        .collection('userProfile')
        .where('userProjectsIDs', arrayContains: projectID)
        .snapshots();
  }
}
