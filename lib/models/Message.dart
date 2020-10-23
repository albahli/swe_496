import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String messageID;
  String senderID;
  String from;
  String contentOfMessage;
  Timestamp time;

  Message({this.messageID, this.senderID, this.from, this.contentOfMessage, this.time});

  Message.fromJson(Map<String, dynamic> json) {
    messageID = json['messageID'];
    senderID = json['senderID'];
    from = json['from'];
    contentOfMessage = json['contentOfMessage'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['messageID'] = this.messageID;
    data['senderID'] = this.senderID;
    data['from'] = this.from;
    data['contentOfMessage'] = this.contentOfMessage;
    data['time'] = this.time;
    return data;
  }
}