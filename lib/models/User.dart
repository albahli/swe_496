class User {
  String userID;
  String userName;
  String email;
  String password;
  String name;
  String birthDate;
  String userAvatar;
  List<UserProjects> userProjects;
  List<Friends> friends;

  User(
      {this.userID,
        this.userName,
        this.email,
        this.password,
        this.name,
        this.birthDate,
        this.userAvatar,
        this.userProjects,
        this.friends});

  User.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
    userName = json['userName'];
    email = json['email'];
    password = json['password'];
    name = json['name'];
    birthDate = json['birthDate'];
    userAvatar = json['UserAvatar'];
    if (json['userProjects'] != null) {
      userProjects = new List<UserProjects>();
      json['userProjects'].forEach((v) {
        userProjects.add(new UserProjects.fromJson(v));
      });
    }
    if (json['friends'] != null) {
      friends = new List<Friends>();
      json['friends'].forEach((v) {
        friends.add(new Friends.fromJson(v));
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
    if (this.userProjects != null) {
      data['userProjects'] = this.userProjects.map((v) => v.toJson()).toList();
    }
    if (this.friends != null) {
      data['friends'] = this.friends.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UserProjects {
  String projectID;

  UserProjects({this.projectID});

  UserProjects.fromJson(Map<String, dynamic> json) {
    projectID = json['projectID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['projectID'] = this.projectID;
    return data;
  }
}

class Friends {
  String userID;

  Friends({this.userID});

  Friends.fromJson(Map<String, dynamic> json) {
    userID = json['userID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userID'] = this.userID;
    return data;
  }
}