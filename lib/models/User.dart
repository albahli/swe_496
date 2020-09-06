class User {
  String userID;
  String userName;
  String email;
  String password;
  String name;
  String birthDate;
  String userAvatar;
  List<String> listOfProjects;
  List<String> listOfFriends;

  User(
      {this.userID,
        this.userName,
        this.email,
        this.password,
        this.name,
        this.birthDate,
        this.userAvatar,
        this.listOfProjects,
        this.listOfFriends});

  User.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    userName = json['userName'];
    email = json['email'];
    password = json['password'];
    name = json['name'];
    birthDate = json['birthDate'];
    userAvatar = json['UserAvatar'];
    listOfProjects = json['listOfProjects'].cast<String>();
    listOfFriends = json['listOfFriends'].cast<String>();
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
    data['listOfProjects'] = this.listOfProjects;
    data['listOfFriends'] = this.listOfFriends;
    return data;
  }
}