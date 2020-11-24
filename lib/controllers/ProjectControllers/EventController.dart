import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:swe496/Database/ProjectCollection.dart';
import 'package:swe496/controllers/ProjectControllers/projectController.dart';
import 'package:swe496/models/Event.dart';

class EventController extends GetxController {
  Rx<Event> eventVal = Rx<Event>();
  String eventID;

  EventController({@required this.eventID});

  Event get event => eventVal.value;

  @override
  void onInit() {
    String projectID = Get.find<ProjectController>().project.projectID;

    eventVal.bindStream(ProjectCollection()
        .eventStream(projectID, eventID)); //stream coming from firebase
  }

  void clear() {
    eventVal.value = Event();
  }
}
