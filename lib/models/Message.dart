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