import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:swe496/Views/private_folder_views/task_details_view.dart';
import 'package:swe496/controllers/private_folder_controllers/task_controller.dart';
import 'package:swe496/models/private_folder_models/task_of_private_folder.dart';
import '../../../controllers/private_folder_controllers/subtasks_list_controller.dart';

class TaskItem extends StatefulWidget {
  final TaskOfPrivateFolder task;
  final Function tickTask;
  final Function deleteTask;

  TaskItem({this.task, this.tickTask, this.deleteTask});

  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  void deactivate() {
    Get.delete<TaskController>();
    Get.delete<SubtasksListController>();
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    final _stateColorIndicator = widget.task.state == 'in-progress'
        ? Colors.green
        : widget.task.state == 'not-started'
            ? Colors.orange[700]
            : Colors.red;

    final _priorityColorIndicator = widget.task.priority == 'high'
        ? Colors.red[800]
        : widget.task.priority == 'medium'
            ? Colors.yellow[800]
            : Colors.blue;

    final _priorityFontWeight =
        widget.task.priority == 'high' ? FontWeight.w900 : FontWeight.w700;

    return GestureDetector(
      onTap: () async {
        Get.put<TaskController>(TaskController(taskId: widget.task.taskId));
        Get.find<TaskController>();
        // Show the setails of the task of id 'task.taskId' where the task is injected to this class
        // await Future.delayed(Duration(milliseconds: 200)); // ! consider uncommenting this if there is an error
        await Get.bottomSheet(
          TaskDetailsView(taskId: widget.task.taskId),
          enableDrag: true,
          ignoreSafeArea: false,
          persistent: true, // ! UI err? change persistent to false
          isScrollControlled: await Get.find<TaskController>().hasSubtasks,
        ).then((value) async {
          await Get.delete<TaskController>();
          print('the value is $value');
        });
        print('the task details closed ${widget.task.taskTitle}');
      },
      // * onDoubleTap has the same functionality as onTap: so no weird functionality occur
      onDoubleTap: () async {
        Get.put<TaskController>(TaskController(taskId: widget.task.taskId));
        Get.find<TaskController>();
        // Show the setails of the task of id 'task.taskId' where the task is injected to this class
        // await Future.delayed(Duration(milliseconds: 200)); // ! consider uncommenting this if there is an error
        await Get.bottomSheet(
          TaskDetailsView(taskId: widget.task.taskId),
          enableDrag: true,
          ignoreSafeArea: false,
          persistent: true, // ! UI err? change persistent to false
          isScrollControlled: await Get.find<TaskController>().hasSubtasks,
        ).then((value) async {
          await Get.delete<TaskController>();
          print('the value is $value');
        });
        print('the task details has been removed ${widget.task.taskTitle}');
      },
      child: Dismissible(
        key: UniqueKey(),
        background: Container(
          color: Theme.of(context).errorColor,
          child: Icon(
            Icons.delete,
            size: 40.0,
            color: Colors.white,
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
        ),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) {
          return showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('Delete task?'),
                content: Text(
                    'Do you really want to delete the task \'${widget.task.taskTitle}\'?'),
                actions: [
                  FlatButton(
                      onPressed: () {
                        Get.back(result: false);
                      },
                      child: Text('No')),
                  FlatButton(
                      onPressed: () {
                        Get.delete<TaskController>();
                        Get.back(result: true);
                      },
                      child: Text('Yes')),
                ],
              );
            },
          );
        },
        onDismissed: (_) async {
          Get.delete<TaskController>();
          await widget.deleteTask(widget.task.taskId);
        },
        child: Card(
          elevation: 0,
          margin: EdgeInsets.symmetric(vertical: 2, horizontal: 3),
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 18,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border:
                            Border.all(width: 4, color: _stateColorIndicator),
                      ),
                      child: Material(
                        shape: CircleBorder(),
                        clipBehavior: Clip.hardEdge,
                        child: InkWell(
                            onTap: () {
                              widget.tickTask(
                                  widget.task.taskId, widget.task.completed);
                            },
                            enableFeedback: true,
                            focusColor: _stateColorIndicator,
                            highlightColor: _stateColorIndicator,
                            hoverColor: _stateColorIndicator,
                            splashColor: _stateColorIndicator,
                            child: widget.task != null
                                ? widget.task.completed
                                    ? Icon(
                                        Icons.check_circle,
                                        size: 24.0,
                                        color: _stateColorIndicator,
                                      )
                                    : Icon(
                                        Icons.circle,
                                        size: 24.0,
                                        color: _stateColorIndicator
                                            .withOpacity(0.15),
                                      )
                                : CircularProgressIndicator()),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 61,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 7),
                      Text(
                        widget.task.taskTitle,
                        style: widget.task.completed
                            ? Theme.of(context).textTheme.headline6.copyWith(
                                  decoration: TextDecoration.lineThrough,
                                  decorationThickness: 1.7,
                                  color: Colors.grey[600],
                                )
                            : Theme.of(context).textTheme.headline6,
                      ),
                      SizedBox(height: 5),
                      widget.task.dueDate == null
                          ? Text("")
                          : Text(
                              "  ${DateFormat.yMMMd().format(widget.task.dueDate)}",
                              style: TextStyle(
                                color: widget.task.completed
                                    ? Colors.grey[500]
                                    : widget.task.state == 'overdue'
                                        ? Colors.red
                                        : Colors.grey[600],
                                decoration: widget.task.completed
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                fontSize: 16,
                              ),
                            ),
                      SizedBox(height: 7),
                    ],
                  ),
                ),
                Flexible(
                  flex: 14,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.42,
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      widget.task.priority == 'low'
                          ? '!'
                          : widget.task.priority == 'high'
                              ? '!!!'
                              : '!!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: _priorityFontWeight,
                        color: _priorityColorIndicator,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
