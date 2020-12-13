import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:group_button/group_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:search_choices/search_choices.dart';
import 'package:swe496/Database/ProjectCollection.dart';
import 'package:swe496/Database/UserProfileCollection.dart';
import 'package:swe496/controllers/ProjectControllers/TaskOfProjectController.dart';
import 'package:swe496/controllers/ProjectControllers/projectController.dart';
import 'package:swe496/controllers/UserControllers/userController.dart';
import 'package:swe496/models/TaskOfProject.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:bubble/bubble.dart';
import 'package:swe496/utils/root.dart';

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

  bool isAdmin = true;
  List<bool> isSelected = [true, false, false];

  // Below attributes for creating new subtask
  final addSubTaskFormKey = GlobalKey<FormState>();

  TextEditingController _subtaskName = new TextEditingController();

  TextEditingController _subtaskDescription = new TextEditingController();

  TextEditingController _subtaskStatus = new TextEditingController();

  TextEditingController _subtaskPriority =
      new TextEditingController(text: 'Low');

  TextEditingController _subtaskStartDate = new TextEditingController(
      text: DateTime.now().toString().substring(0, 10));

  TextEditingController _subtaskDueDate = new TextEditingController(
      text: DateTime.now().toString().substring(0, 10));

  // Below attributes for editing tasks or subtasks.
  final editTaskFormKey = GlobalKey<FormState>();

  TextEditingController _editedSubtaskName = new TextEditingController();

  TextEditingController _editedSubtaskDescription = new TextEditingController();

  TextEditingController _editedSubtaskPriority = new TextEditingController();

  TextEditingController _editedSubtaskStartDate = new TextEditingController(
      text: DateTime.now().toString().substring(0, 10));

  TextEditingController _editedSubtaskDueDate = new TextEditingController(
      text: DateTime.now().toString().substring(0, 10));

  TextEditingController _mainTaskDueDate = new TextEditingController();

  // Main Task ID
  TextEditingController _mainTaskID = new TextEditingController();

  // Task is assigned for a user
  TextEditingController _editedTaskAssignedTo = new TextEditingController();

  // For comment text field
  TextEditingController _commentController = new TextEditingController();

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    projectController.project.members.forEach((member) {
      if (member.memberUID == userController.user.userID && !member.isAdmin) {
        setState(() {
          isAdmin = false;
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            // Here if project is deleted while the task view is opened, it will navigate
            // to the root.
            if (!projectController.initialized ||
                projectController.project == null) {
              Get.delete<TaskOfProjectController>();
              Get.offAll(Root());
              Get.delete<
                  ProjectController>();
            } else {
              Get.delete<TaskOfProjectController>();
              Get.back();
            }
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
                        taskOfProjectController.tasks != null &&
                        taskOfProjectController.tasks.isNotEmpty) {
                      isAdmin
                          ? ProjectCollection().readNotificationByLeader(
                              projectController.projectID,
                              taskOfProjectController.tasks[0].taskID)
                          : ProjectCollection()
                              .readNotificationByAssignedMember(
                                  projectController.projectID,
                                  taskOfProjectController.tasks[0].taskID);
                      // Sort the tasks and events based on due date
                      taskOfProjectController.tasks[0].subtask
                          .sort((a, b) => a.dueDate.compareTo(b.dueDate));

                      return Column(
                        children: [
                          taskCard(
                              taskOfProjectController.tasks[0], true, false),
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
                              return taskCard(
                                  taskOfProjectController
                                      .tasks[0].subtask[index],
                                  false,
                                  (index ==
                                          taskOfProjectController
                                                  .tasks[0].subtask.length -
                                              1
                                      ? true
                                      : false));
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
                              isAdmin
                                  ? FloatingActionButton(
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
                                    )
                                  : SizedBox(),
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
                          ),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Center(
                                    child: Text(
                                  'Comments',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                )),
                                Divider(
                                  thickness: 2,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  child: taskOfProjectController
                                                  .tasks[0].message.length ==
                                              0 ||
                                          taskOfProjectController
                                              .tasks[0].message.isEmpty
                                      ? Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Text(
                                            'No comments',
                                            style: TextStyle(
                                              color: Get
                                                  .theme.unselectedWidgetColor,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ))
                                      : ListView.builder(
                                          controller: _scrollController,
                                          physics: ScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: taskOfProjectController
                                              .tasks[0].message.length,
                                          itemBuilder: (_, index) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: taskOfProjectController
                                                          .tasks[0]
                                                          .message[index]
                                                          .senderID ==
                                                      userController.user.userID
                                                  ? Bubble(
                                                      margin: BubbleEdges.only(
                                                          top: 10),
                                                      color: Get.theme
                                                          .primaryColorLight,
                                                      alignment:
                                                          Alignment.topRight,
                                                      nip:
                                                          BubbleNip.rightBottom,
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                '${taskOfProjectController.tasks[0].message[index].from}',
                                                                style: TextStyle(
                                                                    color: Get
                                                                        .theme
                                                                        .accentColor),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                              ),
                                                              Spacer(),
                                                              Text(
                                                                '${taskOfProjectController.tasks[0].message[index].time.toDate().toString().substring(0, 16)}',
                                                                style:
                                                                    TextStyle(
                                                                  color: Get
                                                                      .theme
                                                                      .unselectedWidgetColor,
                                                                  fontSize: 10,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Row(
                                                              children: [
                                                                Flexible(
                                                                  child: Text(
                                                                    '${taskOfProjectController.tasks[0].message[index].contentOfMessage}',
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [],
                                                          )
                                                        ],
                                                      ),
                                                      padding:
                                                          BubbleEdges.all(8),
                                                    )
                                                  : Bubble(
                                                      margin: BubbleEdges.only(
                                                          top: 10),
                                                      alignment:
                                                          Alignment.topLeft,
                                                      nip: BubbleNip.leftBottom,
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                '${taskOfProjectController.tasks[0].message[index].from}',
                                                                style: TextStyle(
                                                                    color: Get
                                                                        .theme
                                                                        .accentColor),
                                                                textAlign:
                                                                    TextAlign
                                                                        .left,
                                                              ),
                                                              Spacer(),
                                                              Text(
                                                                '${taskOfProjectController.tasks[0].message[index].time.toDate().toString().substring(0, 16)}',
                                                                style:
                                                                    TextStyle(
                                                                  color: Get
                                                                      .theme
                                                                      .unselectedWidgetColor,
                                                                  fontSize: 10,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .right,
                                                              ),
                                                            ],
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Row(
                                                              children: [
                                                                Flexible(
                                                                  child: Text(
                                                                      '${taskOfProjectController.tasks[0].message[index].contentOfMessage}'),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [],
                                                          )
                                                        ],
                                                      ),
                                                      padding:
                                                          BubbleEdges.all(8),
                                                    ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 100,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              children: [
                                Divider(
                                  thickness: 2,
                                ),
                              ],
                            ),
                          ),
                          Align(
                            child: Container(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 10, right: 3, left: 3),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Get.theme.cardColor,
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                          boxShadow: [
                                            BoxShadow(
                                                offset: Offset(0, 3),
                                                blurRadius: 5,
                                                color: Colors.grey)
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller: _commentController,
                                                maxLines: null,
                                                decoration: InputDecoration(
                                                    hintText:
                                                        "Add a comment...",
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            20.0),
                                                    border: InputBorder.none),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(left: 3),
                                        child: FloatingActionButton(
                                          heroTag: 'sendCommentByAdmin',
                                          child: Icon(Icons.send),
                                          onPressed: () {
                                            print(
                                                "here '${_commentController.text}'");
                                            _commentController.text.trim();
                                            print(
                                                "here '${_commentController.text}'");

                                            if (_commentController.text.isNull)
                                              return;

                                            ProjectCollection()
                                                .addCommentToTask(
                                                    projectController
                                                        .project.projectID,
                                                    taskOfProjectController
                                                        .tasks[0].taskID,
                                                    userController.user.userID,
                                                    userController
                                                        .user.userName,
                                                    _commentController.text);
                                            _commentController.clear();
                                          },
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return Center(
                        child: Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Text('Task has been deleted'),
                    ));
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

  Widget taskCard(TaskOfProject taskOfProject, bool mainTask, bool last) {
    if (mainTask) {
      _mainTaskDueDate.text = taskOfProject.dueDate;
      _mainTaskID.text = taskOfProject.taskID;
    }
    // Formatting the current date
    var now = new DateTime.now().subtract(Duration(days: 1));
    var formatter = new DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
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
                            color: taskOfProject.taskStatus.toUpperCase() ==
                                    'COMPLETED'
                                ? Colors.green
                                : (remainingDays <= 0
                                    ? Colors.red
                                    : (taskOfProject.taskStatus.toUpperCase() ==
                                            'NOT-STARTED'
                                        ? Colors.grey
                                        : (taskOfProject.taskStatus
                                                    .toUpperCase() ==
                                                'IN-PROGRESS'
                                            ? Colors.blue
                                            : Colors.green)))))),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(taskOfProject.taskName),
                      leading: taskOfProject.taskStatus.toUpperCase() ==
                              'COMPLETED'
                          ? Icon(
                              Icons.assignment_turned_in,
                              color: Colors.green,
                            )
                          : (remainingDays <= 0
                              ? Icon(
                                  Icons.assignment_late,
                                  color: Colors.red,
                                )
                              : (taskOfProject.taskStatus.toUpperCase() ==
                                      'NOT-STARTED'
                                  ? Icon(
                                      Icons.assignment,
                                      color: Colors.grey,
                                    )
                                  : (taskOfProject.taskStatus.toUpperCase() ==
                                          'IN-PROGRESS'
                                      ? Wrap(
                                          children: [
                                            Icon(
                                              Icons.assignment,
                                              color: Colors.blue,
                                            ),
                                            Icon(Icons.edit,
                                                size: 14, color: Colors.blue),
                                          ],
                                        )
                                      : Icon(
                                          Icons.assignment,
                                          color: Colors.grey,
                                        )))),
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
                            isAdmin
                                ? FlatButton(
                                    child: const Text('EDIT'),
                                    onPressed: () {
                                      Get.bottomSheet(
                                          editTask(taskOfProject, mainTask),
                                          isScrollControlled: true,
                                          ignoreSafeArea: false);
                                    },
                                  )
                                : SizedBox(),
                            isAdmin
                                ? IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext bc) {
                                            return Wrap(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Container(
                                                    color:
                                                        Get.theme.canvasColor,
                                                    child: Column(
                                                      children: [
                                                        ListTile(
                                                          title: mainTask
                                                              ? Text(
                                                                  'Delete task? All subtasks will be deleted')
                                                              : Text(
                                                                  'Delete subtask?'),
                                                          trailing: FlatButton(
                                                            child: const Text(
                                                              'DELETE',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              if (mainTask) {
                                                                Get.back();
                                                                await ProjectCollection().deleteTask(
                                                                    projectController
                                                                        .project
                                                                        .projectID,
                                                                    _mainTaskID
                                                                        .text);
                                                                Get.snackbar(
                                                                    'Success',
                                                                    "task has been deleted successfully");
                                                                Get.back();
                                                                return;
                                                              }
                                                              print(taskOfProject
                                                                  .taskName);
                                                              print(taskOfProject
                                                                  .taskDescription);
                                                              print(taskOfProject
                                                                  .taskStatus);
                                                              await ProjectCollection().deleteSubtask(
                                                                  projectController
                                                                      .project
                                                                      .projectID,
                                                                  _mainTaskID
                                                                      .text,
                                                                  taskOfProject
                                                                      .taskID,
                                                                  taskOfProject
                                                                      .taskName,
                                                                  taskOfProject
                                                                      .taskDescription,
                                                                  taskOfProject
                                                                      .startDate,
                                                                  taskOfProject
                                                                      .dueDate,
                                                                  taskOfProject
                                                                      .taskPriority,
                                                                  taskOfProject
                                                                      .taskStatus);
                                                              Get.back();
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
                                : GroupButton(
                                    spacing: 8,
                                    isRadio: true,
                                    direction: Axis.horizontal,
                                    onSelected: (index, isSelected) {
                                      if (index == 0) {
                                        if (mainTask) {
                                          return ProjectCollection()
                                              .changeMainTaskStatus(
                                                  projectController.projectID,
                                                  taskOfProject.taskID,
                                                  'Completed');
                                        } else {
                                          ProjectCollection()
                                              .changeSubtaskStatus(
                                                  projectController.projectID,
                                                  _mainTaskID.text.trim(),
                                                  taskOfProject.taskID.trim(),
                                                  taskOfProject.taskName,
                                                  taskOfProject.taskDescription,
                                                  taskOfProject.startDate,
                                                  taskOfProject.dueDate,
                                                  taskOfProject.taskPriority,
                                                  taskOfProject.taskStatus,
                                                  'Completed');
                                        }
                                      } else if (index == 1) {
                                        if (mainTask) {
                                          return ProjectCollection()
                                              .changeMainTaskStatus(
                                                  projectController.projectID,
                                                  taskOfProject.taskID,
                                                  'In-progress');
                                        } else {
                                          ProjectCollection()
                                              .changeSubtaskStatus(
                                                  projectController.projectID,
                                                  _mainTaskID.text.trim(),
                                                  taskOfProject.taskID.trim(),
                                                  taskOfProject.taskName,
                                                  taskOfProject.taskDescription,
                                                  taskOfProject.startDate,
                                                  taskOfProject.dueDate,
                                                  taskOfProject.taskPriority,
                                                  taskOfProject.taskStatus,
                                                  'In-progress');
                                        }
                                      } else {
                                        if (mainTask) {
                                          return ProjectCollection()
                                              .changeMainTaskStatus(
                                                  projectController.projectID,
                                                  taskOfProject.taskID,
                                                  'Not-Started');
                                        } else {
                                          ProjectCollection()
                                              .changeSubtaskStatus(
                                                  projectController.projectID,
                                                  _mainTaskID.text.trim(),
                                                  taskOfProject.taskID.trim(),
                                                  taskOfProject.taskName,
                                                  taskOfProject.taskDescription,
                                                  taskOfProject.startDate,
                                                  taskOfProject.dueDate,
                                                  taskOfProject.taskPriority,
                                                  taskOfProject.taskStatus,
                                                  'Not-Started');
                                        }
                                      }
                                    },
                                    buttons: [
                                      "Completed",
                                      "In-progress",
                                      "Not-Started",
                                    ],
                                    selectedButtons: [
                                      "${taskOfProject.taskStatus}"
                                    ],
                                    selectedTextStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Get.textTheme.caption.color,
                                    ),
                                    unselectedTextStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                    selectedColor: Get.theme.canvasColor,
                                    unselectedColor: Colors.grey[300],
                                    selectedBorderColor: Get.theme.primaryColor,
                                    unselectedBorderColor: Colors.grey[500],
                                    borderRadius: BorderRadius.circular(2.0),
                                    selectedShadow: <BoxShadow>[
                                      BoxShadow(color: Colors.transparent)
                                    ],
                                    unselectedShadow: <BoxShadow>[
                                      BoxShadow(color: Colors.transparent)
                                    ],
                                  )
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
            isAdmin
                ? Dash(
                    direction: Axis.vertical,
                    dashGap: 5,
                    length: 50,
                    dashLength: 5,
                    dashColor: Get.theme.unselectedWidgetColor,
                  )
                : (last
                    ? SizedBox()
                    : (mainTask &&
                            (taskOfProject.subtask.isNullOrBlank ||
                                taskOfProject.subtask.isEmpty))
                        ? SizedBox()
                        : Dash(
                            direction: Axis.vertical,
                            dashGap: 5,
                            length: 50,
                            dashLength: 5,
                            dashColor: Get.theme.unselectedWidgetColor,
                          )),
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
              key: addSubTaskFormKey,
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
                            StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState
                                    /*You can rename this!*/) {
                              return RadioButtonGroup(
                                labels: <String>["Low", "Medium", "High"],
                                picked: _subtaskPriority.text,
                                onSelected: (String selected) {
                                  _subtaskPriority.text = selected;
                                  setState(() {});
                                  print(_subtaskPriority.text);
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
                  ),
                  ButtonTheme(
                    minWidth: 20,
                    height: 50.0,
                    child: RaisedButton(
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(30.0),
                              right: Radius.circular(30.0))),
                      onPressed: () async {
                        addSubTaskFormKey.currentState.save();
                        if (addSubTaskFormKey.currentState.validate()) {
                          _subtaskStatus.text = 'Not-Started';
                          Get.back();
                          ProjectCollection().createNewSubtask(
                              projectController.project.projectID,
                              taskOfProject.taskID,
                              _subtaskName.text,
                              _subtaskDescription.text,
                              _subtaskStartDate.text,
                              _subtaskDueDate.text,
                              _subtaskPriority.text,
                              _subtaskStatus.text);
                          Get.snackbar('Success',
                              "Subtask '${_subtaskName.text}' has been added successfully");
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

  void pickEditedMainTaskDate() async {
    DateTime _start = new DateTime.now();
    DateTime _due = new DateTime.now().add(Duration(days: 1));
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
        _editedSubtaskStartDate.text = picked[0].toString().substring(0, 10);
        _editedSubtaskDueDate.text = picked[0].toString().substring(0, 10);
        return;
      } else if (!picked[1].isNullOrBlank) {
        _editedSubtaskStartDate.text = picked[1].toString().substring(0, 10);
        _editedSubtaskDueDate.text = picked[1].toString().substring(0, 10);
        return;
      }
    }

    if (picked != null && picked.length == 2 && picked[0] != picked[1]) {
      _start = picked[0];
      _editedSubtaskStartDate.text = picked[0].toString().substring(0, 10);
      _due = picked[1];
      _editedSubtaskDueDate.text = picked[1].toString().substring(0, 10);
      return;
    }
  }

  void pickEditedSubtaskDate(String startDate, String dueDate) async {
    var due = DateFormat('yyyy-M-d').parse(dueDate);
    DateTime _startDateFromToday = new DateTime.now();
    var newStart = DateFormat('yyyy-M-d')
        .parse(_startDateFromToday.toString().substring(0, 10));

    final List<DateTime> picked = await DateRagePicker.showDatePicker(
      context: context,
      initialFirstDate: newStart,
      initialLastDate: due,
      firstDate: newStart,
      lastDate: due,
    );
    if (picked != null && picked.length == 1) {
      if (!picked[0].isNullOrBlank) {
        _editedSubtaskStartDate.text = picked[0].toString().substring(0, 10);
        _editedSubtaskDueDate.text = picked[0].toString().substring(0, 10);
        return;
      } else if (!picked[1].isNullOrBlank) {
        _editedSubtaskStartDate.text = picked[1].toString().substring(0, 10);
        _editedSubtaskDueDate.text = picked[1].toString().substring(0, 10);
        return;
      }
    }

    if (picked != null && picked.length == 2 && picked[0] != picked[1]) {
      newStart = picked[0];
      _editedSubtaskStartDate.text = picked[0].toString().substring(0, 10);
      due = picked[1];
      _editedSubtaskDueDate.text = picked[1].toString().substring(0, 10);
      return;
    }
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

  Widget editTask(TaskOfProject taskOfProject, bool mainTask) {
    print(taskOfProject.taskID);
    print(taskOfProject.taskName);
    print(taskOfProject.taskDescription);
    print(taskOfProject.startDate);
    print(taskOfProject.dueDate);
    print(taskOfProject.taskPriority);
    print(taskOfProject.assignedTo);

    _editedSubtaskName.text = taskOfProject.taskName;
    _editedSubtaskDescription.text = taskOfProject.taskDescription;
    _editedSubtaskStartDate.text = taskOfProject.startDate;
    _editedSubtaskDueDate.text = taskOfProject.dueDate;
    _editedSubtaskPriority.text = taskOfProject.taskPriority;
    _editedTaskAssignedTo.text = taskOfProject.assignedTo;
    return Scaffold(
      appBar: AppBar(
        title: mainTask ? Text('Edit Task') : Text('Edit Subtask'),
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
              setState(() {
                print(_editedSubtaskName.text);
                print(_editedSubtaskDescription.text);
                print(_editedSubtaskStartDate.text);
                print(_editedSubtaskDueDate.text);
                print(_editedSubtaskPriority.text);

                _editedSubtaskName.text = taskOfProject.taskName;
                _editedSubtaskDescription.text = taskOfProject.taskDescription;
                _editedSubtaskStartDate.text = taskOfProject.startDate;
                _editedSubtaskDueDate.text = taskOfProject.dueDate;
                _editedSubtaskPriority.text = taskOfProject.taskPriority;
              });
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
              key: editTaskFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _editedSubtaskName,
                    validator: (taskNameVal) => taskNameVal.isEmpty
                        ? "Task name cannot be empty"
                        : null,
                    onSaved: (taskNameVal) =>
                        _editedSubtaskName.text = taskNameVal,
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
                    controller: _editedSubtaskDescription,
                    validator: (taskNameVal) => taskNameVal.isEmpty
                        ? "Task description cannot be empty"
                        : null,
                    onSaved: (_taskDescriptionVal) =>
                        _editedSubtaskDescription.text = _taskDescriptionVal,
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
                    height: 30,
                  ),
                  mainTask
                      ? Text('')
                      : Text('Task dates limited to the main tasks date.'),
                  SizedBox(
                    height: mainTask ? 0 : 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _editedSubtaskStartDate,
                          validator: (startDateVal) => startDateVal.isEmpty
                              ? 'Start date cannot be empty'
                              : null,
                          onSaved: (startDateVal) => startDateVal.length >= 10
                              ? _editedSubtaskStartDate.text =
                                  startDateVal.substring(0, 10)
                              : _editedSubtaskStartDate.clear(),
                          readOnly: true,
                          decoration: InputDecoration(
                              labelText: 'Start date',
                              hintText:
                                  DateTime.now().toString().substring(0, 10),
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.horizontal(
                                      left: Radius.circular(20)))),
                          onTap: () async => mainTask
                              ? pickEditedMainTaskDate()
                              : pickEditedSubtaskDate(taskOfProject.startDate,
                                  _mainTaskDueDate.text),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _editedSubtaskDueDate,
                          validator: (dueDateVal) => dueDateVal.isEmpty
                              ? 'Due date cannot be empty'
                              : null,
                          onSaved: (dueDateVal) => dueDateVal.length >= 10
                              ? _editedSubtaskDueDate.text =
                                  dueDateVal.substring(0, 10)
                              : _editedSubtaskDueDate.clear(),
                          readOnly: true,
                          decoration: InputDecoration(
                              labelText: 'Due date',
                              hintText:
                                  DateTime.now().toString().substring(0, 10),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.horizontal(
                                      right: Radius.circular(20)))),
                          onTap: () async => mainTask
                              ? pickEditedMainTaskDate()
                              : pickEditedSubtaskDate(taskOfProject.startDate,
                                  _mainTaskDueDate.text),
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
                                (BuildContext context, StateSetter setState) {
                              return RadioButtonGroup(
                                labels: <String>["Low", "Medium", "High"],
                                picked: _editedSubtaskPriority.text,
                                onSelected: (String selected) {
                                  _editedSubtaskPriority.text = selected;
                                  if (this.mounted) {
                                    setState(() {});
                                  }
                                  print(_editedSubtaskPriority.text);
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
                  ),
                  mainTask
                      ? InkWell(
                          onTap: () {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          },
                          child: Container(
                            foregroundDecoration: BoxDecoration(
                                border: Border.all(
                                    color: Get.theme.unselectedWidgetColor),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: StreamBuilder<QuerySnapshot>(
                                stream: UserProfileCollection()
                                    .checkUserProjectsIDs(
                                        projectController.project.projectID),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasError) {
                                    return Text(snapshot.error.toString());
                                  }
                                  if (snapshot.connectionState ==
                                      ConnectionState.active) {
                                    if (snapshot.hasData &&
                                        snapshot.data != null) {
                                      snapshot.data.documents
                                          .forEach((element) {
                                        if (element.data['userID'] ==
                                            taskOfProject.assignedTo) {
                                          _editedTaskAssignedTo.text =
                                              element.data['userName'] +
                                                  "," +
                                                  element.data['userID'];
                                        }
                                      });
                                      if (snapshot.data.documents.length == 0)
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                              child: Text(
                                                  "No members in the project")),
                                        );
                                      return Column(
                                        children: [
                                          SearchChoices.single(
                                            items: snapshot.data.documents
                                                .toList()
                                                .map((i) {
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
                                                        Icons
                                                            .radio_button_checked,
                                                      )
                                                    : Icon(
                                                        Icons
                                                            .radio_button_unchecked,
                                                      ),
                                                SizedBox(width: 7),
                                                Expanded(
                                                  child: item,
                                                ),
                                              ]));
                                            },
                                            underline: SizedBox(),
                                            isCaseSensitiveSearch: false,
                                            displayClearIcon: true,
                                            value: _editedTaskAssignedTo.text,
                                            searchHint: "Assign a member",
                                            dialogBox: true,
                                            keyboardType: TextInputType.text,
                                            isExpanded: true,
                                            onChanged: (assignedToVal) {
                                              FocusScope.of(context)
                                                  .requestFocus(
                                                      new FocusNode());
                                              _editedTaskAssignedTo.text =
                                                  assignedToVal;
                                              setState(() {});
                                            },
                                            onClear: () {
                                              _editedTaskAssignedTo.clear();
                                            },
                                          ),
                                        ],
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
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 20,
                  ),
                  ButtonTheme(
                    minWidth: 20,
                    height: 50.0,
                    child: RaisedButton(
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(30.0),
                              right: Radius.circular(30.0))),
                      onPressed: () async {
                        editTaskFormKey.currentState.save();
                        if (editTaskFormKey.currentState.validate()) {
                          mainTask
                              ? await ProjectCollection().editTask(
                                  projectController.project.projectID,
                                  taskOfProject.taskID,
                                  _editedSubtaskName.text,
                                  _editedSubtaskDescription.text,
                                  _editedSubtaskStartDate.text,
                                  _editedSubtaskDueDate.text,
                                  _editedSubtaskPriority.text,
                                  _editedTaskAssignedTo.text)
                              : await ProjectCollection().editSubtask(
                                  projectController.project.projectID.trim(),
                                  _mainTaskID.text.trim(),
                                  taskOfProject.taskID.trim(),
                                  _editedSubtaskName.text.trim(),
                                  _editedSubtaskDescription.text.trim(),
                                  _editedSubtaskStartDate.text.trim(),
                                  _editedSubtaskDueDate.text.trim(),
                                  _editedSubtaskPriority.text.trim(),
                                  taskOfProject.taskName.trim(),
                                  taskOfProject.taskDescription.trim(),
                                  taskOfProject.startDate.trim(),
                                  taskOfProject.dueDate.trim(),
                                  taskOfProject.taskPriority.trim(),
                                  taskOfProject.taskStatus);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          mainTask
                              ? Text(('Update task'),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w300,
                                  ))
                              : Text(('Update subtask'),
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
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
