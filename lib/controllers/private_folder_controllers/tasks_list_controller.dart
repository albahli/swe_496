import 'package:get/get.dart';
import 'package:swe496/Database/private_folder_collection.dart';
import 'package:swe496/controllers/UserControllers/authController.dart';
import 'package:swe496/models/private_folder_models/task_of_private_folder.dart';

class TasksListController extends GetxController {
  // 26 we make an observable task models
  Rx<List<TaskOfPrivateFolder>> _tasksList = Rx<List<TaskOfPrivateFolder>>();

  // 27 we need to stream the list of tasks to the private folder
  List<TaskOfPrivateFolder> get tasks => _tasksList.value;

  // 28 we need to bind the _tasksList to the stream coming from Firestore of the database
  @override
  void onInit() {
    String uid = Get.find<AuthController>().user.uid;

    _tasksList.bindStream(PrivateFolderCollection().privateFolderTasksStream(uid));
  }
}
