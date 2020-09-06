import 'package:get/get.dart';
import 'package:swe496/models/User.dart';

class UserController extends GetxController {
  Rx<User> _user = User().obs;

  User get user => _user.value;

  // Set the value for user model and we will be able to observe it by 'get user' function above
  set user(User value) => this._user.value = value;

  void clear() {
    _user.value = User();
  }
}