import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:swe496/Database/private_folder_collection.dart';
import 'package:swe496/controllers/private_folder_controllers/category_controller.dart';
import 'package:swe496/controllers/private_folder_controllers/tasks_list_controller.dart';
import 'package:swe496/models/private_folder_models/category.dart';
import '../../Database/UserProfileCollection.dart';
import '../../controllers/authController.dart';
import '../../controllers/userController.dart';
import '../../utils/root.dart';
import '../friendsView.dart';
import './widget/task_entries.dart';
import './widget/tasks_list.dart';
import '../the_drawer.dart';
import './activity_log_view.dart';

class PrivateFolderView extends StatefulWidget {
  @override
  _PrivateFolderViewState createState() => _PrivateFolderViewState();
}

class _PrivateFolderViewState extends State<PrivateFolderView> {
  List<Category> categories = [];
  TextEditingController _categoryController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String categoryFieldMessage = '';
  AuthController authController = Get.find<AuthController>();
  UserController userController = Get.find<UserController>();

  int barIndex = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    Get.delete<TasksListController>();
    Get.delete<CategoryController>();
    super.dispose();
  }

  void categoryFormDialog() {
    Get.defaultDialog(
      title: "Category Name",
      content: Container(
        // ! fixed height
        height: 150,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(height: 5.0),
              Container(
                padding: EdgeInsets.only(top: 0, left: 7, right: 6, bottom: 0),
                child: TextFormField(
                  validator: (value) {
                    return value.trim().isEmpty ? 'Please enter a value' : null;
                  },
                  controller: _categoryController,
                  decoration: InputDecoration(
                    hintText: 'e.g. Home tasks',
                    labelText: 'Category Name',
                  ),
                  autofocus: true,
                  maxLength: 12,
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  RaisedButton(
                    onPressed: () {
                      _categoryController.clear();
                      Get.back();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    color: Theme.of(context).errorColor,
                  ),
                  RaisedButton(
                    onPressed: () async {
                      if (_categoryController.text.trim().isEmpty) {
                        _formKey.currentState.validate();
                        return;
                      }
                      await PrivateFolderCollection().createCategory(
                        Get.find<AuthController>().user.uid,
                        _categoryController.text,
                      );
                      _categoryController.clear();
                      Get.back();
                    },
                    child: Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    color: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
      // onCancel: () {
      // ? Do we really need to persist the state of the last input of the user, so if he clicked mistakenly on the barrier?
      // ! _categoryController.clear();
      // },
    );
  }

  Widget bottomCustomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          title: Text('Groups'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_turned_in),
          title: Text('Tasks'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.contacts),
          title: Text('Friends'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          title: Text('Messages'),
        ),
      ],
      currentIndex: barIndex,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: (index) {
        setState(() {
          barIndex = index;

          if (barIndex == 0) // Do nothing, stay in the same page
            Get.to(Root());
          else if (barIndex == 1)
            return;
          else if (barIndex == 2)
            Get.off(FriendsView(), transition: Transition.noTransition);
        });

        print(index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // To initilize one object instead of exploding the heap with many objects of the same type (when many contexts change)
    final mediaQuery = MediaQuery.of(context);
    final appBar = AppBar(
      title: (DateTime.now().hour >= 0 && DateTime.now().hour < 12)
          ? Text("Good Morning")
          : (DateTime.now().hour >= 12 && DateTime.now().hour < 16)
              ? Text("Good Afternoon")
              : Text("Good Evening"),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.receipt_outlined),
          onPressed: () {
            // Route to the activity log page
            Get.to(ActivityLogView());
          },
        ),
        // IconButton(
        //   icon: Icon(Icons.edit),
        //   onPressed: () {
        //     if (Get.isDarkMode) {
        //       Get.changeTheme(ThemeData.light());
        //     } else {
        //       Get.changeTheme(ThemeData.dark());
        //     }
        //   },
        // ),
        IconButton(
          icon: Icon(
            Icons.playlist_add_outlined,
            size: 29,
          ),
          onPressed: () {
            categoryFormDialog();
          },
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      // ? might we need SingleChildScrollView surrnounding this above Column?
      body: Column(
        children: <Widget>[
          GetX<CategoryController>(
            init: Get.put<CategoryController>(CategoryController()),
            builder: (CategoryController categoryController) {
              if (categoryController != null &&
                  categoryController.categories != null &&
                  categoryController.categories.isNotEmpty) {
                categories = categoryController.categories;
              }
              Get.put<TasksListController>(TasksListController());
              Get.find<TasksListController>();
              return Expanded(
                // Without Expanded widget surronding ListView, Flutter would complain (ListView inside TasksList)
                child: Container(
                  height: (mediaQuery.size.height -
                      appBar.preferredSize.height -
                      mediaQuery.padding.top),
                  child: TasksList(
                    categoriesList: categories,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: TheDrawer(authController: authController),
      bottomNavigationBar: bottomCustomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: 'Add a Task',
        onPressed: () {
          // We create the task here by openning the bottomsheet
          Get.bottomSheet(
            Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: TaskEntries(selectedCategory: categories[0].categoryId)),
            ignoreSafeArea: false,
            persistent: false,
            enableDrag: true,
          );
        },
      ),
    );
  }
}

enum OptionsButton {
  Category,
  SelectTasks,
}
