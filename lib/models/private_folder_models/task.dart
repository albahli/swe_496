import 'package:flutter/foundation.dart';
import 'package:swe496/models/private_folder_models/comment.dart';

// Show the tasks we have to bring their data from Firestore and then set that as a model and
// bring it back to the personal folder
class TaskModel {
  String categoryId;
  String taskTitle;
  String taskId;
  DateTime dueDate;
  String state;
  String priority;
  bool completed;

  TaskModel({
    @required this.categoryId,
    @required this.taskId,
    @required this.taskTitle,
    this.dueDate,
    this.state,
    this.priority,
    this.completed,
  });

  // 24 now we set the model the model from Firestore database data
  TaskModel.fromJson(Map<String, dynamic> json) {
    try {
      taskId = json['taskId'];
      categoryId = json['category'];
      taskTitle = json['taskTitle'];
      dueDate = json['dueDate'] == null
          ? null
          : DateTime.fromMicrosecondsSinceEpoch(
              json['dueDate'].microsecondsSinceEpoch);
      state = json['taskState'];
      priority = json['taskPriority'];
      completed = json['completed'];
    } catch (e) {
      print('The error occured in the model $e');
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['taskId'] = this.taskId;
    data['category'] = this.categoryId;
    data['taskTitle'] = this.taskTitle;
    data['dueDate'] = this.dueDate;
    data['taskState'] = this.state;
    data['taskPriority'] = this.priority;
    data['completed'] = this.completed;

    return data;
  }

  // Now we are going to stream the list of all the task models available in the database, so we have to get the
  // data from Firestore and model it here then use the controller to feed it back to the personal folder
}
