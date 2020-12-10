import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:password/password.dart';
import 'package:swe496/Database/private_folder_collection.dart';
import 'package:swe496/controllers/UserControllers/authController.dart';
import 'package:swe496/models/User.dart';

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

  Future<void> saveTokenToDatabase(String token) async {
    // Assume user is logged in for this example
    try {
      String userId = Get.find<AuthController>().user.uid;

      await _firestore.collection('userProfile').document(userId).setData({
        'tokens': token,
      }, merge: true);
    } on Exception catch (e) {
      print(e);
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

  Future<void> updateEmail(String email, User user) async {
    try {
      user.email = email;

      // Convert the user object to be a JSON
      var jsonUser = user.toJson();

      //update cloud firestore
      return await Firestore.instance
          .collection('userProfile')
          .document(user.userID)
          .setData(jsonUser);
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateName(String name, User user) async {
    try {
      user.name = name;

      // Convert the user object to be a JSON
      var jsonUser = user.toJson();

      //update cloud firestore
      return await Firestore.instance
          .collection('userProfile')
          .document(user.userID)
          .setData(jsonUser);
    } catch (e) {
      print(e);
    }
  }

  Future<void> updatePassword(String password, User user) async {
    try {
      String hashedPassword = Password.hash(password.trim(), new PBKDF2());
      user.password = hashedPassword;

      // Convert the user object to be a JSON
      var jsonUser = user.toJson();

      //update cloud firestore
      return await Firestore.instance
          .collection('userProfile')
          .document(user.userID)
          .setData(jsonUser);
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateBirthDate(String date, User user) async {
    try {
      user.birthDate = date;

      // Convert the user object to be a JSON
      var jsonUser = user.toJson();

      //update cloud firestore
      return await Firestore.instance
          .collection('userProfile')
          .document(user.userID)
          .setData(jsonUser);
    } catch (e) {
      print(e);
    }
  }

  Future<void> addFriend(String friendUsername, User user) async {
    var friendId;
    try {
      //retrieve friend document
      await Firestore.instance
          .collection('userProfile')
          .where("userName", isEqualTo: friendUsername)
          .limit(1)
          .getDocuments()
          .then((value) {
        value.documents.forEach((element) {
          friendId = element.data["userID"];
          print(element.data);
          User friend = User.fromJson(element.data);

          friend.friendsIDs.add(user.userID);
          var jsonFriend = friend.toJson();
          // update friend document in firebase
          Firestore.instance
              .collection('userProfile')
              .document(friend.userID)
              .setData(jsonFriend);
        });
      });

      print(friendId);

      //add friend username to friends lis
      user.friendsIDs.add(friendId);

      // Convert the user object to be a JSON
      var jsonUser = user.toJson();

      //update cloud firestore
      return await Firestore.instance
          .collection('userProfile')
          .document(user.userID)
          .setData(jsonUser);
    } catch (e) {
      print(e);
    }
  }
}
