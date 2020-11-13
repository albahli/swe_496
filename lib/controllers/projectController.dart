import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:swe496/Database/ProjectCollection.dart';
import 'package:swe496/models/Project.dart';

class ProjectController extends GetxController {

  Rx<Project> _project = Rx<Project>();

  Project get project => _project.value;

  String projectID;

  ProjectController({@required this.projectID});
  // Set the value for project model and we will be able to observe it by 'get project' function above
  set project(Project value) => this._project.value = value;

  @override
  void onInit() {
    _project.bindStream(ProjectCollection().projectStream(projectID));//stream coming from firebase
  }



  void clear() {
    _project.value = Project();
  }
}
