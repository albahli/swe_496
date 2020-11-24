import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:swe496/Database/ProjectCollection.dart';
import 'package:swe496/controllers/ProjectControllers/projectController.dart';
import 'package:swe496/models/Activity.dart';

class ActivityLogController extends GetxController {

  Rx<List<Activity>> _activityLog = Rx<List<Activity>>();

  List<Activity> get activitiesOfProject => _activityLog.value;

  @override
  void onInit() {
    String projectID = Get.find<ProjectController>().project.projectID;
    _activityLog.bindStream(ProjectCollection().streamActivityLogOfProject(
        projectID)); // Stream coming from firebase
  }

  void clear() {
    _activityLog.value = List<Activity>();
  }
}