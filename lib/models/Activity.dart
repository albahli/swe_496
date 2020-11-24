import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  String activityID;
  String typeOfAction;
  String doneBy;
  Timestamp date;


  Activity(
      {this.activityID,
        this.typeOfAction,
        this.doneBy,
        this.date});

  Activity.fromJson(Map<String, dynamic> json) {
    activityID = json['activityID'];
    typeOfAction = json['typeOfAction'];
    doneBy = json['doneBy'];
    date = json['date'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['activityID'] = this.activityID;
    data['typeOfAction'] = this.typeOfAction;
    data['doneBy'] = this.doneBy;
    data['date'] = this.date;
    return data;
  }
}