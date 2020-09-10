import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swe496/models/Project.dart';
import 'package:swe496/models/User.dart';
import 'package:uuid/uuid.dart';

class UserProfileCollection {
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
      User user = new User.fromJson(doc.data);
      return user;
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

  Future<void> createNewProject(String projectName, User user) async {
    String projectID =
        Uuid().v1(); // Project ID, UuiD is package that generates random ID

    // Problem that the user is NULL
    print('now inside create method $user');
    print(user.userName);
    print(user.userID);
    print(user.password);

    // Add the creator of the project to the members list and assign him as admin
    var member = MembersRoles(
      memberUID: user.userID,
      isAdmin: true,
    );
    List<MembersRoles> membersRolesList = new List();
    membersRolesList.add(member);

    // Save his ID in the membersUIDs list
    List <MembersUIDs> membersUIDsList = new List();
    membersUIDsList.add(new MembersUIDs(memberUID: user.userID));

    // Create chat for the new project
    var chat = Chat(chatID: projectID);

    // Create the project object
    var newProject = Project(
      projectID: projectID,
      projectName: projectName,
      image: '',
      joiningLink: '$projectID',
      isJoiningLinkEnabled: true,
      pinnedMessage: '',
      chat: chat,
      membersRoles: membersRolesList,
      membersUIDs: membersUIDsList,
    );

    //print('the length is : ${user.userProjects.length}');

    // Add the new project ID to the user's project list
    user.userProjects.add(new UserProjects(projectID: projectID));

    try {
      // Convert the project object to be a JSON
      var jsonUser = user.toJson();

      // Send the user JSON data to the fire base
      await Firestore.instance
          .collection('userProfile')
          .document(user.userID)
          .setData(jsonUser);

      // Convert the project object to be a JSON
      var jsonProject = newProject.toJson();

      // Send the project JSON data to the fire base
      return await Firestore.instance
          .collection('projects')
          .document(projectID)
          .setData(jsonProject);
    } catch (e) {
      print(e);
    }
  }
}
