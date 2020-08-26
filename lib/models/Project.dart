class Project {
  String projectID;
  String projectName;
  String image;
  String joiningLink;
  bool isJoiningLinkEnabled;
  String pinnedMessage;
  Chat chat;
  List<Events> events;
  List<Members> members;
  List<TasksOfProject> tasksOfProject;

  Project(
      {this.projectID,
        this.projectName,
        this.image,
        this.joiningLink,
        this.isJoiningLinkEnabled,
        this.pinnedMessage,
        this.chat,
        this.events,
        this.members,
        this.tasksOfProject});

  Project.fromJson(Map<String, dynamic> json) {
    projectID = json['projectID'];
    projectName = json['projectName'];
    image = json['image'];
    joiningLink = json['joiningLink'];
    isJoiningLinkEnabled = json['isJoiningLinkEnabled'];
    pinnedMessage = json['pinnedMessage'];
    chat = json['chat'] != null ? new Chat.fromJson(json['chat']) : null;
    if (json['events'] != null) {
      events = new List<Events>();
      json['events'].forEach((v) {
        events.add(new Events.fromJson(v));
      });
    }
    if (json['members'] != null) {
      members = new List<Members>();
      json['members'].forEach((v) {
        members.add(new Members.fromJson(v));
      });
    }
    if (json['tasksOfProject'] != null) {
      tasksOfProject = new List<TasksOfProject>();
      json['tasksOfProject'].forEach((v) {
        tasksOfProject.add(new TasksOfProject.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['projectID'] = this.projectID;
    data['projectName'] = this.projectName;
    data['image'] = this.image;
    data['joiningLink'] = this.joiningLink;
    data['isJoiningLinkEnabled'] = this.isJoiningLinkEnabled;
    data['pinnedMessage'] = this.pinnedMessage;
    if (this.chat != null) {
      data['chat'] = this.chat.toJson();
    }
    if (this.events != null) {
      data['events'] = this.events.map((v) => v.toJson()).toList();
    }
    if (this.members != null) {
      data['members'] = this.members.map((v) => v.toJson()).toList();
    }
    if (this.tasksOfProject != null) {
      data['tasksOfProject'] =
          this.tasksOfProject.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Chat {
  String chatID;
  List<Message> message;

  Chat({this.chatID, this.message});

  Chat.fromJson(Map<String, dynamic> json) {
    chatID = json['chatID'];
    if (json['message'] != null) {
      message = new List<Message>();
      json['message'].forEach((v) {
        message.add(new Message.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['chatID'] = this.chatID;
    if (this.message != null) {
      data['message'] = this.message.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Message {
  String messageID;
  String messageFrom;
  String contentOfMessage;
  String time;

  Message({this.messageID, this.messageFrom, this.contentOfMessage, this.time});

  Message.fromJson(Map<String, dynamic> json) {
    messageID = json['messageID'];
    messageFrom = json['messageFrom'];
    contentOfMessage = json['contentOfMessage'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['messageID'] = this.messageID;
    data['messageFrom'] = this.messageFrom;
    data['contentOfMessage'] = this.contentOfMessage;
    data['time'] = this.time;
    return data;
  }
}

class Events {
  String eventID;
  String eventName;
  String eventDate;
  String eventDescription;
  String eventLocation;

  Events(
      {this.eventID,
        this.eventName,
        this.eventDate,
        this.eventDescription,
        this.eventLocation});

  Events.fromJson(Map<String, dynamic> json) {
    eventID = json['eventID'];
    eventName = json['eventName'];
    eventDate = json['eventDate'];
    eventDescription = json['eventDescription'];
    eventLocation = json['eventLocation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventID'] = this.eventID;
    data['eventName'] = this.eventName;
    data['eventDate'] = this.eventDate;
    data['eventDescription'] = this.eventDescription;
    data['eventLocation'] = this.eventLocation;
    return data;
  }
}

class Members {
  String memberUID;
  bool isAdmin;

  Members({this.memberUID, this.isAdmin});

  Members.fromJson(Map<String, dynamic> json) {
    memberUID = json['memberUID'];
    isAdmin = json['isAdmin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['memberUID'] = this.memberUID;
    data['isAdmin'] = this.isAdmin;
    return data;
  }
}

class TasksOfProject {
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
  List<SubTask> subTask;
  List<Message> message;

  TasksOfProject(
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
        this.subTask,
        this.message});

  TasksOfProject.fromJson(Map<String, dynamic> json) {
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
      subTask = new List<SubTask>();
      json['subTask'].forEach((v) {
        subTask.add(new SubTask.fromJson(v));
      });
    }
    if (json['message'] != null) {
      message = new List<Message>();
      json['message'].forEach((v) {
        message.add(new Message.fromJson(v));
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
    if (this.subTask != null) {
      data['subTask'] = this.subTask.map((v) => v.toJson()).toList();
    }
    if (this.message != null) {
      data['message'] = this.message.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubTask {
  String subTaskName;
  String subTaskDescription;
  String subTaskStatus;

  SubTask({this.subTaskName, this.subTaskDescription, this.subTaskStatus});

  SubTask.fromJson(Map<String, dynamic> json) {
    subTaskName = json['subTaskName'];
    subTaskDescription = json['subTaskDescription'];
    subTaskStatus = json['subTaskStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subTaskName'] = this.subTaskName;
    data['subTaskDescription'] = this.subTaskDescription;
    data['subTaskStatus'] = this.subTaskStatus;
    return data;
  }
}