import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swe496/models/Chat.dart';
import 'package:swe496/models/Members.dart';
import 'package:swe496/models/Project.dart';
import 'package:swe496/models/User.dart';
import 'package:uuid/uuid.dart';

class ProjectCollection {
  final Firestore _firestore = Firestore.instance;



  Future<void> createNewProject(String projectName, User user) async {
    String projectID =
        Uuid().v1(); // Project ID, UuiD is package that generates random ID

    // Add the creator of the project to the members list and assign him as admin
    var member = Member(
      memberUID: user.userID,
      isAdmin: true,
    );
    List<Member> membersList = new List();
    membersList.add(member);

    // Save his ID in the membersUIDs list
    List<String> membersIDs = new List();
    membersIDs.add(user.userID);

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
      members: membersList,
      membersIDs: membersIDs,
    );

    //print('the length is : ${user.userProjects.length}');

    // Add the new project ID to the user's project list
    user.userProjectsIDs.add(projectID);
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
