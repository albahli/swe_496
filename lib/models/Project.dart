import 'Chat.dart';
import 'Event.dart';
import 'Members.dart';
import 'TaskOfProject.dart';

class Project {
  String projectID;
  String projectName;
  String image;
  String joiningLink;
  bool isJoiningLinkEnabled;
  String pinnedMessage;
  Chat chat;
  List<Event> event;
  List<Member> members;
  List<String> membersIDs;
  List<TaskOfProject> task;

  Project(
      {this.projectID,
        this.projectName,
        this.image,
        this.joiningLink,
        this.isJoiningLinkEnabled,
        this.pinnedMessage,
        this.chat,
        this.event,
        this.members,
        this.membersIDs,
        this.task});

  Project.fromJson(Map<String, dynamic> json) {
    projectID = json['projectID'];
    projectName = json['projectName'];
    image = json['image'];
    joiningLink = json['joiningLink'];
    isJoiningLinkEnabled = json['isJoiningLinkEnabled'];
    pinnedMessage = json['pinnedMessage'];
    chat = json['chat'] != null ? new Chat.fromJson(Map<String,dynamic>.from(json['chat'])) : null;
    if (json['event'] != null) {
      event = new List<Event>();
      json['event'].forEach((v) {
        event.add(new Event.fromJson(Map<String,dynamic>.from(v)));
      });
    }
    if (json['members'] != null) {
      members = new List<Member>();
      json['members'].forEach((v) {
        members.add(new Member.fromJson(Map<String,dynamic>.from(v)));
      });
    }
    membersIDs = List.of(json['membersIDs'].cast<String>());
    if (json['Task'] != null) {
      task = new List<TaskOfProject>();
      json['Task'].forEach((v) {
        task.add(new TaskOfProject.fromJson(Map<String,dynamic>.from(v)));
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
    if (this.event != null) {
      data['event'] = this.event.map((v) => v.toJson()).toList();
    }
    if (this.members != null) {
      data['members'] = this.members.map((v) => v.toJson()).toList();
    }
    data['membersIDs'] = this.membersIDs;
    if (this.task != null) {
      data['Task'] = this.task.map((v) => v.toJson()).toList();
    }
    return data;
  }
}