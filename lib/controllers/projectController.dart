import 'package:get/get.dart';
import 'package:swe496/Database/ProjectCollection.dart';
import 'package:swe496/controllers/authController.dart';
import 'package:swe496/controllers/userController.dart';
import 'package:swe496/models/Project.dart';
import 'package:swe496/models/User.dart';

class ProjectController extends GetxController {

  Rx<List<Project>> projectList = Rx<List<Project>>();

  List<Project> get projects => projectList.value;

  @override
  void onInit() {
    User user = Get.find<UserController>().user;
   // projectList.bindStream(ProjectCollection().projectStream(user)); // stream coming from firebase
  }
}