class Event {
  String eventID;
  String eventName;
  String eventDate;
  String eventDescription;
  String eventLocation;

  Event(
      {this.eventID,
        this.eventName,
        this.eventDate,
        this.eventDescription,
        this.eventLocation});

  Event.fromJson(Map<String, dynamic> json) {
    eventID = json['eventID'];
    eventName = json['eventName'];
    eventDate = json['eventDate'];
    eventDescription = json['eventDescription'];
    eventLocation = json['eventLocation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['eventID'] = this.eventID;
    data['eventName'] = this.eventName;
    data['eventDate'] = this.eventDate;
    data['eventDescription'] = this.eventDescription;
    data['eventLocation'] = this.eventLocation;
    return data;
  }
}