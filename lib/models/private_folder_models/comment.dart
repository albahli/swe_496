import 'package:flutter/foundation.dart';

class Comment {
  String commentId;
  String commentText;
  DateTime dateTime;

  Comment({
    @required this.commentId,
    @required this.commentText,
    @required this.dateTime,
  });

  Comment.fromJson(Map<String, dynamic> json) {
    commentId = json['commentId'];
    commentText = json['commentText'];
    dateTime = DateTime.fromMicrosecondsSinceEpoch(
        json['dateTime'].microsecondsSinceEpoch);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['commentId'] = this.commentId;
    data['commentText'] = this.commentText;
    data['dateTime'] = this.dateTime;
    return data;
  }
}
