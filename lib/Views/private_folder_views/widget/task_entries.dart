import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:swe496/Database/private_folder_collection.dart';
import 'package:swe496/controllers/private_folder_controllers/category_controller.dart';

import '../../../controllers/authController.dart';

class TaskEntries extends StatefulWidget {
  final categories =
      Get.put<CategoryController>(CategoryController()).categories;
  final String selectedCategory;

  TaskEntries({this.selectedCategory});

  @override
  _TaskEntriesState createState() => _TaskEntriesState();
}

class _TaskEntriesState extends State<TaskEntries> {
  final _taskTitleController = TextEditingController();
  final _tasktTitleFocusNode = FocusNode();
  // state is by default not-started, and user can switch it while creating to in-progress, other states are to time and completion factors
  String _selectedStateValue = 'not-started';
  // priority is by default 'low', and user can switch it to medium and high
  String _selectedPriorityValue = 'low';
  String _selectedCategoryIdValue;

  // TODO: comment adding feature

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

    _selectedCategoryIdValue = widget.selectedCategory;

    // setting a listner for the task title entry focus node so once it hasn't the focus, it brings it back to it
    _tasktTitleFocusNode.addListener(() {
      if (!_tasktTitleFocusNode.hasFocus) {
        // if the task title loses the focus node, it immediately requested it back
        FocusScope.of(context).requestFocus(_tasktTitleFocusNode);
      }
    });
  }

  @override
  void dispose() {
    _taskTitleController.dispose();
    _tasktTitleFocusNode.dispose();
    super.dispose();
  }

  // Adds the task entered in the bottom sheet to the database
  void _addTaskFromEntries() {
    final String givenTaskTitle = _taskTitleController.text;
    // Check before adding the task
    if (givenTaskTitle == null || givenTaskTitle.trim().isEmpty) {
      return;
    }

    if (_dateTime == null) {
      // If there isn't a date, it won't be set, thus undated (the user can either decide the date later)
      // ! _dateTime = DateTime.now();
    }

    // Adding the task to the database
    PrivateFolderCollection().createTask(
      userId: Get.find<AuthController>().user.uid,
      categoryId: _selectedCategoryIdValue,
      newTaskTitle: _taskTitleController.text,
      dueDate: _dateTime,
      state: _selectedStateValue,
      priority: _selectedPriorityValue,
    );
    Get.back();
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
      print(dateChosen);
      //  Then mark the widget as dirty and set the state if a date chosen
      setState(() {
        _dateTime = dateChosen;
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
                                        Get.back();
                                      },
                                    );
                                  },
                                ),
                              ),
                            )
                            .toList())
                    .toList(),
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

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter task title',
              hintStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
              border: InputBorder.none,
            ),
            controller: _taskTitleController,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            onSubmitted: (_) => _addTaskFromEntries(),
            cursorColor: Theme.of(context).primaryColor,
            focusNode: _tasktTitleFocusNode,
            autofocus: true,
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
                                  style: TextStyle(fontWeight: FontWeight.w500),
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
                  width: mediaQuery.size.width * 0.05,
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
                      child: Row(
                        children: [
                          Text(
                            "Category:",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            width: mediaQuery.size.width * 0.02,
                          ),
                          FittedBox(
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
                              maxLines: 10,
                            ),
                          ),
                        ],
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // The box of choosing the state of the task
                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _stateColorIndicator, width: 2),
                    ),
                    child: DropdownButton(
                      isDense: false,
                      items: _states,
                      // The underline below dropdown list entry can be omitted giving it an empty value (null won't work)
                      underline: Text(''),
                      onChanged: (value) {
                        setState(
                          () {
                            _selectedStateValue = value;
                          },
                        );
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
                  // The box of choosing the priority of the task
                  // TODO: fix the problem of the dropdown menu item 'High' being hidden by keyboard when it is already set as 'Low'
                  Container(
                    padding: const EdgeInsets.only(left: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: _priorityColorIndicator, width: 2),
                    ),
                    child: DropdownButton(
                      items: _priorities,
                      onChanged: (value) {
                        setState(() {
                          _selectedPriorityValue = value;
                        });
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
                  RaisedButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Add'),
                        Icon(Icons.arrow_right),
                      ],
                    ),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).textTheme.button.color,
                    onPressed: _addTaskFromEntries,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
