import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:swe496/Database/private_folder_collection.dart';
import 'package:swe496/Views/private_folder_views/widget/subtask_entries.dart';
import 'package:swe496/Views/private_folder_views/widget/subtask_item.dart';
import 'package:swe496/controllers/UserControllers/authController.dart';
import 'package:swe496/controllers/private_folder_controllers/category_controller.dart';
import 'package:swe496/controllers/private_folder_controllers/task_controller.dart';
import '../../controllers/private_folder_controllers/subtasks_list_controller.dart';
import 'package:swe496/models/private_folder_models/task_of_private_folder.dart';
import '../../models/private_folder_models/subtask.dart';
import './comments_view.dart';

class TaskDetailsView extends StatefulWidget {
  final String taskId;
  final categories =
      Get.put<CategoryController>(CategoryController()).categories;

  TaskDetailsView({@required this.taskId});

  @override
  _TaskDetailsViewState createState() => _TaskDetailsViewState();
}

class _TaskDetailsViewState extends State<TaskDetailsView> {
  final _taskTitleController = TextEditingController();

  TaskOfPrivateFolder task;
  String _selectedStateValue;
  String _selectedPriorityValue;
  String _selectedCategoryIdValue;
  String _taskModelId;
  List<Subtask> subtasks = [];

  DateTime _dateTime;
  final _states = <DropdownMenuItem>[
    DropdownMenuItem(
      child: Row(
        children: [
          Text(
            'In Progress',
            style: TextStyle(
              color: Colors.green,
            ),
          ),
          Icon(
            Icons.timelapse,
            color: Colors.green,
          )
        ],
      ),
      value: 'in-progress',
    ),
    DropdownMenuItem(
      child: Row(
        children: [
          Text(
            'Not Started',
            style: TextStyle(
              color: Colors.orange[900],
            ),
          ),
          Icon(
            Icons.browser_not_supported,
            color: Colors.orange[900],
          ),
        ],
      ),
      value: 'not-started',
    )
  ];

  final _priorities = <DropdownMenuItem>[
    DropdownMenuItem(
      child: Text(
        '!',
        style: TextStyle(
          color: Colors.blue,
        ),
      ),
      value: 'low',
    ),
    DropdownMenuItem(
      child: Text(
        '!!',
        style: TextStyle(
          color: Colors.yellow[800],
        ),
      ),
      value: 'medium',
    ),
    DropdownMenuItem(
      child: Text(
        '!!!',
        style: TextStyle(
          color: Colors.red[800],
        ),
      ),
      value: 'high',
    ),
  ];

  @override
  void initState() {
    super.initState();
    try {
      Get.put(TaskController(taskId: widget.taskId));
      var task = Get.find<TaskController>().task;
      _selectedCategoryIdValue = task.categoryId;
      _selectedStateValue = task.taskStatus;
      _selectedPriorityValue = task.taskPriority;
      _taskTitleController.text = task.taskName;
      _dateTime = task.dueDate;
      _taskModelId = task.taskID;
      print('print task.taskId in initState ${task.taskID}');
      print('print widget.taskId in initState ${widget.taskId}');
    } catch (e) {
      print('catched in initState of TaskDetailsView >> $e');
    }
  }

  @override
  void deactivate() async {
    // Delete the control object in this deactivate() function to remove it before disposing the state of this stateful widget
    // await Get.delete<TaskController>();
    super.deactivate();
  }

  @override
  void dispose() async {
    _taskTitleController.dispose();
    Get.delete<SubtasksListController>();
    subtasks = [];
    super.dispose();
  }

  GestureDetector addSubtask() {
    return GestureDetector(
      onTap: () {
        Get.bottomSheet(
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SubtaskEntries(_taskModelId),
          ),
          ignoreSafeArea: false,
          persistent: false,
          enableDrag: true,
        );
      },
      child: Row(
        children: [
          Expanded(child: Divider(thickness: 2)),
          Text(
            "     Click to add subtask +     ",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Divider(thickness: 2),
          ),
        ],
      ),
    );
  }

  void _tickSubask(String subtaskId, bool currentCompletionState) {
    PrivateFolderCollection().subtaskCompletionToggle(
      completionState: currentCompletionState ? false : true,
      userId: Get.find<AuthController>().user.uid,
      parentTaskId: widget.taskId,
      subtaskId: subtaskId,
    );
    setState(() {});
  }

  // Update the task title edited in the bottom sheet
  Future<void> _updateTaskTitle() async {
    final String givenTaskTitle = _taskTitleController.text;
    // We first check before adding the task edit, so no empty
    if (givenTaskTitle == null || givenTaskTitle.trim().isEmpty) {
      return;
    }

    try {
      await PrivateFolderCollection().changeTaskTitle(
        userId: Get.find<AuthController>().user.uid,
        taskId: _taskModelId,
        newTitle: givenTaskTitle,
      );
    } catch (e) {
      print(e);
    }
    Get.back();
  }

  Future<void> _updateTaskDueDate() async {
    if (_dateTime == null) {
      return;
    }
    try {
      await PrivateFolderCollection().changeTaskDueDate(
          userId: Get.find<AuthController>().user.uid,
          taskId: _taskModelId,
          newDueDate: _dateTime);
    } catch (e) {
      print(
          'catched in the function _updateTaskDueDate of TaskDetailsView state widget >> $e');
    }
  }

  Future<void> _updateTaskStatus(String value) async {
    try {
      print('the value in _updateTaskStatus is $value');
      await PrivateFolderCollection().changeStatus(
        userId: Get.find<AuthController>().user.uid,
        taskId: _taskModelId,
        newState: value,
      );
    } catch (e) {
      print(
          'catched in the function _updateTaskStatus of TaskDetailsView state widget >> $e');
    }
  }

  Future<void> _updateTaskPriority(String value) async {
    try {
      await PrivateFolderCollection().changePriority(
        userId: Get.find<AuthController>().user.uid,
        taskId: _taskModelId,
        newPriority: value,
      );
      print('printed in _updateTaskPriority $_selectedCategoryIdValue');
    } catch (e) {
      print(
          'catched in the function _updateTaskPriority of TaskDetailsView state widget >> $e');
    }
  }

  // This function shows the date picker UI
  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
      helpText: 'Select The Task Due Date',
      cancelText: 'Not Now',
      confirmText: 'Set',
      fieldLabelText: 'Due Date',
      fieldHintText: 'Month/Date/Year',
      errorFormatText: 'Enter valid date',
      errorInvalidText: 'Enter date in valid range',
    ).then((dateChosen) {
      // If no date chosen, then we close the date picker
      if (dateChosen == null) {
        return;
      }

      // mark the current widget as dirty and set the state if a date chosen
      setState(() {
        _dateTime = dateChosen;
        _updateTaskDueDate();
      });
    });
  }

  void _showCategoriesList(BuildContext ctx) {
    Get.defaultDialog(
      title: "Select Category",
      titleStyle: TextStyle(
        fontSize: 23,
        fontWeight: FontWeight.w900,
      ),
      content: Container(
        height: (MediaQuery.of(context).size.height * 0.6 -
            MediaQuery.of(context).viewInsets.bottom),
        width: MediaQuery.of(ctx).size.width * 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView(
                shrinkWrap: true,
                children: ListTile.divideTiles(
                  context: ctx,
                  color: Colors.black45,
                  tiles: widget.categories
                      .map(
                        (category) => ListTile(
                          title: FlatButton(
                            child: Text(
                              category.categoryName,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                              ),
                            ),
                            onPressed: () {
                              setState(
                                () {
                                  _selectedCategoryIdValue =
                                      category.categoryId;
                                },
                              );
                              PrivateFolderCollection().changeTaskCategory(
                                userId: Get.find<AuthController>().user.uid,
                                taskId: widget.taskId,
                                newCategoryId: _selectedCategoryIdValue,
                              );
                              Get.back();
                            },
                          ),
                        ),
                      )
                      .toList(),
                ).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final _stateColorIndicator = _selectedStateValue == 'in-progress'
        ? Colors.green
        : _selectedStateValue == 'not-started'
            ? Colors.orange[900]
            : _selectedStateValue == 'overdue'
                ? Colors.red
                : Colors.grey[350];

    final _priorityColorIndicator = _selectedPriorityValue == 'high'
        ? Colors.red[800]
        : _selectedPriorityValue == 'medium'
            ? Colors.yellow[800]
            : Colors.blue;

    final _priorityFontWeight =
        _selectedPriorityValue == 'high' ? FontWeight.w800 : FontWeight.w600;
    try {
      print('in the return of build method ${widget.taskId}');
      print(
          'in the return of build method ${widget.categories.first.categoryName}');
      try {
        print('task.taskId, in the return of build method $_taskModelId');
      } catch (e) {
        print(
            'catched in the return of the build method after calling _taskModelId');
      }

      return GetX<TaskController>(
        init: Get.put<TaskController>(TaskController(taskId: _taskModelId)),
        builder: (taskController) {
          if (taskController != null && taskController.task != null) {
            return SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                // TODO: Wrap the Column with gesture detector so when it is dragged up, then it return true to
                // a callback functoin in TaskItem widget so this function is called again in the bottomsheet
                // function, so its isScrollControlled: feature gets true value, and then setState there
                // so it rebuild this widget with isScrollControlled: true
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      child: Center(
                        child: Divider(
                          indent: 150,
                          endIndent: 150,
                          thickness: 4,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Form(
                      child: TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Edit task title',
                          border: InputBorder.none,
                        ),
                        controller: _taskTitleController,
                        onFieldSubmitted: (_) => _updateTaskTitle(),
                        onSaved: (newValue) => _updateTaskDueDate(),
                        onEditingComplete: () => _updateTaskTitle(),
                        cursorColor: Theme.of(context).primaryColor,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    // This is the container which encapsulates the row of date, state, and priority buttons
                    Container(
                      // The height here indicates the fit height of the components of the row
                      height: mediaQuery.size.height * 0.053,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: _showDatePicker,
                            child: Container(
                              padding: EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 7,
                                bottom: 10,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: _dateTime == null
                                        ? Colors.grey[500]
                                        : Theme.of(context).primaryColor,
                                    width: 2),
                              ),
                              child: _dateTime == null
                                  ? Container(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'No Date',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500),
                                          ),
                                          SizedBox(width: 10),
                                          Icon(
                                            Icons.calendar_today,
                                            color: Colors.grey[600],
                                          ),
                                        ],
                                      ),
                                    )
                                  : Text(
                                      "${DateFormat.MMMd().format(_dateTime)}",
                                      style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(
                            width: mediaQuery.size.width * 0.1,
                          ),
                          // The continaer encapsulating the categories of dialog list to choose from
                          Flexible(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FlatButton(
                                onPressed: () {
                                  _showCategoriesList(context);
                                },
                                child: FittedBox(
                                  alignment: Alignment.center,
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    widget.categories
                                        .firstWhere((category) =>
                                            category.categoryId ==
                                            _selectedCategoryIdValue)
                                        .categoryName,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: mediaQuery.size.height * 0.073,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // The box of editing the state of the task
                            Container(
                              padding: const EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: _stateColorIndicator, width: 2),
                              ),
                              child: DropdownButton(
                                isDense: false,
                                items: _states,
                                // The underline below dropdown list entry can be omitted giving it an empty value (null won't work)
                                underline: Text(''),
                                onChanged: (value) async {
                                  _selectedStateValue = value;
                                  await _updateTaskStatus(value);
                                  setState(() {});
                                },
                                value: _selectedStateValue,
                                style: TextStyle(
                                  color: _stateColorIndicator,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                                hint: Text(
                                  _selectedStateValue == 'in-progress'
                                      ? 'In Progress'
                                      : 'Not Started',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                            SizedBox(width: mediaQuery.size.width * 0.05),
                            // The box of editing the priority of the task
                            Container(
                              padding: const EdgeInsets.only(left: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: _priorityColorIndicator, width: 2),
                              ),
                              child: DropdownButton(
                                items: _priorities,
                                onChanged: (value) async {
                                  _selectedPriorityValue = value;
                                  await _updateTaskPriority(value);
                                  setState(() {});
                                },
                                underline: Text(''),
                                value: _selectedPriorityValue,
                                style: TextStyle(
                                  color: _priorityColorIndicator,
                                  fontWeight: _priorityFontWeight,
                                  fontSize: 17,
                                ),
                                hint: Text(
                                  _selectedPriorityValue == 'low'
                                      ? '!'
                                      : _selectedPriorityValue == 'medium'
                                          ? '!!'
                                          : '!!!',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            SizedBox(width: mediaQuery.size.width * 0.03),
                            // Comments screen button
                            IconButton(
                              icon: Icon(Icons.mode_comment_outlined),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                        secondaryAnimation) {
                                      return CommentsView(taskId: _taskModelId);
                                    },
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      return FadeTransition(
                                          opacity: animation, child: child);
                                    },
                                  ),
                                );
                                // ! Get.to didn't work
                                // Get.to(
                                //   CommentsView(taskId: _taskModelId),
                                //   transition: Transition.downToUp,
                                // );
                                setState(() {});
                              },
                            ),
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.more_vert),
                              onPressed: () {
                                // TODO: Show dropdown options of deleting the task, showing its activity log, and Editing it.
                                // ! think about showing another options of more UX
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: mediaQuery.size.height * 0.03),
                    addSubtask(),
                    SizedBox(
                      height: mediaQuery.size.height * 0.003,
                    ),
                    Flexible(
                      child: GetX<SubtasksListController>(
                        init: Get.put<SubtasksListController>(
                            SubtasksListController(_taskModelId)),
                        builder:
                            (SubtasksListController subtasksListController) {
                          print('checked 0');
// TODO: switch back the logic >> if(subtasksListController == null || ... || ... ) then return progress indicator
                          if (subtasksListController != null &&
                              subtasksListController.subtasks != null &&
                              subtasksListController.subtasks.isNotEmpty) {
                            print('checked 1');
                            subtasks = subtasksListController.subtasks;
                            print(
                                'in the if ${subtasksListController.subtasks.first.subtaskTitle}');
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: [
                                      ...subtasks.map(
                                        (subtask) {
                                          return Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.only(
                                              right: 11,
                                              left: 11,
                                              top: 15,
                                            ),
                                            child: SubtaskItem(
                                              subtask: subtask,
                                              tickSubtask: _tickSubask,
                                            ),
                                          );
                                        },
                                      ).toList(),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                          return Container();
                          // (subtasks.length > 0)
                          //     ? SpinKitRotatingCircle(
                          //         color: Theme.of(context).primaryColor,
                          //         duration: Duration(milliseconds: 900),
                          //       )
                          //     : Container();
                        },
                      ),
                    )
                  ],
                ),
              ),
            );
          }
          return Container();
        },
      );
    } catch (e) {
      setState(() {
        return;
      });
    }
    return CircularProgressIndicator(
        value: Duration(seconds: 5).inMilliseconds.toDouble());
  }
}
