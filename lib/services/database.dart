import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swe496/models/User.dart';

class Database {
  final Firestore _firestore = Firestore.instance;

  Future<bool> createNewUser(User user) async {
    try {
      await Firestore.instance
          .collection('userProfile')
          .document(user.userID)
          .setData(user.toJson());
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<User> getUser(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('userProfile').document(uid).get();
      return User.fromJson(doc.data);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<bool> checkIfUsernameIsTaken(String username) async {
    bool userNameIsTaken = false;
    await Firestore.instance
        .collection('userProfile').getDocuments()
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
}
