import 'package:get/get.dart';
import 'package:swe496/Database/ProjectCollection.dart';
import 'package:swe496/controllers/projectController.dart';
import 'package:swe496/models/TaskOfProject.dart';

import 'authController.dart';

class TaskOfProjectController extends GetxController {
Rx<List<TaskOfProject>> tasksList = Rx<List<TaskOfProject>>();

List<TaskOfProject> get tasks => tasksList.value;

@override
void onInit() {
  String assignedTo = Get.find<AuthController>().user.uid;
  String projectID = Get.find<ProjectController>().project.projectID;
  tasksList.bindStream(ProjectCollection().tasksOfProjectStream(projectID, assignedTo)); //stream coming from firebase
}
}