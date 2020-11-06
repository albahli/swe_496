import 'package:get/get.dart';
import 'package:swe496/Database/ProjectCollection.dart';
import 'package:swe496/controllers/authController.dart';
import 'package:swe496/models/Project.dart';

class ListOfProjectsController extends GetxController {


  Rx<List<Project>> _projectsList = Rx<List<Project>>();

  List<Project> get projects => _projectsList.value;

  @override
  void onInit() {
    String userID = Get.find<AuthController>().user.uid;

    _projectsList.bindStream(ProjectCollection().projectsListStream(userID)); //stream coming from firebase
  }
  void clear() {
    _projectsList.value = List<Project>();
  }
}
