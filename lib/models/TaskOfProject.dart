import 'Message.dart';

class TaskOfProject {
  String taskID;
  String taskName;
  String taskDescription;
  String taskStatus;
  String taskPriority;
  String startDate;
  String dueDate;
  String isAssigned;
  String assignedBy;
  String assignedTo;
  List<TaskOfProject> subtask;
  List<Message> message;
  TaskOfProject(
      {this.taskID,
        this.taskName,
        this.taskDescription,
        this.taskStatus,
        this.taskPriority,
        this.startDate,
        this.dueDate,
        this.isAssigned,
        this.assignedBy,
        this.assignedTo,
        this.subtask,
        this.message});

  TaskOfProject.fromJson(Map<String, dynamic> json) {
    taskID = json['taskID'];
    taskName = json['taskName'];
    taskDescription = json['taskDescription'];
    taskStatus = json['taskStatus'];
    taskPriority = json['taskPriority'];
    startDate = json['startDate'];
    dueDate = json['dueDate'];
    isAssigned = json['isAssigned'];
    assignedBy = json['assignedBy'];
    assignedTo = json['assignedTo'];
    if (json['subTask'] != null) {
      subtask = new List<TaskOfProject>();
      json['subTask'].forEach((v) {
        subtask.add(new TaskOfProject.fromJson(Map<String,dynamic>.from(v)));
      });
    }
    if (json['message'] != null) {
      message = new List<Message>();
      json['message'].forEach((v) {
        message.add(new Message.fromJson(Map<String,dynamic>.from(v)));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['taskID'] = this.taskID;
    data['taskName'] = this.taskName;
    data['taskDescription'] = this.taskDescription;
    data['taskStatus'] = this.taskStatus;
    data['taskPriority'] = this.taskPriority;
    data['startDate'] = this.startDate;
    data['dueDate'] = this.dueDate;
    data['isAssigned'] = this.isAssigned;
    data['assignedBy'] = this.assignedBy;
    data['assignedTo'] = this.assignedTo;
    if (this.subtask != null) {
      data['subTask'] = this.subtask.map((v) => v.toJson()).toList();
    }
    if (this.message != null) {
      data['message'] = this.message.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
