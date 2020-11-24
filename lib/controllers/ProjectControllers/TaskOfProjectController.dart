import 'package:get/get.dart';
import 'package:swe496/Database/ProjectCollection.dart';
import 'package:swe496/controllers/ProjectControllers/projectController.dart';
import 'package:swe496/models/TaskOfProject.dart';

class TaskOfProjectController extends GetxController {
  String taskID;

  TaskOfProjectController({this.taskID});

  Rx<List<TaskOfProject>> tasksList = Rx<List<TaskOfProject>>();

  List<TaskOfProject> get tasks => tasksList.value;

  @override
  void onInit() {
    String projectID = Get.find<ProjectController>().project.projectID;

    tasksList.bindStream(ProjectCollection().taskStream(
        projectID, taskID)); //stream coming from firebase
  }

  void clear() {
    tasksList.value = List<TaskOfProject>();
  }
}
