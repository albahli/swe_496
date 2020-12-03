import 'package:flutter/foundation.dart';
import 'package:swe496/Database/private_folder_collection.dart';

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

  Future<void> createComment({
    @required String userId,
    @required String taskId,
    @required String commentText,
    @required DateTime dateTime,
  }) async {
    await PrivateFolderCollection().createComment(userId: userId, taskId: taskId, commentText: commentText, dateTime: dateTime);
  }

}
