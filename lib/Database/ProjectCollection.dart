import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:swe496/controllers/UserControllers/userController.dart';
import 'package:swe496/models/Activity.dart';
import 'package:swe496/models/Chat.dart';
import 'package:swe496/models/Event.dart';
import 'package:swe496/models/Members.dart';
import 'package:swe496/models/Message.dart';
import 'package:swe496/models/Project.dart';
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

    // Record this action in the activity log of the project
    insertIntoActivityLog(projectID, "Created new task '$_taskName'");

    String taskID =
        Uuid().v1(); // Task ID, UuiD is package that generates random ID.

    // Creating a list of sub tasks for that task.
    List<TaskOfProject> subTasksList = new List();

    // Creating a list of messages/comment for that task.
    List<Message> messagesList = new List();

    // Splitting the username and the ID by (,)
    List listOfUserNameAndID = _taskAssignedTo.split(',');

    // Creating the task object for the project
    TaskOfProject taskOfProject = new TaskOfProject(
      taskID: taskID,
      taskName: _taskName,
      taskDescription: _taskDescription,
      startDate: _taskStartDate,
      dueDate: _taskDueDate,
      taskPriority: _taskPriority,
      isAssigned: _taskAssignedTo.isEmpty ? 'false' : 'true',
      // Determine if the task is assigned or not.
      assignedTo: _taskAssignedTo.isEmpty ? '' : listOfUserNameAndID[1],
      // Storing only the user ID
      assignedBy: _taskAssignedBy,
      taskStatus: _taskStatus,
      subtask: subTasksList,
      message: messagesList,
    );

    // Creating the list of tasks for that project.
    List<TaskOfProject> listOfTasks = new List();

    // Adding the task to the list of tasks
    listOfTasks.add(taskOfProject);

    // Convert the task object to JSON
    try {
      var listOfTasksJson = taskOfProject.toJson();

      print(listOfTasksJson);

      return await _firestore
          .collection('projects')
          .document(projectID)
          .collection('tasks')
          .document(taskID)
          .setData(listOfTasksJson);
    } on Exception catch (e) {
      print(e);
    }
  }

  Stream<List<Project>> projectsListStream(String userID) {
    return Firestore.instance
        .collection('projects')
        .where('membersIDs', arrayContains: userID)
        .snapshots()
        .map((QuerySnapshot query) {
      List<Project> retVal = List();
      query.documents.forEach((element) {
        retVal.add(Project.fromJson(element.data));
      });
      return retVal;
    });
  }

  Stream<Project> projectStream(String projectID) {
    return _firestore
        .collection('projects')
        .document(projectID)
        .snapshots()
        .map((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.data == null) {
        return null;
      }
      return Project.fromJson(documentSnapshot.data);
    });
  }

  Future<void> createNewSubtask(
      String projectID,
      String mainTaskID,
      String _subtaskName,
      String _subtaskDescription,
      String _subtaskStartDate,
      String _subtaskDueDate,
      String _subtaskPriority,
      String _subtaskStatus) async {

    // Record this action in the activity log of the project
    insertIntoActivityLog(projectID, "Created new subtask '$_subtaskName'");

    String subtaskID =
        Uuid().v1(); // Task ID, UuiD is package that generates random ID.

    // Creating the task object for the project
    TaskOfProject newSubtaskOfProject = new TaskOfProject(
      taskID: subtaskID,
      taskName: _subtaskName,
      taskDescription: _subtaskDescription,
      startDate: _subtaskStartDate,
      dueDate: _subtaskDueDate,
      taskPriority: _subtaskPriority,
      taskStatus: _subtaskStatus,
      isAssigned: 'true',
    );
    // Convert the sub task object to JSON
    var newSubtaskJSON = newSubtaskOfProject.toJson();
    try {
      DocumentReference documentReference = _firestore
          .collection('projects')
          .document(projectID)
          .collection('tasks')
          .document(mainTaskID);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(documentReference);
        if (!snapshot.exists) {
          throw Exception("data does not exist!");
        }
        await transaction.update(
            documentReference,
            ({
              'subTask': FieldValue.arrayUnion([
                newSubtaskJSON,
              ]),
            }));
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> editTask(
      String projectID,
      String taskID,
      String taskName,
      String taskDescription,
      String startDate,
      String dueDate,
      String taskPriority,
      String assignedTo) async {

    // Record this action in the activity log of the project
    insertIntoActivityLog(projectID, "Updated a task '$taskName'");

    List listOfUserNameAndID = assignedTo.split(',');

    try {
      DocumentReference documentReference = _firestore
          .collection('projects')
          .document(projectID)
          .collection('tasks')
          .document(taskID);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(documentReference);
        if (!snapshot.exists) {
          throw Exception("data does not exist!");
        }
        await transaction.update(
            documentReference,
            ({
              "taskName": taskName,
              "taskDescription": taskDescription,
              "startDate": startDate,
              "dueDate": dueDate,
              "taskPriority": taskPriority,
              "assignedTo": assignedTo.isEmpty ? '' : listOfUserNameAndID[1],
              "isAssigned": assignedTo.isEmpty ? 'false' : 'true',
              "taskStatus": 'Not-started'
            }));
      });
      Get.back();
      Get.snackbar('Success', "Task '$taskName' has been updated successfully");
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> deleteTask(
    String projectID,
    String taskID,
  ) async {

    // Record this action in the activity log of the project
    insertIntoActivityLog(projectID, "Deleted a task");

    try {
      DocumentReference documentReference = _firestore
          .collection('projects')
          .document(projectID)
          .collection('tasks')
          .document(taskID);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(documentReference);
        if (!snapshot.exists) {
          throw Exception("data does not exist!");
        }

        await transaction.delete(documentReference);
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> deleteSubtask(
    String projectID,
    String taskID,
    String subtaskID,
    String subtaskName,
    String subtaskDescription,
    String startDate,
    String dueDate,
    String subtaskPriority,
  ) async {

    // Record this action in the activity log of the project
    insertIntoActivityLog(projectID, "Deleted a subtask '$subtaskName'");

    // Creating the task object for the project

    TaskOfProject deletedSubtaskOfProject = new TaskOfProject(
      taskID: subtaskID,
      taskName: subtaskName,
      taskDescription: subtaskDescription,
      startDate: startDate,
      dueDate: dueDate,
      taskPriority: subtaskPriority,
      taskStatus: 'Not-Started',
      isAssigned: 'true',
      assignedBy: null,
      assignedTo: null,
    );
    // Convert the sub task object to JSON
    var deletedSubtaskJSON = deletedSubtaskOfProject.toJson();
    try {
      DocumentReference documentReference = _firestore
          .collection('projects')
          .document(projectID)
          .collection('tasks')
          .document(taskID);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(documentReference);
        if (!snapshot.exists) {
          throw Exception("data does not exist!");
        }

        await transaction.update(
          documentReference,
          {
            'subTask': FieldValue.arrayRemove([deletedSubtaskJSON])
          },
        );
      });
      Get.back();
      Get.snackbar(
          'Success', "Subtask '$subtaskName' has been deleted successfully");
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> editSubtask(
      String projectID,
      String taskID,
      String subtaskID,
      String subtaskName,
      String subtaskDescription,
      String startDate,
      String dueDate,
      String subtaskPriority,
      String oldSubtaskName,
      String oldSubtaskDescription,
      String oldStartDate,
      String oldDueDate,
      String oldSubtaskPriority) async {

    // Record this action in the activity log of the project
    insertIntoActivityLog(projectID, "Updated a subtask '$subtaskName'");

    await deleteSubtask(projectID, taskID, subtaskID, oldSubtaskName,
            oldSubtaskDescription, oldStartDate, oldDueDate, oldSubtaskPriority)
        .then((value) async {
      await createNewSubtask(projectID, taskID, subtaskName, subtaskDescription,
          startDate, dueDate, subtaskPriority, 'Not-Started');
    });

    Get.back();
  }

  Future<void> createNewEvent(
      String projectID,
      String eventName,
      String eventDescription,
      String startDate,
      String endDate,
      String location) async {

    // Record this action in the activity log of the project
    insertIntoActivityLog(projectID, "Created new event '$eventName'");

    String eventID =
        Uuid().v1(); // Event ID, UuiD is package that generates random ID.

    Event event = new Event(
      eventID: eventID,
      eventName: eventName.trim(),
      eventDescription: eventDescription,
      eventStartDate: startDate,
      eventEndDate: endDate,
      eventLocation: location,
    );

    try {
      var eventJson = event.toJson();

      return await _firestore
          .collection('projects')
          .document(projectID)
          .collection('events')
          .document(eventID)
          .setData(eventJson);
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> editEvent(
      String projectID,
      String eventID,
      String eventName,
      String eventDescription,
      String startDate,
      String endDate,
      String location) async {

    // Record this action in the activity log of the project
    insertIntoActivityLog(projectID, "Updated an event '$eventName'");

    try {
      DocumentReference documentReference = _firestore
          .collection('projects')
          .document(projectID)
          .collection('events')
          .document(eventID);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(documentReference);
        if (!snapshot.exists) {
          throw Exception("data does not exist!");
        }

        await transaction.update(
            documentReference,
            ({
              "eventName": eventName,
              "eventDescription": eventDescription,
              "eventStartDate": startDate,
              "eventEndDate": endDate,
              "eventLocation": location,
            }));
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> deleteEvent(String projectID, String eventID) async {

    // Record this action in the activity log of the project
    insertIntoActivityLog(projectID, 'Deleted an event');

    try {
      DocumentReference documentReference = _firestore
          .collection('projects')
          .document(projectID)
          .collection('events')
          .document(eventID);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(documentReference);
        if (!snapshot.exists) {
          throw Exception("data does not exist!");
        }

        await transaction.delete(documentReference);
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  // To view the tasks in the "tasks & events" tab for the admin.
  Stream<List<TaskOfProject>> getTasksOfProjectAssignedByAdmin(
      String projectID, String assignedBy) {
    return _firestore
        .collection('projects')
        .document(projectID)
        .collection('tasks')
        .where('assignedBy', isEqualTo: assignedBy)
        .snapshots()
        .map((QuerySnapshot query) {
      List<TaskOfProject> retVal = List();
      query.documents.forEach((element) {
        retVal.add(TaskOfProject.fromJson(element.data));
      });
      return retVal;
    });
  }

  // To view the tasks in the "tasks & events" tab for the assigned member.
  Stream<List<TaskOfProject>> getTasksOfProjectAssignedToMember(
      String projectID, String assignedTo) {
    return _firestore
        .collection('projects')
        .document(projectID)
        .collection('tasks')
        .where('assignedTo', isEqualTo: assignedTo)
        .snapshots()
        .map((QuerySnapshot query) {
      List<TaskOfProject> retVal = List();
      query.documents.forEach((element) {
        retVal.add(TaskOfProject.fromJson(element.data));
      });
      return retVal;
    });
  }

  Stream<List<Event>> getEventsOfProject(String projectID) {
    return _firestore
        .collection('projects')
        .document(projectID)
        .collection('events')
        .snapshots()
        .map((QuerySnapshot query) {
      List<Event> retVal = List();
      query.documents.forEach((element) {
        retVal.add(Event.fromJson(element.data));
      });
      return retVal;
    });
  }

  // To view the task details in TaskView.dart
  Stream<List<TaskOfProject>> taskStream(String projectID, String taskID) {
    return _firestore
        .collection('projects')
        .document(projectID)
        .collection('tasks')
        .where('taskID', isEqualTo: taskID)
        .snapshots()
        .map((QuerySnapshot query) {
      List<TaskOfProject> retVal = List();
      query.documents.forEach((element) {
        retVal.add(TaskOfProject.fromJson(element.data));
      });
      return retVal;
    });
  }

  Stream<Event> eventStream(String projectID, String eventID) {
    return _firestore
        .collection('projects')
        .document(projectID)
        .collection('events')
        .document(eventID)
        .snapshots()
        .map((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.data == null) {
        return null;
      }
      return Event.fromJson(documentSnapshot.data);
    });
  }

  Future<void> addCommentToTask(String projectID, String taskID,
      String senderID, String from, String contentOfMessage) async {

    insertIntoActivityLog(projectID, 'Added comment to task');

    Message message = new Message(
        messageID: Uuid().v1(),
        senderID: senderID,
        from: from,
        contentOfMessage: contentOfMessage,
        time: Timestamp.now());

    var jsonMessage = message.toJson();

    try {
      DocumentReference documentReference = _firestore
          .collection('projects')
          .document(projectID)
          .collection('tasks')
          .document(taskID);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(documentReference);
        if (!snapshot.exists) {
          throw Exception("data does not exist!");
        }
        await transaction.update(
            documentReference,
            ({
              'message': FieldValue.arrayUnion([
                jsonMessage,
              ]),
            }));
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> updateProjectSettings(String projectID, String projectName,
      String pinnedMessage, bool joiningLinkStatus) async {
    try {
      DocumentReference documentReference =
          _firestore.collection('projects').document(projectID);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(documentReference);
        if (!snapshot.exists) {
          throw Exception("data does not exist!");
        }
        await transaction.update(
            documentReference,
            ({
              'projectName': projectName,
              'pinnedMessage': pinnedMessage,
              'isJoiningLinkEnabled': joiningLinkStatus
            }));
      });
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<void> insertIntoActivityLog(
      String projectID, String typeOfAction) async {
    String activityID =
        Uuid().v1(); // Activity ID, UuiD is package that generates random ID.

    Activity activity = new Activity(
      activityID: activityID,
      typeOfAction: typeOfAction,
      doneBy: Get.find<UserController>().user.userName,
      date: Timestamp.now()
    );

    // Convert the activity object to JSON

    var activityJSON = activity.toJson();


    try {
      return await _firestore
          .collection('projects')
          .document(projectID)
          .collection('activityLog')
          .document(activityID)
          .setData(activityJSON);
    } on Exception catch (e) {
      print(e);
    }
  }

  Stream<List<Activity>> streamActivityLogOfProject(String projectID) {
    return _firestore
        .collection('projects')
        .document(projectID)
        .collection('activityLog')
        .snapshots()
        .map((QuerySnapshot query) {
      List<Activity> retVal = List();
      query.documents.forEach((element) {
        retVal.add(Activity.fromJson(element.data));
      });
      return retVal;
    });
  }

  Future<void> deleteProject(String projectID) async {
    try {
      DocumentReference documentReference =
          _firestore.collection('projects').document(projectID);

      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(documentReference);
        if (!snapshot.exists) {
          throw Exception("data does not exist!");
        }
        await transaction.delete(documentReference);
      });
    } on Exception catch (e) {
      print(e);
    }
  }
}
