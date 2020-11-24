import 'package:get/get.dart';
import 'package:swe496/controllers/UserControllers/authController.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }

}