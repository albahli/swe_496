import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swe496/models/Chat.dart';
import 'package:swe496/models/Members.dart';
import 'package:swe496/models/Message.dart';
import 'package:swe496/models/Project.dart';
import 'package:swe496/models/SubTask.dart';
import 'package:swe496/models/TaskOfProject.dart';
import 'package:swe496/models/User.dart';
import 'package:uuid/uuid.dart';

class ProjectCollection {
  final Firestore _firestore = Firestore.instance;

  Future<void> createNewProject(String projectName, User user) async {
    String projectID =
        Uuid().v1(); // Project ID, UuiD is package that generates random ID.

    // Add the creator of the project to the members list and assign him as admin.
    var member = Member(
      memberUID: user.userID,
      isAdmin: true,
    );
    List<Member> membersList = new List();
    membersList.add(member);

    // Save his ID in the membersUIDs list
    List<String> membersIDs = new List();
    membersIDs.add(user.userID);

    List<TaskOfProject> listOfTasks = new List();
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
      task: listOfTasks,
    );

    // Add the new project ID to the user's project list.
    user.userProjectsIDs.add(projectID);
    try {
      // Convert the project object to be a JSON.
      var jsonUser = user.toJson();

      // Send the user JSON data to the fire base.
      await Firestore.instance
          .collection('userProfile')
          .document(user.userID)
          .setData(jsonUser);

      // Convert the project object to be a JSON.
      var jsonProject = newProject.toJson();

      // Send the project JSON data to the fire base.
      return await Firestore.instance
          .collection('projects')
          .document(projectID)
          .setData(jsonProject);
    } catch (e) {
      print(e);
    }
  }

  Future<void> createNewTask(
      String projectID,
      String _taskName,
      String _taskDescription,
      String _taskStartDate,
      String _taskDueDate,
      String _taskPriority,
      String _taskAssignedTo,
      String _taskAssignedBy,
      String _taskStatus) async {
    // Creating a list of sub tasks for that task.
    List<SubTask> subTasksList = new List();

    // Creating a list of messages/comment for that task.
    List<Message> messagesList = new List();

    // Splitting the username and the ID by (,)
    List listOfUserNameAndID = _taskAssignedTo.split(',');

    // Determine if the task is assigned or not.
    String isAssigned = _taskAssignedTo.isEmpty ? 'false' : 'true' ;

    // Creating the task object for the project
    TaskOfProject taskOfProject = new TaskOfProject(
      taskID: Uuid().v1(),
      // Task ID, UuiD is package that generates random ID.
      taskName: _taskName,
      taskDescription: _taskDescription,
      startDate: _taskStartDate,
      dueDate: _taskDueDate,
      taskPriority: _taskPriority,
      isAssigned: isAssigned,
      assignedTo: listOfUserNameAndID[1], // Storing only the user ID
      assignedBy: _taskAssignedBy,
      taskStatus: _taskStatus,
      subTask: subTasksList,
      message: messagesList,
    );

    // Creating the list of tasks for that project.
    List<TaskOfProject> listOfTasks = new List();

    // Adding the task to the list of tasks
    listOfTasks.add(taskOfProject);

    // Convert the task object to JSON
    var listOfTasksJson = taskOfProject.toJson();

    print(listOfTasksJson);
    //TODO: stopped here
     return await Firestore.instance
        .collection('projects')
        .document(projectID)
        .setData({'listOfTasks': listOfTasksJson},  merge: true);
  }
}
