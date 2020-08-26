class User {
  String userID;
  String userName;
  String email;
  String password;
  String name;
  String birthDate;
  String userAvatar;
  List<Projects> projects;
  List<User> user;

  User(
      {this.userID,
        this.userName,
        this.email,
        this.password,
        this.name,
        this.birthDate,
        this.userAvatar,
        this.projects,
        this.user});

  User.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    userName = json['userName'];
    email = json['email'];
    password = json['password'];
    name = json['name'];
    birthDate = json['birthDate'];
    userAvatar = json['UserAvatar'];
    if (json['projects'] != null) {
      projects = new List<Projects>();
      json['projects'].forEach((v) {
        projects.add(new Projects.fromJson(v));
      });
    }
    if (json['User'] != null) {
      user = new List<User>();
      json['User'].forEach((v) {
        user.add(new User.fromJson(v));
      });
    }
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
    if (this.projects != null) {
      data['projects'] = this.projects.map((v) => v.toJson()).toList();
    }
    if (this.user != null) {
      data['User'] = this.user.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Projects {
  String projectID;

  Projects({this.projectID});

  Projects.fromJson(Map<String, dynamic> json) {
    projectID = json['projectID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['projectID'] = this.projectID;
    return data;
  }
}
