import 'package:get/get.dart';
import 'package:swe496/Database/ProjectCollection.dart';
import 'package:swe496/controllers/projectController.dart';
import 'package:swe496/models/Event.dart';
class ListOfEventsController extends GetxController {


  ListOfEventsController();

  Rx<List<Event>> eventsList = Rx<List<Event>>();

  List<Event> get events => eventsList.value;

  @override
  void onInit() {

    String projectID = Get.find<ProjectController>().project.projectID;
    eventsList.bindStream(ProjectCollection().getEventsOfProject(
        projectID)); //stream coming from firebase

  }

  void clear() {
    eventsList.value = List<Event>();
  }
}
