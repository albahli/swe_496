import 'Message.dart';

class Chat {
  String chatID;
  List<Message> message;

  Chat({this.chatID, this.message});

  Chat.fromJson(Map<String, dynamic> json) {
    chatID = json['chatID'];

    if (json['message'] != null) {
      message = new List<Message>();
      json['message'].forEach((v) {
        message.add(new Message.fromJson(Map<String, dynamic>.from(v)));
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
