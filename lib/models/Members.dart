class Member {
  String memberUID;
  bool isAdmin;

  Member({this.memberUID, this.isAdmin});

  Member.fromJson(Map<String, dynamic> json) {
    memberUID = json['memberUID'];
    isAdmin = json['isAdmin'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['memberUID'] = this.memberUID;
    data['isAdmin'] = this.isAdmin;
    return data;
  }
}