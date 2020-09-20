import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:swe496/Views/Project/MembersView.dart';
import 'package:swe496/controllers/projectController.dart';
import 'package:swe496/utils/root.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

class TasksAndEventsView extends StatefulWidget {
  final String projectID;

  TasksAndEventsView({Key key, this.projectID}) : super(key: key);

  @override
  _TasksAndEvents createState() => _TasksAndEvents();
}

class _TasksAndEvents extends State<TasksAndEventsView> {
  int barIndex = 0; // Current page index in bottom navigation bar
  ProjectController projectController = Get.find<ProjectController>();

  TextEditingController _taskName = new TextEditingController();
  TextEditingController _taskDescription = new TextEditingController();
  TextEditingController _taskStatus = new TextEditingController();
  TextEditingController _taskPriority = new TextEditingController();
  TextEditingController _startDate = new TextEditingController(
      text: DateTime.now().toString().substring(0, 10));
  TextEditingController _dueDate = new TextEditingController(
      text: DateTime.now().toString().substring(0, 10));
  TextEditingController _assignedBy = new TextEditingController();
  TextEditingController _assignedTo = new TextEditingController();

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
            color: Colors.white,
          ),
          onPressed: () {
            Get.offAll(Root());
            projectController.clear();
            print("back to 'Root' from 'TaskAndEventsView'");
          },
        ),
        title: Text(projectController.project.projectName),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            color: Colors.white,
            onPressed: () {
              // Open project settings page
            },
          )
        ],
      ),
      body: Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: MediaQuery
            .of(context)
            .size
            .height,
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
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.grey,
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
      marginRight: 18,
      marginBottom: 20,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 25.0),
      // this is ignored if animatedIcon is non null
      // child: Icon(Icons.add),
      // If true user is forced to close dial manually
      // by tapping main button and overlay is not rendered.
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.3,
      onOpen: () => print('OPENING MENU'),
      onClose: () => print('MENU CLOSED'),
      tooltip: 'Menu',
      heroTag: '',
      backgroundColor: Colors.white,
      foregroundColor: Colors.red,
      elevation: 8.0,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
          child: Icon(
            Icons.timeline,
            size: 25,
          ),
          backgroundColor: Colors.red,
          label: 'Upcoming',
          labelStyle: TextStyle(fontSize: 16.0),
          onTap: () =>
              Get.bottomSheet(
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
                isScrollControlled: true,
                ignoreSafeArea: false,
                backgroundColor: Colors.white,
              ),
        ),
        SpeedDialChild(
          child: Icon(
            Icons.event,
            size: 25,
          ),
          backgroundColor: Colors.red,
          label: 'New Event',
          labelStyle: TextStyle(fontSize: 16.0),
          onTap: () =>
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
                      ),
                      Expanded(child: createNewTask()),
                    ],
                  ),
                ),
                isScrollControlled: true,
                ignoreSafeArea: false,
                backgroundColor: Colors.white,
              ),
        ),
        SpeedDialChild(
          child: Icon(
            Icons.assignment,
            size: 25,
          ),
          backgroundColor: Colors.red,
          label: 'New Task',
          labelStyle: TextStyle(fontSize: 16.0),
          onTap: () =>
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
                      ),
                      Expanded(child: createNewTask()),
                    ],
                  ),
                ),
                isScrollControlled: true,
                ignoreSafeArea: false,
                backgroundColor: Colors.white,
              ),
        ),
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
                  color: Colors.grey[250],
                  boxShadow: [
                    BoxShadow(color: Colors.black12, spreadRadius: 0.5),
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
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Description: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Status: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Priority: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Start date: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'End date: ',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          position: TimelineItemPosition.right,
          iconBackground: Colors.red,
          isFirst: true,
          icon: Icon(
            Icons.assignment,
            color: Colors.white,
          )),
      TimelineModel(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey[250],
                  boxShadow: [
                    BoxShadow(color: Colors.black12, spreadRadius: 0.5),
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
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Description: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Location: (optional) ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Date: ',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          position: TimelineItemPosition.left,
          iconBackground: Colors.red,
          isFirst: true,
          icon: Icon(
            Icons.event,
            color: Colors.white,
          )),
      TimelineModel(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey[250],
                  boxShadow: [
                    BoxShadow(color: Colors.black12, spreadRadius: 0.5),
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
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Description: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Status: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Priority: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Start date: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'End date: ',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          position: TimelineItemPosition.right,
          iconBackground: Colors.red,
          isFirst: true,
          icon: Icon(
            Icons.assignment,
            color: Colors.white,
          )),
    ];

    return Timeline(children: items, position: TimelinePosition.Center);
  }

  Widget createNewTask() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 8),
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 35,
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
                      controller: _startDate,
                      onSaved: (startDateVal) =>
                      _startDate.text = startDateVal.substring(0, 10),
                      readOnly: true,
                      decoration: InputDecoration(
                          labelText: 'Start date',
                          hintText: DateTime.now().toString().substring(0, 10),
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
                      controller: _dueDate,
                      onSaved: (dueDateVal) => _dueDate.text = dueDateVal,
                      readOnly: true,
                      decoration: InputDecoration(
                          labelText: 'Due date',
                          hintText: DateTime.now().toString().substring(0, 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(20)))),
                      onTap: () async {
                        pickDate();
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),

              //TODO: Stopped here
              TextFormField(
                controller: _taskPriority,
                validator: (taskNameVal) =>
                taskNameVal.isEmpty ? "Task name cannot be empty" : null,
                onSaved: (taskNameVal) => _taskName.text = taskNameVal,
                decoration: InputDecoration(
                    labelText: 'Task name',
                    hintText: 'Meet the client at 9:00 pm',
                    prefixIcon: Icon(Icons.edit)),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _taskName,
                validator: (taskNameVal) =>
                taskNameVal.isEmpty ? "Task name cannot be empty" : null,
                onSaved: (taskNameVal) => _taskName.text = taskNameVal,
                decoration: InputDecoration(
                    labelText: 'Task name',
                    hintText: 'Meet the client at 9:00 pm',
                    prefixIcon: Icon(Icons.edit)),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _taskName,
                validator: (taskNameVal) =>
                taskNameVal.isEmpty ? "Task name cannot be empty" : null,
                onSaved: (taskNameVal) => _taskName.text = taskNameVal,
                decoration: InputDecoration(
                    labelText: 'Task name',
                    hintText: 'Meet the client at 9:00 pm',
                    prefixIcon: Icon(Icons.edit)),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _taskName,
                validator: (taskNameVal) =>
                taskNameVal.isEmpty ? "Task name cannot be empty" : null,
                onSaved: (taskNameVal) => _taskName.text = taskNameVal,
                decoration: InputDecoration(
                    labelText: 'Task name',
                    hintText: 'Meet the client at 9:00 pm',
                    prefixIcon: Icon(Icons.edit)),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _taskName,
                validator: (taskNameVal) =>
                taskNameVal.isEmpty ? "Task name cannot be empty" : null,
                onSaved: (taskNameVal) => _taskName.text = taskNameVal,
                decoration: InputDecoration(
                    labelText: 'Task name',
                    hintText: 'Meet the client at 9:00 pm',
                    prefixIcon: Icon(Icons.edit)),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _taskName,
                validator: (taskNameVal) =>
                taskNameVal.isEmpty ? "Task name cannot be empty" : null,
                onSaved: (taskNameVal) => _taskName.text = taskNameVal,
                decoration: InputDecoration(
                    labelText: 'Task name',
                    hintText: 'Meet the client at 9:00 pm',
                    prefixIcon: Icon(Icons.edit)),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _decideWhichDayToEnable(DateTime day) {
    if ((day.isAfter(DateTime.now().subtract(Duration(days: 1))) &&
        day.isBefore(DateTime.now().add(Duration(days: 1460))))) {
      return true;
    }
    return false;
  }

  void pickDate() async {
    final List<DateTime> picked =
    await DateRagePicker.showDatePicker(
      context: context,
      initialFirstDate: _start,
      initialLastDate: _due,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(Duration(days: 2 * 365)),
      selectableDayPredicate: _decideWhichDayToEnable,
    );
    if (picked != null && picked.length == 2)
      if (picked[0] != picked[1]) {
        _start = picked[0];
      _startDate.text = picked[0].toString().substring(0, 10);
      _due = picked[1];
      _dueDate.text = picked[1].toString().substring(0, 10);
    }
  }
}
