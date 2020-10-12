import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:get/get.dart';
import 'package:swe496/Database/ProjectCollection.dart';
import 'package:swe496/controllers/projectController.dart';
import 'CreateTaskView.dart';
import 'GoogleMapWidgetView.dart';

class CreateEventView extends StatefulWidget {
  @override
  _CreateEventViewState createState() => _CreateEventViewState();
}

class _CreateEventViewState extends State<CreateEventView> {

  ProjectController projectController = Get.find<ProjectController>();
  TextEditingController _eventName = new TextEditingController();
  TextEditingController _eventDescription = new TextEditingController();
  TextEditingController _eventLocation = new TextEditingController();
  TextEditingController _eventStartDate = new TextEditingController();
  TextEditingController _eventEndDate = new TextEditingController();

  DateTime _start = new DateTime.now();
  DateTime _due = new DateTime.now().add(Duration(days: 1));

  final eventFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Event'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.autorenew),
            tooltip: 'Clear fields',
            onPressed: () {
              _eventName.clear();
              _eventDescription.clear();
              _eventStartDate.clear();
              _eventEndDate.clear();
              _eventLocation.clear();
            },
          )
        ],
      ),
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
                    controller: _eventName,
                    validator: (eventNameVal) =>
                    eventNameVal.isEmpty
                        ? "Event name cannot be empty"
                        : null,
                    onSaved: (eventNameVal) => _eventName.text = eventNameVal,
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
                    controller: _eventDescription,
                    validator: (eventDescriptionVal) =>
                    eventDescriptionVal.isEmpty
                        ? "Event description cannot be empty"
                        : null,
                    onSaved: (eventDescriptionVal) =>
                    _eventDescription.text = eventDescriptionVal,
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
                          controller: _eventStartDate,
                          validator: (startDateVal) =>
                          startDateVal.isEmpty
                              ? 'Start date cannot be empty'
                              : null,
                          onSaved: (startDateVal) =>
                          startDateVal.length >= 10
                              ? _eventStartDate.text =
                              startDateVal.substring(0, 10)
                              : _eventStartDate.clear(),
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
                          controller: _eventEndDate,
                          validator: (dueDateVal) =>
                          dueDateVal.isEmpty
                              ? 'End date cannot be empty'
                              : null,
                          onSaved: (dueDateVal) =>
                          dueDateVal.length >= 10
                              ? _eventEndDate.text = dueDateVal.substring(0, 10)
                              : _eventEndDate.clear(),
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
                          child: TextFormField(
                            controller: _eventLocation,
                            focusNode: AlwaysDisabledFocusNode(),
                            textAlignVertical: TextAlignVertical.center,
                            readOnly: true,
                            decoration: InputDecoration(
                                hintText: 'Event location',
                                prefixIcon: Icon(
                                  Icons.location_on,
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20))),
                            onTap: () async =>
                            _eventLocation.text =
                            await Get.to(GoogleMapWidgetView(),
                                transition: Transition.downToUp),
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
                          print(_eventName.text);
                          print(_eventDescription.text);
                          print(_eventStartDate.text);
                          print(_eventEndDate.text);
                          print(_eventLocation.text);
                          ProjectCollection().createNewEvent(
                              projectController.project.projectID, _eventName.text,
                              _eventDescription.text, _eventStartDate.text, _eventEndDate.text, _eventLocation.text);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const Text('Add Event',
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
        _eventStartDate.text = picked[0].toString().substring(0, 10);
        _eventEndDate.text = picked[0].toString().substring(0, 10);
        return;
      } else if (!picked[1].isNullOrBlank) {
        _eventStartDate.text = picked[1].toString().substring(0, 10);
        _eventEndDate.text = picked[1].toString().substring(0, 10);
        return;
      }
    }
    if (picked != null && picked.length == 2 && picked[0] != picked[1]) {
      _start = picked[0];
      _eventStartDate.text = picked[0].toString().substring(0, 10);
      _due = picked[1];
      _eventEndDate.text = picked[1].toString().substring(0, 10);
      return;
    }
  }
}
