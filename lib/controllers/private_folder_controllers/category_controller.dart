import 'package:get/get.dart';
import 'package:swe496/Database/private_folder_collection.dart';
import 'package:swe496/models/private_folder_models/category.dart';
import '../authController.dart';

class CategoryController extends GetxController {
  // Make an observable task models
  Rx<List<Category>> _categoryList = Rx<List<Category>>();

  List<Category> get categories => _categoryList.value;

  @override
  void onInit() {
    // We need to get the current user uid
    String uid = Get.find<AuthController>().user.uid;
    // Binds the tasks model of the user of the above uid by assigning its uid to its database private tasks stream
    _categoryList.bindStream(
      PrivateFolderCollection().privateFolderCategoriesStream(uid),
    );
  }
}
