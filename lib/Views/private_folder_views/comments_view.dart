import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swe496/Database/private_folder_collection.dart';
import 'package:swe496/models/private_folder_models/comment.dart';

import '../../controllers/authController.dart';
import '../../controllers/private_folder_controllers/comments_list_controller.dart';
import './widget/comment_item.dart';

class CommentsView extends StatefulWidget {
  final String taskId;

  CommentsView({@required this.taskId});
  @override
  _CommentsViewState createState() => _CommentsViewState();
}

class _CommentsViewState extends State<CommentsView> {
  TextEditingController _commentTextController = TextEditingController();

  List<Comment> taskComments = [];

  @override
  void initState() {
    super.initState();
    Get.put<CommentsListController>(CommentsListController(widget.taskId));
  }

  Future<void> _createComment() async {
    await PrivateFolderCollection().createComment(
      userId: Get.find<AuthController>().user.uid,
      taskId: widget.taskId,
      commentText: _commentTextController.text,
      dateTime: DateTime.now(),
    );
    _commentTextController.clear();
  }

  Future<void> getCommentsStream() async {
    GetX<CommentsListController>(
      init: Get.find<CommentsListController>() != null
          ? Get.find<CommentsListController>()
          : Get.put<CommentsListController>(
              CommentsListController(widget.taskId),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.cached),
              onPressed: () async {
                await getCommentsStream();
              })
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GetX<CommentsListController>(
              init: Get.find<CommentsListController>(),
              builder: (CommentsListController commentsController) {
                if (commentsController != null &&
                    commentsController.comments != null &&
                    commentsController.comments.isNotEmpty) {
                  taskComments = commentsController.comments;
                  return ListView(
                    reverse: true,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                    shrinkWrap: true,
                    children: [
                      ...commentsController.comments.map((comment) {
                        return CommentItem(
                          comment.commentText,
                          comment.dateTime,
                        );
                      }).toList()
                    ],
                  );
                }
                return Container();
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                    color: Theme.of(context).primaryColor, width: 2.0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Form(
                    child: TextFormField(
                      controller: _commentTextController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 20.0,
                        ),
                        hintText: 'Type a comment',
                        border: InputBorder.none,
                      ),
                      keyboardType: TextInputType.text,
                      onFieldSubmitted: (_) => _createComment(),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: () async {
                    await _createComment();
                  },
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.01),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
