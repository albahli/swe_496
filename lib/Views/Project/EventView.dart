import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:swe496/Database/ProjectCollection.dart';
import 'package:swe496/Views/Project/CreateTaskView.dart';
import 'package:swe496/Views/Project/MembersView.dart';
import 'package:swe496/controllers/EventController.dart';
import 'package:swe496/controllers/projectController.dart';
import 'package:uuid/uuid.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

import 'GoogleMapWidgetView.dart';

class EventView extends StatefulWidget {
  @override
  _EventViewState createState() => _EventViewState();
}

class _EventViewState extends State<EventView> {
  // Project Controller
  ProjectController projectController = Get.find<ProjectController>();

  // Google map controller
  Completer<GoogleMapController> _googleMapController = Completer();
  Marker eventMarker;
  LatLng latLng;
  Set<Marker> markersSet;
  GoogleMapController  _mapController;

  // Below attributes used for editing the events info
  final eventFormKey = GlobalKey<FormState>();
  TextEditingController editedEventName = new TextEditingController();
  TextEditingController editedEventDescription = new TextEditingController();
  TextEditingController editedEventLocation = new TextEditingController();
  TextEditingController editedEventStartDate = new TextEditingController();
  TextEditingController editedEventEndDate = new TextEditingController();

  DateTime _start = new DateTime.now();
  DateTime _due = new DateTime.now().add(Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.delete<EventController>();
            Get.back();
          },
        ),
      ),
      body: GetX<EventController>(builder: (EventController eventController) {
        if (eventController != null &&
            eventController.event != null &&
            !eventController.event.isNullOrBlank &&
            !eventController.event.isNull
        ) {
          // Splitting the event's location into Lat and Lng.
          if (eventController.event.eventLocation.isNotEmpty ||
              !eventController.event.eventLocation.isNullOrBlank) {
            var arrayOfLatLng = eventController.event.eventLocation.split(',');
            // Creating LatLng object from the event's location.
            latLng = new LatLng(
                double.parse(arrayOfLatLng[0]), double.parse(arrayOfLatLng[1]));

            // Creating marker for the event location.
            eventMarker =
                new Marker(markerId: MarkerId(Uuid().v1()), position: latLng);
            // Creating set of Marker
            markersSet = new Set<Marker>();
            markersSet.add(eventMarker);
          }

          double noLocationMaxHeight = MediaQuery.of(context).size.height;
          double noLocationMinHeight = MediaQuery.of(context).size.height;
          return SlidingUpPanel(
            collapsed: eventController.event.eventLocation.isNotEmpty ||
                    !eventController.event.eventLocation.isNullOrBlank
                ? Icon(
                    Icons.keyboard_arrow_up,
                  )
                : SizedBox(),
            borderRadius: eventController.event.eventLocation.isNotEmpty ||
                    !eventController.event.eventLocation.isNullOrBlank
                ? BorderRadius.only(
                    topLeft: Radius.circular(18.0),
                    topRight: Radius.circular(18.0))
                : BorderRadius.only(),
            maxHeight: eventController.event.eventLocation.isNotEmpty ||
                    !eventController.event.eventLocation.isNullOrBlank
                ? MediaQuery.of(context).size.height * 0.7
                : noLocationMaxHeight,
            minHeight: eventController.event.eventLocation.isNotEmpty ||
                    !eventController.event.eventLocation.isNullOrBlank
                ? MediaQuery.of(context).size.height * 0.1
                : noLocationMinHeight,
            margin: eventController.event.eventLocation.isNotEmpty ||
                    !eventController.event.eventLocation.isNullOrBlank
                ? EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1)
                : EdgeInsets.all(0),
            body: eventController.event.eventLocation.isNullOrBlank
                ? SizedBox()
                : Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    width: MediaQuery.of(context).size.width,
                    child: GoogleMap(
                      compassEnabled: true,
                      onMapCreated: (GoogleMapController controller) async {
                        _googleMapController.complete(controller);
                        _mapController = controller;
                      },
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.5),
                      zoomGesturesEnabled: true,
                      scrollGesturesEnabled: true,
                      rotateGesturesEnabled: true,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: true,
                      tiltGesturesEnabled: true,
                      gestureRecognizers:
                          <Factory<OneSequenceGestureRecognizer>>[
                        new Factory<OneSequenceGestureRecognizer>(
                          () => new EagerGestureRecognizer(),
                        ),
                      ].toSet(),
                      mapType: MapType.normal,

                      markers: markersSet,
                      initialCameraPosition: CameraPosition(
                        target: LatLng(latLng.latitude, latLng.longitude),
                        zoom: 13.0,
                      ),
                    ),
                  ),
            panel: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: eventController.event.eventLocation.isNotEmpty ||
                            !eventController.event.eventLocation.isNullOrBlank
                        ? MediaQuery.of(context).size.height * 0.1
                        : 0,
                  ),
                  Flexible(
                    child: ListTile(
                      leading: Icon(Icons.event),
                      title: Text('${eventController.event.eventName}', style: TextStyle(fontSize: 18),),
                    ),
                  ),
                  Divider(thickness: 1,),
                  Flexible(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:
                            Text('${eventController.event.eventDescription}')),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          '${eventController.event.eventStartDate} - ${eventController.event.eventEndDate}'),
                    ),
                  ),
                  Divider(thickness: 1,),
                  ButtonBar(
                    children: [
                      FlatButton(
                        child: const Text('EDIT'),
                        onPressed: () {
                          Get.bottomSheet(editEvent(eventController),
                              isScrollControlled: true, ignoreSafeArea: false);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          showModalBottomSheet(
                              context: context,
                              builder: (BuildContext bc) {
                                return Wrap(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        color: Get.theme.canvasColor,
                                        child: Column(
                                          children: [
                                            ListTile(
                                              title: Text('Delete Event?'),
                                              trailing: FlatButton(
                                                child: const Text(
                                                  'DELETE',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                                onPressed: () async {
                                                  Get.delete<EventController>();
                                                  Get.back();
                                                  Get.back();
                                                  ProjectCollection()
                                                      .deleteEvent(
                                                          projectController
                                                              .project
                                                              .projectID,
                                                          eventController
                                                              .event.eventID);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              });
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: Text('Event has been deleted')),
        );
      }),
    );
  }

  Widget editEvent(EventController eventController) {
    editedEventName.text = eventController.event.eventName;
    editedEventDescription.text = eventController.event.eventDescription;
    editedEventStartDate.text = eventController.event.eventStartDate;
    editedEventEndDate.text = eventController.event.eventEndDate;
    editedEventLocation.text = eventController.event.eventLocation;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.restore),
            tooltip: 'Restore fields',
            onPressed: () {
              editedEventName.text = eventController.event.eventName;
              editedEventDescription.text =
                  eventController.event.eventDescription;
              editedEventStartDate.text = eventController.event.eventStartDate;
              editedEventEndDate.text = eventController.event.eventEndDate;
              editedEventLocation.text = eventController.event.eventLocation;
            },
          ),
          IconButton(
            icon: Icon(Icons.autorenew),
            tooltip: 'Clear fields',
            onPressed: () {
              editedEventName.clear();
              editedEventDescription.clear();
              editedEventStartDate.clear();
              editedEventEndDate.clear();
              editedEventLocation.clear();
            },
          ),
        ],
      ),
      resizeToAvoidBottomPadding: false,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 20, 8),
        child: Container(
          child: SingleChildScrollView(
            child: Form(
              key: eventFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: editedEventName,
                    validator: (eventNameVal) => eventNameVal.isEmpty
                        ? "Event name cannot be empty"
                        : null,
                    onSaved: (eventNameVal) =>
                        editedEventName.text = eventNameVal,
                    decoration: InputDecoration(
                        labelText: 'Event name',
                        hintText: 'Meeting at Marriott hotel.',
                        prefixIcon: Icon(Icons.edit),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: editedEventDescription,
                    validator: (eventDescriptionVal) =>
                        eventDescriptionVal.isEmpty
                            ? "Event description cannot be empty"
                            : null,
                    onSaved: (eventDescriptionVal) =>
                        editedEventDescription.text = eventDescriptionVal,
                    decoration: InputDecoration(
                        labelText: 'Event description',
                        hintText:
                            'We are going to meet at the Marriott hotel 8:30 PM in the conference room to discuss the future activities of our project.',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                    maxLines: 5,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: editedEventStartDate,
                          validator: (startDateVal) => startDateVal.isEmpty
                              ? 'Start date cannot be empty'
                              : null,
                          onSaved: (startDateVal) => startDateVal.length >= 10
                              ? editedEventStartDate.text =
                                  startDateVal.substring(0, 10)
                              : editedEventStartDate.clear(),
                          readOnly: true,
                          decoration: InputDecoration(
                              labelText: 'Start date',
                              hintText:
                                  DateTime.now().toString().substring(0, 10),
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(20)))),
                          onTap: () async {
                            pickDate();
                          },
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: editedEventEndDate,
                          validator: (dueDateVal) => dueDateVal.isEmpty
                              ? 'End date cannot be empty'
                              : null,
                          onSaved: (dueDateVal) => dueDateVal.length >= 10
                              ? editedEventEndDate.text =
                                  dueDateVal.substring(0, 10)
                              : editedEventEndDate.clear(),
                          readOnly: true,
                          decoration: InputDecoration(
                              labelText: 'End date',
                              hintText:
                                  DateTime.now().toString().substring(0, 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.horizontal(
                                      right: Radius.circular(20)))),
                          onTap: () async => pickDate(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Stack(
                            children: [
                              TextFormField(
                        controller: editedEventLocation,
                        textAlignVertical: TextAlignVertical.center,
                        readOnly: true,
                        decoration: InputDecoration(
                                hintText: 'Event location',
                                prefixIcon: Icon(
                                  Icons.location_on,
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20))),
                        onTap: () async {
                              editedEventLocation.text = await Get.to(
                                  GoogleMapWidgetView(),
                                  preventDuplicates: false,
                                  transition: Transition.downToUp);
                        },
                      ),
                            ],
                          )),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ButtonTheme(
                    minWidth: 20,
                    height: 50.0,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(30.0),
                              right: Radius.circular(30.0))),
                      onPressed: () async {
                        eventFormKey.currentState.save();
                        if (eventFormKey.currentState.validate()) {
                          ProjectCollection().editEvent(
                              projectController.project.projectID,
                              eventController.eventID,
                              editedEventName.text,
                              editedEventDescription.text,
                              editedEventStartDate.text,
                              editedEventEndDate.text,
                              editedEventLocation.text);

                          //TODO: Camera position not updating after event location, fix it.
                           // _googleMapController = Completer();
                            if (eventController.event.eventLocation.isNotEmpty ||
                                !eventController.event.eventLocation.isNullOrBlank) {
                              var arrayOfLatLng = eventController.event.eventLocation.split(',');
                              // Creating LatLng object from the event's location.
                              var latLng = new LatLng(
                                  double.parse(arrayOfLatLng[0]), double.parse(arrayOfLatLng[1]));
                              eventMarker =
                              new Marker(markerId: MarkerId(Uuid().v1()), position: latLng);
                              // Creating set of Marker
                              markersSet = new Set<Marker>();
                              markersSet.add(eventMarker);
                              print('HERE LAT : ${latLng.latitude}');
                              print('HERE LNG : ${latLng.longitude}');
                              _mapController.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target: latLng, zoom: 14)));
                              // Creating marker for the event location.
                            }
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const Text('Update Event',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w300,
                              )),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // This function decides the how many days can be selected in that range.
  // Here we decide that the user can select from one day up to two years.
  bool _decideWhichDayToEnable(DateTime day) {
    if ((day.isAfter(DateTime.now().subtract(Duration(days: 1))) &&
        day.isBefore(DateTime.now().add(Duration(days: 365 * 2))))) {
      return true;
    }
    return false;
  }

  void pickDate() async {
    final List<DateTime> picked = await DateRagePicker.showDatePicker(
      context: context,
      initialFirstDate: _start,
      initialLastDate: _due,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(Duration(days: 2 * 365)),
      selectableDayPredicate: _decideWhichDayToEnable,
    );
    if (picked != null && picked.length == 1) {
      if (!picked[0].isNullOrBlank) {
        editedEventStartDate.text = picked[0].toString().substring(0, 10);
        editedEventEndDate.text = picked[0].toString().substring(0, 10);
        return;
      } else if (!picked[1].isNullOrBlank) {
        editedEventStartDate.text = picked[1].toString().substring(0, 10);
        editedEventEndDate.text = picked[1].toString().substring(0, 10);
        return;
      }
    }
    if (picked != null && picked.length == 2 && picked[0] != picked[1]) {
      _start = picked[0];
      editedEventStartDate.text = picked[0].toString().substring(0, 10);
      _due = picked[1];
      editedEventEndDate.text = picked[1].toString().substring(0, 10);
      return;
    }
  }
}
