import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:swe496/Database/private_folder_collection.dart';
import 'package:swe496/Views/private_folder_views/task_details_view.dart';
import 'package:swe496/controllers/private_folder_controllers/task_controller.dart';
import 'package:swe496/models/private_folder_models/subtask.dart';
import 'package:swe496/models/private_folder_models/task.dart';

import '../../../controllers/authController.dart';

class SubtaskItem extends StatefulWidget {
  final Subtask subtask;
  final Function tickSubtask;

  SubtaskItem({this.subtask, this.tickSubtask});

  @override
  _SubtaskItemState createState() => _SubtaskItemState();
}

class _SubtaskItemState extends State<SubtaskItem> {
  //

  Future<void> _deleteSubtask() async {
    try {
      print('entered the subtask deletion caller area');
      await PrivateFolderCollection().deleteSubtask(
        userId: Get.find<AuthController>().user.uid,
        parentTaskId: widget.subtask.parentTaskId,
        subtaskId: widget.subtask.subtaskId,
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final _stateColorIndicator = widget.subtask.subtaskState == 'in-progress'
        ? Colors.green
        : widget.subtask.subtaskState == 'not-started'
            ? Colors.orange[700]
            : Colors.red;

    final _priorityColorIndicator = widget.subtask.subtaskPriority == 'high'
        ? Colors.red[800]
        : widget.subtask.subtaskPriority == 'medium'
            ? Colors.yellow[800]
            : Colors.blue;

    final _priorityFontWeight = widget.subtask.subtaskPriority == 'high'
        ? FontWeight.w900
        : FontWeight.w700;

    return Dismissible(
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
              title: Text('Delete Subtask?'),
              content: Text(
                  'Do you really want to delete the subtask \'${widget.subtask.subtaskTitle}\'?'),
              actions: [
                FlatButton(
                    onPressed: () {
                      // Navigator.of(context).pop(false);
                      Get.back(result: false);
                    },
                    child: Text('No')),
                FlatButton(
                    onPressed: () {
                      // Navigator.of(context).pop(true);
                      Get.back(result: true);
                    },
                    child: Text('Yes')),
              ],
            );
          },
        );
      },
      onDismissed: (_) async {
        await _deleteSubtask();
      },
      child: Card(
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
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
                      border: Border.all(width: 4, color: _stateColorIndicator),
                    ),
                    child: Material(
                      shape: CircleBorder(),
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: () {
                          widget.tickSubtask(
                            widget.subtask.subtaskId,
                            widget.subtask.completed,
                          );
                        },
                        enableFeedback: true,
                        focusColor: _stateColorIndicator,
                        highlightColor: _stateColorIndicator,
                        hoverColor: _stateColorIndicator,
                        splashColor: _stateColorIndicator,
                        child: widget.subtask != null
                            ? widget.subtask.completed
                                ? Icon(
                                    Icons.check_circle,
                                    size: 24.0,
                                    color: _stateColorIndicator,
                                  )
                                : Icon(
                                    Icons.circle,
                                    size: 24.0,
                                    color:
                                        _stateColorIndicator.withOpacity(0.15),
                                  )
                            : CircularProgressIndicator(),
                      ),
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
                      widget.subtask.subtaskTitle,
                      style: widget.subtask.completed
                          ? Theme.of(context).textTheme.headline6.copyWith(
                                decoration: TextDecoration.lineThrough,
                                decorationThickness: 1.7,
                                color: Colors.grey[600],
                              )
                          : Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: 5),
                    widget.subtask.dueDate == null
                        ? Text("")
                        : Text(
                            "  ${DateFormat.yMMMd().format(widget.subtask.dueDate)}",
                            style: TextStyle(
                              color: widget.subtask.completed
                                  ? Colors.grey[500]
                                  : widget.subtask.subtaskState == 'overdue'
                                      ? Colors.red
                                      : Colors.grey[600],
                              decoration: widget.subtask.completed
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
                    widget.subtask.subtaskPriority == 'low'
                        ? '!'
                        : widget.subtask.subtaskPriority == 'high'
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
    );
  }
}
