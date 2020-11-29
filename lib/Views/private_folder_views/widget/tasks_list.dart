import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swe496/Database/private_folder_collection.dart';
import 'package:swe496/controllers/private_folder_controllers/task_controller.dart';
import 'package:swe496/controllers/private_folder_controllers/tasks_list_controller.dart';
import 'package:swe496/models/private_folder_models/category.dart';
import 'package:swe496/models/private_folder_models/task.dart';
import '../../../controllers/authController.dart';
import './task_item.dart';

class TasksList extends StatefulWidget {
  final List<Category> categoriesList;

  TasksList({@required this.categoriesList});

  @override
  _TasksListState createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  List<TaskModel> userTasks = [];
  List<TaskModel> completedTasks = [];

  void _tickTask(String taskId, bool currentCompletionState) {
    PrivateFolderCollection().taskCompletionToggle(
      completionState: currentCompletionState ? false : true,
      userId: Get.find<AuthController>().user.uid,
      taskId: taskId,
    );
    setState(() {
      currentCompletionState
          ? completedTasks
              .removeWhere((TaskModel task) => task.taskId == taskId)
          : completedTasks.add(
              userTasks.firstWhere((TaskModel task) => task.taskId == taskId));
    });
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      userTasks.removeWhere((task) => task.taskId == taskId);
      Get.delete<TaskController>();
      await PrivateFolderCollection().deleteTask(
        userId: Get.find<AuthController>().user.uid,
        taskId: taskId,
      );
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  void _categoryOptions(String categoryId) {
    // TODO: Add the dropdown list of the options of the category
  }

  @override
  Widget build(BuildContext context) {
    return widget.categoriesList.isEmpty
        ? SizedBox()
        : GetX(
            init: Get.put<TasksListController>(TasksListController()),
            builder: (TasksListController tasksController) {
              if (tasksController != null &&
                  tasksController.tasks != null &&
                  tasksController.tasks.isNotEmpty) {
                userTasks = tasksController.tasks;
              }
              return ListView(
                children: List.generate(
                  widget.categoriesList.length,
                  (index) {
                    return Container(
                      width: double.infinity,
                      // height: MediaQuery.of(context).size.height -
                      //     Scaffold.of(context).appBarMaxHeight,
                      padding: EdgeInsets.only(right: 11, left: 11, top: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                flex: 10,
                                child: Text(
                                  widget.categoriesList[index].categoryName ??
                                      '',
                                  style: TextStyle(
                                    fontSize: 26.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: Colors.grey.shade700,
                                  ),
                                  onPressed: () {
                                    /* // TODO: add a pop view of actions. including the following actions:-
                            1- delete category(ask the user if he/she also wants to delete its tasks or move it to another category). 
                            2- rename category. 
                            3- Add task to this category. 
                            4- Activity Log of the category.
                          */
                                  },
                                ),
                              ),
                            ],
                          ),
                          Divider(thickness: 2),
                          if (userTasks.isNotEmpty)
                            Column(
                              children: userTasks
                                  .where((task) =>
                                      task.categoryId ==
                                      widget.categoriesList[index].categoryId)
                                  .map(
                                    (taskItem) => TaskItem(
                                      task: taskItem,
                                      tickTask: _tickTask,
                                      deleteTask: _deleteTask,
                                    ),
                                  )
                                  .toList(),
                            )
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
  }
}
