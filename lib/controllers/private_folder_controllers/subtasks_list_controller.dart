import 'package:get/get.dart';
import 'package:swe496/Database/private_folder_collection.dart';
import 'package:swe496/models/private_folder_models/subtask.dart';
import 'package:swe496/models/private_folder_models/task.dart';
import '../authController.dart';

class SubtasksListController extends GetxController {
  String taskId;
  Rx<List<Subtask>> _subtasksList = Rx<List<Subtask>>();

  SubtasksListController(this.taskId);
  // !
  List<Subtask> get subtasks => _subtasksList.value;

  @override
  void onInit() {
    String uid = Get.find<AuthController>().user.uid;

    _subtasksList.bindStream(PrivateFolderCollection()
        .subtasksStream(userId: uid, parentTaskId: taskId));
  }
}
