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
}