import 'package:swe496/Database/UserProfileCollection.dart';
import 'package:swe496/controllers/UserControllers/authController.dart';

class User {
  String userID;
  String userName;
  String email;
  String password;
  String name;
  String birthDate;
  String userAvatar;
  List<String> userProjectsIDs;
  List<String> friendsIDs;
  List<String> userChatsIDs;

  User(
      {this.userID,
      this.userName,
      this.email,
      this.password,
      this.name,
      this.birthDate,
      this.userAvatar,
      this.userProjectsIDs,
      this.friendsIDs,
      this.userChatsIDs});

  User.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    userName = json['userName'];
    email = json['email'];
    password = json['password'];
    name = json['name'];
    birthDate = json['birthDate'];
    userAvatar = json['UserAvatar'];
    userProjectsIDs = List.of(json['userProjectsIDs'].cast<String>());
    friendsIDs = List.of(json['friendsIDs'].cast<String>());
    userChatsIDs = List.of(json['userChatsIDs'].cast<String>());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userID'] = this.userID;
    data['userName'] = this.userName;
    data['email'] = this.email;
    data['password'] = this.password;
    data['name'] = this.name;
    data['birthDate'] = this.birthDate;
    data['UserAvatar'] = this.userAvatar;
    data['userProjectsIDs'] = this.userProjectsIDs;
    data['friendsIDs'] = this.friendsIDs;
    data['userChatsIDs'] = this.userChatsIDs;
    return data;
  }
  Future<void> updateBirthDate(String date,User user) async{
    UserProfileCollection().updateBirthDate(date, user);
  }
  Future<void> updateName(String name,User user) async{
    UserProfileCollection().updateName(name, user);
  }
  Future<void> updateEmail(String email) async{
    AuthController().updateEmail(email);
  }
  Future<void> updatePassword(String password) async{
    AuthController().updatePassword(password);
  }

  Future<void> addFriend(String friendUsername , User user){
    return UserProfileCollection().addFriend(friendUsername, user);
  }


}
