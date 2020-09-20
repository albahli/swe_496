class SubTask {
  String subTaskID;
  String subTaskName;
  String subTaskDescription;
  String subTaskStatus;

  SubTask({this.subTaskID, this.subTaskName, this.subTaskDescription, this.subTaskStatus});

  SubTask.fromJson(Map<String, dynamic> json) {
    subTaskID = json['subTaskID'];
    subTaskName = json['subTaskName'];
    subTaskDescription = json['subTaskDescription'];
    subTaskStatus = json['subTaskStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subTaskID'] = this.subTaskID;
    data['subTaskName'] = this.subTaskName;
    data['subTaskDescription'] = this.subTaskDescription;
    data['subTaskStatus'] = this.subTaskStatus;
    return data;
  }
}