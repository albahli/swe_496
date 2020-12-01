import 'package:flutter/foundation.dart';

class ActivityAction {
  String actionId;
  String actionType;
  DateTime actionDate;

  ActivityAction({
    @required this.actionId,
    @required this.actionType,
    @required this.actionDate,
  });

  ActivityAction.fromJson(Map<String, dynamic> json) {
    actionId = json['actionId'];
    actionType = json['actionType'];
    actionDate = DateTime.fromMicrosecondsSinceEpoch(
        json['actionDate'].microsecondsSinceEpoch);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();

    data['actionId'] = this.actionId;
    data['actionType'] = this.actionType;
    data['actionDate'] = this.actionDate;

    return data;
  }
}
