import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:swe496/Database/ProjectCollection.dart';
import 'package:swe496/Database/UserProfileCollection.dart';
import 'package:swe496/Views/Project/MembersView.dart';
import 'package:swe496/controllers/projectController.dart';
import 'package:swe496/controllers/userController.dart';
import 'package:swe496/models/Members.dart';
import 'package:swe496/utils/root.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:searchable_dropdown/searchable_dropdown.dart';

class TasksAndEventsView extends StatefulWidget {
  final String projectID;

  TasksAndEventsView({Key key, this.projectID}) : super(key: key);

  @override
  _TasksAndEvents createState() => _TasksAndEvents();
}

class _TasksAndEvents extends State<TasksAndEventsView> {
  int barIndex = 0; // Current page index in bottom navigation bar
  ProjectController projectController = Get.find<ProjectController>();
  UserController userController = Get.find<UserController>();

  TextEditingController _taskName = new TextEditingController();
  TextEditingController _taskDescription = new TextEditingController();
  TextEditingController _taskStatus = new TextEditingController();
  TextEditingController _taskPriority = new TextEditingController(text: 'Low');
  TextEditingController _taskStartDate = new TextEditingController(
      text: DateTime.now().toString().substring(0, 10));
  TextEditingController _taskDueDate = new TextEditingController(
      text: DateTime.now().toString().substring(0, 10));
  TextEditingController _taskAssignedBy = new TextEditingController();
  TextEditingController _taskAssignedTo = new TextEditingController();

  DateTime _start = new DateTime.now();
  DateTime _due = new DateTime.now().add(Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      // still not working in landscape mode
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 30,
          ),
          onPressed: () {
            Get.offAll(Root());
            projectController.clear();
            print("back to 'Root' from 'TaskAndEventsView'");
          },
        ),
        title: Text(projectController.project.projectName),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Open project settings page
            },
          )
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            _searchBar(),
          ],
        ),
      ),
      bottomNavigationBar: bottomCustomNavigationBar(),
      floatingActionButton: floatingButtons(context),
    );
  }

  // Search Bar
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(hintText: 'Search'),
        onChanged: (textVal) {
          textVal = textVal.toLowerCase();
          setState(() {});
        },
      ),
    );
  }

  // Bottom Navigation Bar
  Widget bottomCustomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_turned_in),
          title: Text('Tasks & Events'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          title: Text('Chat'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_work),
          title: Text('Members'),
        ),
      ],
      currentIndex: barIndex,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: (index) {
        setState(() {
          barIndex = index;

          if (barIndex == 0) // Do nothing, stay in the same page
            return;
          else if (barIndex == 1)
            return;
          else if (barIndex == 2)
            Get.off(MembersView(), transition: Transition.noTransition);
        });
        print(index);
      },
    );
  }

  Widget floatingButtons(BuildContext context) {
    return SpeedDial(
      // both default to 16
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 25.0),
      // this is ignored if animatedIcon is non null
      // child: Icon(Icons.add),
      // If true user is forced to close dial manually
      // by tapping main button and overlay is not rendered.
      closeManually: false,
      curve: Curves.bounceIn,
      overlayOpacity: 0.5,
      onOpen: () => print('OPENING MENU'),
      onClose: () => print('MENU CLOSED'),
      tooltip: 'Menu',
      heroTag: '',
      elevation: 8.0,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
          child: Icon(
            Icons.timeline,
            size: 25,
          ),
          label: 'Upcoming',
          onTap: () => Get.bottomSheet(
            Container(
              child: Column(
                children: [
                  AppBar(
                    title: Text('Timeline'),
                    centerTitle: true,
                    leading: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  Expanded(child: viewTimeLineOfTasksAndEvents()),
                ],
              ),
            ),
            backgroundColor: Get.theme.canvasColor,
            isScrollControlled: true,
            ignoreSafeArea: false,
          ),
        ),
        SpeedDialChild(
          child: Icon(
            Icons.event,
            size: 25,
          ),
          label: 'New Event',
          onTap: () {
            Get.bottomSheet(
              Container(
                child: Column(
                  children: [
                    AppBar(
                      title: Text('New Event'),
                      centerTitle: true,
                      leading: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Get.back(),
                      ),
                    ),
                    Expanded(
                      child: StatefulBuilder(
                        builder:
                            (BuildContext context, StateSetter innerSetState) {
                          return createNewEvent();
                        },
                      ),
                    )
                  ],
                ),
              ),
              backgroundColor: Get.theme.canvasColor,
              isScrollControlled: true,
              ignoreSafeArea: false,
            );
          },
        ),
        SpeedDialChild(
            child: Icon(
              Icons.assignment,
              size: 25,
            ),
            label: 'New Task',
            onTap: () {
              Get.bottomSheet(
                Container(
                  child: Column(
                    children: [
                      AppBar(
                        title: Text('New Task'),
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
                              _taskName.clear();
                              _taskDescription.clear();
                              _taskStartDate.clear();
                              _taskDueDate.clear();
                            },
                          ),
                        ],
                      ),
                      Expanded(
                        child: StatefulBuilder(
                          builder: (BuildContext context,
                              StateSetter innerSetState) {
                            return createNewTask(innerSetState);
                          },
                        ),
                      )
                    ],
                  ),
                ),
                backgroundColor: Get.theme.canvasColor,
                isScrollControlled: true,
                ignoreSafeArea: false,
              );
            }),
      ],
    );
  }

  Widget viewTimeLineOfTasksAndEvents() {
    List<TimelineModel> items = [
      TimelineModel(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(spreadRadius: 0.5),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: 300, minWidth: 200, minHeight: 200),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Task name: ',
                        ),
                        Text(
                          'Description: ',
                        ),
                        Text(
                          'Status: ',
                        ),
                        Text(
                          'Priority: ',
                        ),
                        Text(
                          'Start date: ',
                        ),
                        Text(
                          'End date: ',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          position: TimelineItemPosition.right,
          isFirst: true,
          icon: Icon(
            Icons.assignment,
          )),
      TimelineModel(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(spreadRadius: 0.5),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: 300, minWidth: 200, minHeight: 200),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Event name: ',
                        ),
                        Text(
                          'Description: ',
                        ),
                        Text(
                          'Location: (optional) ',
                        ),
                        Text(
                          'Date: ',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          position: TimelineItemPosition.left,
          isFirst: true,
          icon: Icon(
            Icons.event,
          )),
      TimelineModel(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(spreadRadius: 0.5),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: 300, minWidth: 200, minHeight: 200),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Task name: ',
                        ),
                        Text(
                          'Description: ',
                        ),
                        Text(
                          'Status: ',
                        ),
                        Text(
                          'Priority: ',
                        ),
                        Text(
                          'Start date: ',
                        ),
                        Text(
                          'End date: ',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          position: TimelineItemPosition.right,
          isFirst: true,
          icon: Icon(
            Icons.assignment,
          )),
    ];

    return Timeline(children: items, position: TimelinePosition.Center);
  }

  Widget createNewTask(innerSetState) {
    final formKey = GlobalKey<FormState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 8),
      child: Container(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _taskName,
                  validator: (taskNameVal) =>
                      taskNameVal.isEmpty ? "Task name cannot be empty" : null,
                  onSaved: (taskNameVal) => _taskName.text = taskNameVal,
                  decoration: InputDecoration(
                      labelText: 'Task name',
                      hintText: 'Meet the client.',
                      prefixIcon: Icon(Icons.edit),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20))),
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _taskDescription,
                  onSaved: (_taskDescriptionVal) =>
                      _taskDescription.text = _taskDescriptionVal,
                  decoration: InputDecoration(
                      labelText: 'Task description',
                      hintText:
                          'Collect the requirements from the client and refine them.',
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
                        controller: _taskStartDate,
                        validator: (startDateVal) => startDateVal.isEmpty
                            ? 'Start date cannot be empty'
                            : null,
                        onSaved: (startDateVal) => startDateVal.length >= 10
                            ? _taskStartDate.text =
                                startDateVal.substring(0, 10)
                            : _taskStartDate.clear(),
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
                        controller: _taskDueDate,
                        validator: (dueDateVal) => dueDateVal.isEmpty
                            ? 'Due date cannot be empty'
                            : null,
                        onSaved: (dueDateVal) => dueDateVal.length >= 10
                            ? _taskDueDate.text = dueDateVal.substring(0, 10)
                            : _taskDueDate.clear(),
                        readOnly: true,
                        decoration: InputDecoration(
                            labelText: 'Due date',
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
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  child: Container(
                    foregroundDecoration: BoxDecoration(
                        border:
                            Border.all(color: Get.theme.unselectedWidgetColor),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  focusNode: AlwaysDisabledFocusNode(),
                                  textAlignVertical: TextAlignVertical.center,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                      hintText: 'Task Priority',
                                      prefixIcon: Icon(
                                        Icons.assignment_late,
                                      ),
                                      border: InputBorder.none),
                                ),
                              ),
                            ],
                          ),
                          RadioButtonGroup(
                              labels: <String>["Low", "Medium", "High"],
                              onSelected: (String selected) {
                                _taskPriority.text = selected;
                                print(_taskPriority.text);
                              }),
                          SizedBox(
                            height: 10,
                          ),
                        ]),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  child: Container(
                    foregroundDecoration: BoxDecoration(
                        border:
                            Border.all(color: Get.theme.unselectedWidgetColor),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: StreamBuilder<QuerySnapshot>(
                        stream: UserProfileCollection().checkUserProjectsIDs(
                            projectController.project.projectID),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.active) {
                            if (snapshot.hasData && snapshot.data != null) {
                              if (snapshot.data.documents.length == 0)
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                      child: Text("No members in the project")),
                                );
                              return SearchableDropdown.single(
                                items:
                                    snapshot.data.documents.toList().map((i) {
                                  return (DropdownMenuItem(
                                    child: Text(i.data['userName']),
                                    value: i.data['userName'] + ',' + i.data['userID'],
                                    onTap: (){},

                                  ));
                                }).toList(),
                                displayItem: (item, selected) {
                                  return (Row(children: [
                                    selected
                                        ? Icon(
                                            Icons.radio_button_checked,
                                          )
                                        : Icon(
                                            Icons.radio_button_unchecked,
                                          ),
                                    SizedBox(width: 7),
                                    Expanded(
                                      child: item,
                                    ),
                                  ]));
                                },
                                isCaseSensitiveSearch: false,
                                displayClearIcon: true,
                                value: _taskAssignedTo.text,
                                hint: "Assign a member",
                                searchHint: "Assign a member",
                                dialogBox: true,
                                keyboardType: TextInputType.text,
                                isExpanded: true,
                                onChanged: (assignedToVal) {
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                  _taskAssignedTo.text = assignedToVal;
                                },
                                onClear: () {
                                  _taskAssignedTo.clear();
                                },
                              );
                            }
                          }
                          return Container(
                            child: Center(
                              child: CircularProgressIndicator(
                                semanticsLabel: 'Loading',
                                strokeWidth: 4,
                              ),
                            ),
                          );
                        }),
                  ),
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
                      formKey.currentState.save();
                      if (formKey.currentState.validate()) {

                        _taskAssignedBy.text = userController.user.userID;
                        _taskStatus.text = 'Not-Started';

                        ProjectCollection().createNewTask(
                            projectController.project.projectID,
                            _taskName.text.trim(),
                            _taskDescription.text.trim(),
                            _taskStartDate.text,
                            _taskDueDate.text,
                            _taskPriority.text,
                            _taskAssignedTo.text,
                            _taskAssignedBy.text,
                            _taskStatus.text);
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Text('Add Task',
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
    if (picked != null && picked.length == 2 && picked[0] != picked[1]) {
      _start = picked[0];
      _taskStartDate.text = picked[0].toString().substring(0, 10);
      _due = picked[1];
      _taskDueDate.text = picked[1].toString().substring(0, 10);
    }
  }

  Widget createNewEvent() {}
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
