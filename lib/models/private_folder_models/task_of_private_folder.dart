import 'package:flutter/foundation.dart';
import 'package:swe496/Database/private_folder_collection.dart';
import 'package:swe496/models/Task.dart';

// Show the tasks we have to bring their data from Firestore and then set that as a model and
// bring it back to the personal folder
class TaskOfPrivateFolder implements Task {
  String categoryId;
  String taskName;
  String taskID;
  DateTime dueDate;
  String taskStatus;
  String taskPriority;
  bool completed;

  TaskOfPrivateFolder({
    @required this.categoryId,
    @required this.taskID,
    @required this.taskName,
    this.dueDate,
    this.taskStatus,
    this.taskPriority,
    this.completed,
  });

  // Set the dar object model from Firestore database JSON object
  TaskOfPrivateFolder.fromJson(Map<String, dynamic> json) {
    try {
      taskID = json['taskID'];
      categoryId = json['category'];
      taskName = json['taskName'];
      dueDate = json['dueDate'] == null
          ? null
          : DateTime.fromMicrosecondsSinceEpoch(
              json['dueDate'].microsecondsSinceEpoch);
      taskStatus = json['taskStatus'];
      taskPriority = json['taskPriority'];
      completed = json['completed'];
    } catch (e) {
      print('The error occured in the model $e');
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['taskID'] = this.taskID;
    data['category'] = this.categoryId;
    data['taskName'] = this.taskName;
    data['dueDate'] = this.dueDate;
    data['taskStatus'] = this.taskStatus;
    data['taskPriority'] = this.taskPriority;
    data['completed'] = this.completed;

    return data;
  }

  Future<void> createTask({
    String userId,
    String categoryId,
    String newTaskTitle,
    DateTime dueDate,
    String state,
    String priority,
  }) async {
    await PrivateFolderCollection().createTask(
        userId: userId,
        categoryId: categoryId,
        newTaskTitle: newTaskTitle,
        dueDate: dueDate,
        state: state,
        priority: priority);
  }

  Future<void> deleteTask({
    @required String userId,
    @required String taskId,
  }) async {
    await PrivateFolderCollection().deleteTask(userId: userId, taskId: taskId);
  }

  Future<void> createSubtask({
    @required String userId,
    @required String parentTaskId,
    @required String subtaskTitle,
    @required DateTime dueDate,
    @required String state,
    @required String priority,
  }) async {
    await PrivateFolderCollection().createSubtask(
        userId: userId,
        parentTaskId: parentTaskId,
        subtaskTitle: subtaskTitle,
        dueDate: dueDate,
        state: state,
        priority: priority);
  }

  Future<void> deleteSubtask({
    @required String userId,
    @required String parentTaskId,
    @required String subtaskId,
  }) async {
    await PrivateFolderCollection().deleteSubtask(
        userId: userId, parentTaskId: parentTaskId, subtaskId: subtaskId);
  }


  Future<void> taskCompletionToggle({
    String userId,
    String taskId,
    bool completionState,
  }) async {

    await PrivateFolderCollection().taskCompletionToggle(userId: userId,taskId: taskId, completionState: completionState);
  }

  Future<void> changeTaskCategory({
    @required String userId,
    @required String taskId,
    @required String newCategoryId,
  }) async {
    await PrivateFolderCollection().changeTaskCategory(userId: userId, taskId: taskId, newCategoryId: newCategoryId);
  }

  Future<void> changeTaskTitle({
    @required String userId,
    @required String taskId,
    @required String newTitle,
  }) async {
    await PrivateFolderCollection().changeTaskTitle(userId: userId, taskId: taskId, newTitle: newTitle);
  }

  Future<void> changeTaskDueDate({
    @required String userId,
    @required String taskId,
    @required DateTime newDueDate,
  }) async {
    await PrivateFolderCollection().changeTaskDueDate(userId: userId, taskId: taskId, newDueDate: newDueDate);
  }

  Future<void> changeStatus({
    @required String userId,
    @required String taskId,
    @required String newState,
  }) async {
    await PrivateFolderCollection().changeStatus(userId: userId, taskId: taskId, newState: newState);
  }

  Future<void> changePriority({
    @required String userId,
    @required String taskId,
    @required String newPriority,
  }) async {
    await PrivateFolderCollection().changePriority(userId: userId, taskId: taskID, newPriority: newPriority);
  }

  Future<bool> taskHasSubtasks(String taskId, String userId) async {
    return await PrivateFolderCollection().taskHasSubtasks(taskId, userId);
  }

  Future<void> subtaskCompletionToggle({
    String userId,
    String parentTaskId,
    String subtaskId,
    bool completionState,
  }) async {
    await PrivateFolderCollection().subtaskCompletionToggle(userId: userId, parentTaskId: parentTaskId, subtaskId: subtaskId, completionState: completionState);
  }

  Future<void> changeSubtaskStatus({
    @required String userId,
    @required String taskId,
    @required String newState,
    @required String subtaskId,
  }) async {
    await PrivateFolderCollection().changeSubtaskStatus(userId: userId, taskId: taskId, newState: newState, subtaskId: subtaskId);
  }

  Future<void> changeSubtaskPriority({
    @required String userId,
    @required String taskId,
    @required String newPriority,
    @required String subtaskId,
  }) async {
    await PrivateFolderCollection().changeSubtaskPriority(userId: userId, taskId: taskId, newPriority: newPriority, subtaskId: subtaskId);
  }


// Now we are going to stream the list of all the task models available in the database, so we have to get the
// data from Firestore and model it here then use the controller to feed it back to the personal folder
}
