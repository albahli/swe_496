import 'package:get/get.dart';
import 'package:swe496/models/Project.dart';

class ProjectController extends GetxController {

  Rx<Project> _project = Project().obs;

  Project get project => _project.value;

  // Set the value for project model and we will be able to observe it by 'get project' function above
  set project(Project value) => this._project.value = value;

  void clear() {
    _project.value = Project();
  }
}
