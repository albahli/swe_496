import 'package:swe496/Database/ProjectCollection.dart';

class Event {
  String eventID;
  String eventName;
  String eventStartDate;
  String eventEndDate;
  String eventDescription;
  String eventLocation;

  Event(
      {this.eventID,
      this.eventName,
      this.eventStartDate,
      this.eventEndDate,
      this.eventDescription,
      this.eventLocation});

  Event.fromJson(Map<String, dynamic> json) {
    eventID = json['eventID'];
    eventName = json['eventName'];
    eventStartDate = json['eventStartDate'];
    eventEndDate = json['eventEndDate'];
    eventDescription = json['eventDescription'];
    eventLocation = json['eventLocation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventID'] = this.eventID;
    data['eventName'] = this.eventName;
    data['eventStartDate'] = this.eventStartDate;
    data['eventEndDate'] = this.eventEndDate;
    data['eventDescription'] = this.eventDescription;
    data['eventLocation'] = this.eventLocation;
    return data;
  }

  Future<void> createNewEvent(
      String projectID,
      String eventName,
      String eventDescription,
      String startDate,
      String endDate,
      String location) async {
    await ProjectCollection().createNewEvent(
        projectID, eventName, eventDescription, startDate, endDate, location);
  }

  Future<bool> editEvent(
      String projectID,
      String eventID,
      String eventName,
      String eventDescription,
      String startDate,
      String endDate,
      String location) async {
    return await ProjectCollection().editEvent(projectID, eventID, eventName,
        eventDescription, startDate, endDate, location);
  }

  Future<void> deleteEvent(String projectID, String eventID) async {
    await ProjectCollection().deleteEvent(projectID, eventID);
  }


}
