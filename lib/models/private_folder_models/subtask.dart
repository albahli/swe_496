import 'package:flutter/foundation.dart';
import 'package:swe496/models/private_folder_models/task_of_private_folder.dart';

class Subtask extends TaskOfPrivateFolder {
  String parentTaskId;
  String subtaskId;
  String subtaskTitle;
  DateTime dueDate;
  String subtaskState;
  String subtaskPriority;
  bool completed;

  Subtask({
    @required this.parentTaskId,
    @required this.subtaskId,
    @required this.subtaskTitle,
    this.dueDate,
    this.subtaskState,
    this.subtaskPriority,
    this.completed,
  });

  Subtask.fromJson(Map<String, dynamic> json) {
    try {
      parentTaskId = json['parentTaskId'];
      subtaskId = json['subtaskId'];
      subtaskTitle = json['subtaskTitle'];
      dueDate = json['dueDate'] == null
          ? null
          : DateTime.fromMicrosecondsSinceEpoch(
              json['dueDate'].microsecondsSinceEpoch);
      subtaskState = json['subtaskState'];
      subtaskPriority = json['subtaskPriority'];
      completed = json['completed'];
    } catch (e) {
      print(
        'catched in >models>private_folder_models>subtask.dart>Subtask.fromJson(p1): $e',
      );
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['parentTaskId'] = this.parentTaskId;
    data['subtaskId'] = this.subtaskId;
    data['subtaskTitle'] = this.subtaskTitle;
    data['dueDate'] = this.dueDate;
    data['subtaskState'] = this.subtaskState;
    data['subtaskPriority'] = this.subtaskPriority;
    data['completed'] = this.completed;

    return data;
  }
}
