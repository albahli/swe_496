import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:swe496/Database/ProjectCollection.dart';
import 'package:swe496/controllers/TaskOfProjectController.dart';
import 'package:swe496/controllers/projectController.dart';
import 'package:swe496/controllers/userController.dart';
import 'package:swe496/models/TaskOfProject.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

class TaskView extends StatefulWidget {
  const TaskView({Key key, this.taskID}) : super(key: key);
  final String taskID;

  @override
  _TaskViewState createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  int remainingDays = 0;

  ProjectController projectController = Get.find<ProjectController>();
  UserController userController = Get.find<UserController>();

  // Below attributes for creating new subtask
  final formKey = GlobalKey<FormState>();

  TextEditingController _subtaskName = new TextEditingController();

  TextEditingController _subtaskDescription = new TextEditingController();

  TextEditingController _subtaskStatus = new TextEditingController();

  TextEditingController _subtaskPriority =
      new TextEditingController(text: 'Low');

  TextEditingController _subtaskStartDate = new TextEditingController(
      text: DateTime.now().toString().substring(0, 10));

  TextEditingController _subtaskDueDate = new TextEditingController(
      text: DateTime.now().toString().substring(0, 10));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: Container(
        child: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(
            children: [
              GetX<TaskOfProjectController>(
                  init: Get.put<TaskOfProjectController>(
                      TaskOfProjectController()),
                  builder: (TaskOfProjectController taskOfProjectController) {
                    if (taskOfProjectController != null &&
                        taskOfProjectController.tasks != null) {
                      return Column(
                        children: [
                          taskCard(taskOfProjectController.tasks[0]),
                          taskOfProjectController.tasks[0].subtask.length == 0
                              ? SizedBox()
                              : subtasksTitle(),
                          ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount:
                                taskOfProjectController.tasks[0].subtask.length,
                            itemBuilder: (_, index) {
                              return taskCard(taskOfProjectController
                                  .tasks[0].subtask[index]);
                            },
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Spacer(),
                              FloatingActionButton(
                                child: Icon(Icons.add),
                                tooltip: 'Add Subtask',
                                onPressed: () {
                                  Get.bottomSheet(
                                    createSubTaskView(
                                        taskOfProjectController.tasks[0]),
                                    isScrollControlled: true,
                                    ignoreSafeArea: false,
                                  );
                                },
                              ),
                              Spacer(),
                              Expanded(
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '',
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Spacer(),
                              SizedBox(
                                width: 155,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 100,
                            height: 100,
                          )
                        ],
                      );
                    }
                    return Text('nothing');
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget subtasksTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Spacer(),
        Dash(
          direction: Axis.vertical,
          dashGap: 5,
          length: 150,
          dashLength: 5,
          dashColor: Get.theme.unselectedWidgetColor,
        ),
        Spacer(),
        Expanded(
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Subtasks',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        Spacer(),
        SizedBox(
          width: 100,
        ),
      ],
    );
  }

  Widget taskCard(TaskOfProject taskOfProject) {
    // Formatting the current date
    var now = new DateTime.now().subtract(Duration(days: 1));
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    print(formattedDate);

    Jiffy taskDueDate = Jiffy(taskOfProject.dueDate, "yyyy-MM-dd");

    remainingDays = taskDueDate.diff(formattedDate, Units.DAY);

    return Column(
      children: [
        Card(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border(
                        left: BorderSide(
                            width: 3,
                            color: taskOfProject.taskStatus.toUpperCase()=='COMPLETED' ? Colors.green :(remainingDays <= 0
                                ? Colors.red
                                : (taskOfProject.taskStatus.toUpperCase() ==
                                        'NOT-STARTED'
                                    ? Colors.grey
                                    : (taskOfProject.taskStatus.toUpperCase() ==
                                            'IN-PROGRESS'
                                        ? Colors.blue
                                        : Colors.green)))))),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(taskOfProject.taskName),
                      leading: Wrap(
                        children: [Icon(Icons.assignment)],
                      ),
                      subtitle: Text(
                          "Due date ${taskOfProject.dueDate.toString().substring(0, 10)}"),
                      trailing: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${taskOfProject.taskPriority.toUpperCase()}',
                          style: TextStyle(
                              color: taskOfProject.taskPriority.toUpperCase() ==
                                      'LOW'
                                  ? Colors.green
                                  : (taskOfProject.taskPriority.toUpperCase() ==
                                          'HIGH'
                                      ? Colors.red
                                      : Colors.orange)),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Divider(),
                        Flexible(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(taskOfProject.taskDescription),
                        ))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            (taskOfProject.taskStatus.toUpperCase() ==
                                    'COMPLETED'
                                ? 'Completed'
                                : (remainingDays < 1
                                    ? 'Overdue'
                                    : 'Days left: $remainingDays')),
                            style: TextStyle(
                                color: taskOfProject.taskStatus.toUpperCase() ==
                                        'COMPLETED'
                                    ? Get.theme.primaryColor
                                    : (remainingDays <= 1
                                        ? Colors.red
                                        : (remainingDays < 3
                                            ? Colors.orange
                                            : Get.theme.primaryColor))),
                          ),
                        ),
                        Spacer(),
                        ButtonBar(
                          alignment: MainAxisAlignment.start,
                          children: [
                            FlatButton(
                              onPressed: () {},
                              child: const Text('EDIT'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Spacer(),
            Dash(
              direction: Axis.vertical,
              dashGap: 5,
              length: 50,
              dashLength: 5,
              dashColor: Get.theme.unselectedWidgetColor,
            ),
            Spacer(),
            Expanded(
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            SizedBox(
              width: 100,
            ),
          ],
        ),
      ],
    );
  }

  Widget createSubTaskView(TaskOfProject taskOfProject) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Subtask'),
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
              _subtaskName.clear();
              _subtaskDescription.clear();
              _subtaskStartDate.clear();
              _subtaskDueDate.clear();
            },
          )
        ],
      ),
      resizeToAvoidBottomPadding: false,
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
                    controller: _subtaskName,
                    validator: (taskNameVal) => taskNameVal.isEmpty
                        ? "Subtask name cannot be empty"
                        : null,
                    onSaved: (taskNameVal) => _subtaskName.text = taskNameVal,
                    decoration: InputDecoration(
                        labelText: 'Subtask name',
                        hintText: 'Meet the client.',
                        prefixIcon: Icon(Icons.edit),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _subtaskDescription,
                    validator: (taskNameVal) => taskNameVal.isEmpty
                        ? "Subtask description cannot be empty"
                        : null,
                    onSaved: (_taskDescriptionVal) =>
                        _subtaskDescription.text = _taskDescriptionVal,
                    decoration: InputDecoration(
                        labelText: 'Subtask description',
                        hintText:
                            'Collect the requirements from the client and refine them.',
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                    maxLines: 5,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text('Subtask dates limited to the main tasks date.'),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _subtaskStartDate,
                          validator: (startDateVal) => startDateVal.isEmpty
                              ? 'Start date cannot be empty'
                              : null,
                          onSaved: (startDateVal) => startDateVal.length >= 10
                              ? _subtaskStartDate.text =
                                  startDateVal.substring(0, 10)
                              : _subtaskStartDate.clear(),
                          readOnly: true,
                          decoration: InputDecoration(
                              labelText: 'Start date',
                              hintText:
                                  DateTime.now().toString().substring(0, 10),
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(20)))),
                          onTap: () async => pickDate(
                              taskOfProject.startDate, taskOfProject.dueDate),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _subtaskDueDate,
                          validator: (dueDateVal) => dueDateVal.isEmpty
                              ? 'Due date cannot be empty'
                              : null,
                          onSaved: (dueDateVal) => dueDateVal.length >= 10
                              ? _subtaskDueDate.text =
                                  dueDateVal.substring(0, 10)
                              : _subtaskDueDate.clear(),
                          readOnly: true,
                          decoration: InputDecoration(
                              labelText: 'Due date',
                              hintText:
                                  DateTime.now().toString().substring(0, 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.horizontal(
                                      right: Radius.circular(20)))),
                          onTap: () async => pickDate(
                              taskOfProject.startDate, taskOfProject.dueDate),
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
                                        hintText: 'Subtask Priority',
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
                                  _subtaskPriority.text = selected;
                                  print(_subtaskPriority.text);
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
                          _subtaskStatus.text = 'Not-Started';
                          ProjectCollection().createNewSubtask(
                              projectController.project.projectID,
                              taskOfProject.taskID,
                              _subtaskName.text,
                              _subtaskDescription.text,
                              _subtaskStartDate.text,
                              _subtaskDueDate.text,
                              _subtaskPriority.text,
                              _subtaskStatus.text);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const Text('Add Subtask',
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

  void pickDate(String startDate, String dueDate) async {
    var start = DateFormat('yyyy-M-d').parse(startDate);
    var due = DateFormat('yyyy-M-d').parse(dueDate);
    final List<DateTime> picked = await DateRagePicker.showDatePicker(
      context: context,
      initialFirstDate: start,
      initialLastDate: due,
      firstDate: start,
      lastDate: due,
    );
    if (picked != null && picked.length == 1) {
      if (!picked[0].isNullOrBlank) {
        _subtaskStartDate.text = picked[0].toString().substring(0, 10);
        _subtaskDueDate.text = picked[0].toString().substring(0, 10);
        return;
      } else if (!picked[1].isNullOrBlank) {
        _subtaskStartDate.text = picked[1].toString().substring(0, 10);
        _subtaskDueDate.text = picked[1].toString().substring(0, 10);
        return;
      }
    }

    if (picked != null && picked.length == 2 && picked[0] != picked[1]) {
      start = picked[0];
      _subtaskStartDate.text = picked[0].toString().substring(0, 10);
      due = picked[1];
      _subtaskDueDate.text = picked[1].toString().substring(0, 10);
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
