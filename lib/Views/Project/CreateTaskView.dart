import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:swe496/Database/ProjectCollection.dart';
import 'package:swe496/Database/UserProfileCollection.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:swe496/controllers/ProjectControllers/projectController.dart';
import 'package:swe496/controllers/UserControllers/userController.dart';

class CreateTaskView extends StatefulWidget {
  @override
  _CreateTaskViewState createState() => _CreateTaskViewState();
}

class _CreateTaskViewState extends State<CreateTaskView> {
  final formKey = GlobalKey<FormState>();

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
      appBar: AppBar(
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
              if(this.mounted){
                setState(() {
                  _taskName.clear();
                  _taskDescription.clear();
                  _taskStatus.clear();
                  _taskPriority.text = 'Low';
                  _taskStartDate.clear();
                  _taskDueDate.clear();
                  _taskAssignedTo.clear();
                });
              }
            },
          )
        ],
      ),
      body: Padding(
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
                    validator: (taskNameVal) => taskNameVal.isEmpty
                        ? "Task name cannot be empty"
                        : null,
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
                          onTap: () async => pickDate(),
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
                          border: Border.all(
                              color: Get.theme.unselectedWidgetColor),
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
                            StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState
                                    /*You can rename this!*/) {
                              return RadioButtonGroup(
                                labels: <String>["Low", "Medium", "High"],
                                picked: _taskPriority.text,
                                onSelected: (String selected) {
                                  _taskPriority.text = selected;
                                  if(this.mounted){
                                    setState(() {});
                                  }
                                  print(_taskPriority.text);
                                },
                              );
                            }),
                            SizedBox(
                              height: 10,
                            ),
                          ]),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),  InkWell(
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child: Container(
                      foregroundDecoration: BoxDecoration(
                          border: Border.all(
                              color: Get.theme.unselectedWidgetColor),
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
                                        child:
                                        Text("No members in the project")),
                                  );
                                return SearchableDropdown.single(
                                  items:
                                  snapshot.data.documents.toList().map((i) {
                                    return (DropdownMenuItem(
                                      child: Text(i.data['userName']),
                                      value: i.data['userName'] +
                                          ',' +
                                          i.data['userID'],
                                      onTap: () {},
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
                          Get.back();
                          Get.snackbar('Success !', "Task '${_taskName.text} has been created successfully.'");
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
      ),
    );
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
        _taskStartDate.text = picked[0].toString().substring(0, 10);
        _taskDueDate.text = picked[0].toString().substring(0, 10);
        return;
      } else if (!picked[1].isNullOrBlank) {
        _taskStartDate.text = picked[1].toString().substring(0, 10);
        _taskDueDate.text = picked[1].toString().substring(0, 10);
        return;
      }
    }

    if (picked != null && picked.length == 2 && picked[0] != picked[1]) {
      _start = picked[0];
      _taskStartDate.text = picked[0].toString().substring(0, 10);
      _due = picked[1];
      _taskDueDate.text = picked[1].toString().substring(0, 10);
      return;
    }
  }

  bool _decideWhichDayToEnable(DateTime day) {
    if ((day.isAfter(DateTime.now().subtract(Duration(days: 1))) &&
        day.isBefore(DateTime.now().add(Duration(days: 365 * 2))))) {
      return true;
    }
    return false;
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
