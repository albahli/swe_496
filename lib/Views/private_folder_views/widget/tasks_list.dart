import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swe496/Database/private_folder_collection.dart';
import 'package:swe496/controllers/UserControllers/authController.dart';
import 'package:swe496/controllers/private_folder_controllers/task_controller.dart';
import 'package:swe496/controllers/private_folder_controllers/tasks_list_controller.dart';
import 'package:swe496/models/private_folder_models/category.dart';
import 'package:swe496/models/private_folder_models/task.dart';
import './task_item.dart';
import './task_entries.dart';

enum CategoryOptions {
  Rename,
  AddTask,
  Delete,
  ActivityLog,
  /* // TODO: add a pop view of actions. including the following actions:-
        1- delete category(ask the user if he/she also wants to delete its tasks or move it to another category). 
        2- rename category. 
        3- Add task to this category. 
        4- Activity Log of the category.
   */
}

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

  Widget _categoryOptions(String categoryId) {
    return PopupMenuButton(
      // TODO: add a barrier or add fog shading to the back screen, so it is easier for user to focus
      elevation: 9,
      itemBuilder: (ctx) {
        return [
          PopupMenuItem(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add task',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Icon(Icons.add),
              ],
            ),
            value: CategoryOptions.AddTask,
          ),
          PopupMenuItem(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Activity Log',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Icon(Icons.receipt_long),
              ],
            ),
            value: CategoryOptions.AddTask,
          ),
          PopupMenuItem(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(thickness: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rename Category',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Icon(
                      Icons.drive_file_rename_outline,
                      color: Colors.green,
                    )
                  ],
                ),
              ],
            ),
            value: CategoryOptions.Rename,
          ),
          PopupMenuItem(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delete Category',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Icon(
                  Icons.delete,
                  color: Theme.of(context).errorColor,
                ),
              ],
            ),
            value: CategoryOptions.Delete,
          ),
        ];
      },
      onSelected: (selectedOption) {
        if (selectedOption == CategoryOptions.AddTask) {
          Get.bottomSheet(
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: TaskEntries(
                selectedCategory: categoryId,
              ),
            ),
            ignoreSafeArea: false,
            persistent: false,
            enableDrag: true,
          );
        } else if (selectedOption == CategoryOptions.Delete) {
          return showDialog(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: Text('Delete category?'),
                content: Text(
                  'Do you really want to delete the Category ' +
                      '\'${widget.categoriesList.singleWhere((category) => category.categoryId == categoryId).categoryName}\'?',
                ),
                actions: [
                  FlatButton(
                    onPressed: () {
                      Get.back(result: false);
                    },
                    child: Text('No'),
                  ),
                  FlatButton(
                      onPressed: () async {
                        await PrivateFolderCollection().deleteCategory(
                          userId: Get.find<AuthController>().user.uid,
                          categoryId: categoryId,
                        );

                        Get.back(result: true);
                      },
                      child: Text('Yes')),
                ],
              );
            },
          );
        } else if (selectedOption == CategoryOptions.Rename) {
          // TODO: change the category title to be in TextField() rather than Text() widget
        } else if (selectedOption == CategoryOptions.ActivityLog) {
          // TODO: direct the user to the ActivityLog of the selected category
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.categoriesList.isEmpty
        ? Container()
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
                                  child: Container(
                                    child: _categoryOptions(
                                      widget.categoriesList[index].categoryId,
                                    ),
                                  )),
                            ],
                          ),
                          Divider(thickness: 2),
                          if (userTasks.isNotEmpty)
                            CategoryTasks(
                              userTasks: userTasks,
                              category: widget.categoriesList[index],
                              tickTask: _tickTask,
                              deleteTask: _deleteTask,
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

class CategoryTasks extends StatelessWidget {
  const CategoryTasks({
    Key key,
    @required this.userTasks,
    @required this.category,
    @required this.tickTask,
    @required this.deleteTask,
  }) : super(key: key);

  final List<TaskModel> userTasks;
  final Category category;
  final Function tickTask;
  final Function deleteTask;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: userTasks
          .where((task) => task.categoryId == category.categoryId)
          .map(
            (taskItem) => TaskItem(
              task: taskItem,
              tickTask: tickTask,
              deleteTask: deleteTask,
            ),
          )
          .toList(),
    );
  }
}
