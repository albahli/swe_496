import 'package:swe496/Database/ProjectCollection.dart';
import 'package:swe496/models/Task.dart';

import 'Message.dart';

class TaskOfProject implements Task {
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
  bool isUpdatedByLeader;
  bool isUpdatedByAssignedMember;

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
      this.message,
      this.isUpdatedByLeader,
      this.isUpdatedByAssignedMember
      });

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
    isUpdatedByLeader = json['isUpdatedByLeader'];
    isUpdatedByAssignedMember = json['isUpdatedByAssignedMember'];

    if (json['subTask'] != null) {
      subtask = new List<TaskOfProject>();
      json['subTask'].forEach((v) {
        subtask.add(new TaskOfProject.fromJson(Map<String, dynamic>.from(v)));
      });
    }
    if (json['message'] != null) {
      message = new List<Message>();
      json['message'].forEach((v) {
        message.add(new Message.fromJson(Map<String, dynamic>.from(v)));
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
    data['isUpdatedByLeader'] = this.isUpdatedByLeader;
    data['isUpdatedByAssignedMember'] = this.isUpdatedByAssignedMember;
    if (this.subtask != null) {
      data['subTask'] = this.subtask.map((v) => v.toJson()).toList();
    }
    if (this.message != null) {
      data['message'] = this.message.map((v) => v.toJson()).toList();
    }
    return data;
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
    await ProjectCollection().createNewTask(
        projectID,
        _taskName,
        _taskDescription,
        _taskStartDate,
        _taskDueDate,
        _taskPriority,
        _taskAssignedTo,
        _taskAssignedBy,
        _taskStatus);
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
    await ProjectCollection().createNewSubtask(
        projectID,
        mainTaskID,
        _subtaskName,
        _subtaskDescription,
        _subtaskStartDate,
        _subtaskDueDate,
        _subtaskPriority,
        _subtaskStatus);
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
    await ProjectCollection().editTask(projectID, taskID, taskName,
        taskDescription, startDate, dueDate, taskPriority, assignedTo);
  }

  Future<void> deleteTask(
    String projectID,
    String taskID,
  ) async {
    await ProjectCollection().deleteTask(projectID, taskID);
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
      String subtaskStatus) async {
    await ProjectCollection().deleteSubtask(
        projectID,
        taskID,
        subtaskID,
        subtaskName,
        subtaskDescription,
        startDate,
        dueDate,
        subtaskPriority,
        subtaskStatus);
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
      String oldSubtaskPriority,
      String subtaskStatus) async {
    await ProjectCollection().editSubtask(
        projectID,
        taskID,
        subtaskID,
        subtaskName,
        subtaskDescription,
        startDate,
        dueDate,
        subtaskPriority,
        oldSubtaskName,
        oldSubtaskDescription,
        oldStartDate,
        oldDueDate,
        oldSubtaskPriority,
        subtaskStatus);
  }

  Future<void> addCommentToTask(String projectID, String taskID,
      String senderID, String from, String contentOfMessage) async {
    await ProjectCollection()
        .addCommentToTask(projectID, taskID, senderID, from, contentOfMessage);
  }

  Future<void> changeMainTaskStatus(
      String projectID, String taskID, String taskStatus) async {
    await ProjectCollection()
        .changeMainTaskStatus(projectID, taskID, taskStatus);
  }

  Future<void> changeSubtaskStatus(
      String projectID,
      String taskID,
      String subtaskID,
      String subtaskName,
      String subtaskDescription,
      String startDate,
      String dueDate,
      String subtaskPriority,
      String oldSubtaskStatus,
      String newSubTaskStatus) async {
    await ProjectCollection().changeSubtaskStatus(
        projectID,
        taskID,
        subtaskID,
        subtaskName,
        subtaskDescription,
        startDate,
        dueDate,
        subtaskPriority,
        oldSubtaskStatus,
        newSubTaskStatus);
  }
}
