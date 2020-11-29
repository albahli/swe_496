import 'package:get/get.dart';
import 'package:swe496/Database/private_folder_collection.dart';
import 'package:swe496/models/private_folder_models/comment.dart';

import '../authController.dart';

class CommentsListController extends GetxController {
  String taskId;
  Rx<List<Comment>> _commentsList = Rx<List<Comment>>();

  CommentsListController(this.taskId);

  List<Comment> get comments => _commentsList.value;

  @override
  void onInit() {
    String uid = Get.find<AuthController>().user.uid;
    _commentsList.bindStream(
        PrivateFolderCollection().commentsStream(userId: uid, taskId: taskId));
  }
}
