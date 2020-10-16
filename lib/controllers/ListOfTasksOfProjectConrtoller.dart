import 'package:get/get.dart';
import 'package:swe496/Database/ProjectCollection.dart';
import 'package:swe496/controllers/projectController.dart';
import 'package:swe496/models/TaskOfProject.dart';

import 'authController.dart';

class ListOfTasksOfProjectController extends GetxController {

  Rx<List<TaskOfProject>> tasksList = Rx<List<TaskOfProject>>();

  List<TaskOfProject> get tasks => tasksList.value;

  @override
  void onInit() {
    String memberID = Get.find<AuthController>().user.uid;
    String projectID = Get.find<ProjectController>().project.projectID;
    bool isAdmin = false;

    Get.find<ProjectController>().project.members.forEach((member) {
      if (member.memberUID == memberID && member.isAdmin) {
        isAdmin = true;
      }
    });

    if (isAdmin) {
      // Gets tasks assigned by admin
      tasksList.bindStream(ProjectCollection()
          .getTasksOfProjectAssignedByAdmin(projectID, memberID));
      return;
    } else {
      // Gets tasks
      tasksList.bindStream(ProjectCollection()
          .getTasksOfProjectAssignedToMember(projectID, memberID)); //stream coming from firebase
      return;
    }
  }

  void clear() {
    tasksList.value = List<TaskOfProject>();
  }
}
