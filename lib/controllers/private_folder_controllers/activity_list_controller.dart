import 'package:get/get.dart';
import '../../models/private_folder_models/activity_action.dart';
import '../authController.dart';
import '../../Database/private_folder_collection.dart';

class ActivityListController extends GetxController {
  Rx<List<ActivityAction>> _activityList = Rx<List<ActivityAction>>();

  List<ActivityAction> get activityList => _activityList.value;

  @override
  void onInit() {
    // We need to get the current user uid
    String uid = Get.find<AuthController>().user.uid;
    // Binds the tasks model of the user of the above uid by assigning its uid to its database private tasks stream
    _activityList.bindStream(
      PrivateFolderCollection().activityStream(uid),
    );
  }
}
