import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:swe496/Database/private_folder_collection.dart';
import 'package:swe496/models/private_folder_models/task.dart';

import '../authController.dart';

class TaskController extends GetxController {
  String taskId;

  Rx<TaskModel> _task = Rx<TaskModel>();

  TaskModel get task => _task.value;

  Future<bool> get hasSubtasks async => await PrivateFolderCollection()
          .taskHasSubtasks(taskId, Get.find<AuthController>().user.uid)
          .catchError((s) {
        return false;
      });
  // TODO: add timeout handler so that if there isn't conncetion, then error can be handled

  TaskController({@required this.taskId});

  @override
  void onInit() async {
    String uid = Get.find<AuthController>().user.uid;
    _task.bindStream(await PrivateFolderCollection().taskStream(uid, taskId));
    super.onInit();
  }
}
