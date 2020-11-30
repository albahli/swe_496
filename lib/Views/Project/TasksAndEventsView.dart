import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:swe496/Views/Project/CreateEventView.dart';
import 'package:swe496/Views/Project/CreateTaskView.dart';
import 'package:swe496/Views/Project/EventView.dart';
import 'package:swe496/Views/Project/MembersView.dart';
import 'package:swe496/Views/Project/ProjectSettingsView.dart';
import 'package:swe496/Views/Project/TaskView.dart';
import 'package:swe496/controllers/ProjectControllers/EventController.dart';
import 'package:swe496/controllers/ProjectControllers/ListOfEventsController.dart';
import 'package:swe496/controllers/ProjectControllers/ListOfTasksOfProjectConrtoller.dart';
import 'package:swe496/controllers/ProjectControllers/TaskOfProjectController.dart';
import 'package:swe496/controllers/ProjectControllers/projectController.dart';
import 'package:swe496/controllers/UserControllers/userController.dart';
import 'package:swe496/models/Event.dart';
import 'package:swe496/models/TaskOfProject.dart';
import 'package:swe496/utils/root.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';
import 'package:intl/intl.dart';

class TasksAndEventsView extends StatefulWidget {
  TasksAndEventsView({Key key}) : super(key: key);

  @override
  _TasksAndEvents createState() => _TasksAndEvents();
}

class _TasksAndEvents extends State<TasksAndEventsView>
    with TickerProviderStateMixin {
  int barIndex = 0; // Current page index in bottom navigation bar
  ProjectController projectController = Get.find<ProjectController>();
  UserController userController = Get.find<UserController>();
  TabController
      tabController; // Top bar navigation between the tasks and events

  bool isAdmin = true;
  String taskKeywordSearch = '';
  List<TaskOfProject> filteredTasksListBySearch = new List<TaskOfProject>();

  String eventKeywordSearch = '';
  List<Event> filteredEventsListBySearch = new List<Event>();

  bool sortByTaskName = true;
  bool sortByTaskDueDate = false;
  bool sortByTaskPriority = false;
  bool sortByTaskStatus = false;
  bool ascendingSort = false;
  bool descendingSort = false;

  String dropDownSortButtonOption = 'Name';

  @override
  void initState() {
    super.initState();
    () async {
      await Future.delayed(Duration.zero);
      projectController = Get.find<ProjectController>();
    }();
    this.tabController = new TabController(length: 1, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    if (projectController.isNullOrBlank ||
        projectController.project.isNullOrBlank) {
      projectController = Get.find<ProjectController>();
    }
    if (projectController.isNullOrBlank ||
        projectController.project.isNullOrBlank) {
      Get.back();
      print('Handled Error.');
      return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
            ),
            onPressed: () {
              Get.offAll(Root());
              //    Get.delete<ProjectController>();
              tabController.dispose();
              print("back to 'Root' from 'TaskAndEventsView'");
            },
          ),
        ),
        body: Center(
          child: Text('Something went wrong !'),
        ),
      );
    }

    projectController.project.members.forEach((member) {
      if (member.memberUID == userController.user.userID && !member.isAdmin) {
        setState(() {
          isAdmin = false;
        });
      }
    });
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () {
            Get.offAll(Root());
            Get.delete<ProjectController>();
            tabController.dispose();
            print("back to 'Root' from 'TaskAndEventsView'");
          },
        ),
        title: Text(projectController.project.projectName),
        centerTitle: true,
        actions: <Widget>[
          isAdmin
              ? IconButton(
                  icon: Icon(Icons.settings),
                  tooltip: 'Project Settings',
                  onPressed: () {
                    Get.to(ProjectSettingsView());
                    FocusScope.of(context).unfocus();
                  },
                )
              : SizedBox()
        ],
      ),
      body: TabBarView(
        controller: tabController,
        children: <Widget>[
          DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: Container(
                  height: 50.0,
                  child: new TabBar(
                    indicatorColor: Get.theme.indicatorColor,
                    unselectedLabelColor: Get.theme.unselectedWidgetColor,
                    labelColor: Get.theme.indicatorColor,
                    tabs: [
                      Tab(
                        text: "Tasks",
                      ),
                      Tab(
                        text: "Events",
                      ),
                    ],
                  ),
                ),
              ),
              body: TabBarView(
                children: [
                  tasksTab(),
                  eventsTab(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomCustomNavigationBar(),
      floatingActionButton: isAdmin
          ? floatingButtons()
          : FloatingActionButton(
              child: Icon(Icons.timeline),
              onPressed: () => Get.bottomSheet(
                    Container(
                      child: Column(
                        children: [
                          AppBar(
                            title: Text('Timeline'),
                            centerTitle: true,
                            leading: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => Get.back(),
                            ),
                          ),
                          Expanded(child: viewTimeLineOfTasksAndEvents()),
                        ],
                      ),
                    ),
                    backgroundColor: Get.theme.canvasColor,
                    isScrollControlled: true,
                    ignoreSafeArea: false,
                  )),
    );
  }

  // Search Bar
  Widget tasksSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
              ),
              onChanged: (textVal) {
                setState(() {
                  taskKeywordSearch = textVal;
                });
              },
            ),
          ),
          SizedBox(
            width: 3,
          ),
          Column(
            children: [
              Row(
                children: [
                  IconButton(
                      tooltip: 'Ascending',
                      icon: Icon(Icons.arrow_upward, size: 20),
                      onPressed: () {
                        setState(() {
                          ascendingSort = true;
                          descendingSort = false;
                        });
                      }),
                  IconButton(
                      tooltip: 'Descending',
                      icon: Icon(
                        Icons.arrow_downward,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          descendingSort = true;
                          ascendingSort = false;
                        });
                      }),
                ],
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton(
                    isDense: true,
                    value: dropDownSortButtonOption,
                    icon: Icon(Icons.sort),
                    items: ['Name', 'Date', 'Priority', 'Status']
                        .map((sortOption) {
                      return new DropdownMenuItem<String>(
                        value: sortOption,
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Row(
                            children: [Text(sortOption)],
                          ),
                        ),
                        onTap: () {},
                      );
                    }).toList(),
                    onTap: () {},
                    onChanged: (selectedOption) {
                      setState(() {
                        dropDownSortButtonOption = selectedOption;
                        if (selectedOption == 'Name') {
                          sortByTaskName = true;
                          sortByTaskDueDate = false;
                          sortByTaskStatus = false;
                          sortByTaskPriority = false;
                        } else if (selectedOption == 'Date') {
                          sortByTaskName = false;
                          sortByTaskDueDate = true;
                          sortByTaskStatus = false;
                          sortByTaskPriority = false;
                        } else if (selectedOption == 'Priority') {
                          sortByTaskName = false;
                          sortByTaskDueDate = false;
                          sortByTaskStatus = false;
                          sortByTaskPriority = true;
                        } else if (selectedOption == 'Status') {
                          sortByTaskName = false;
                          sortByTaskDueDate = false;
                          sortByTaskStatus = true;
                          sortByTaskPriority = false;
                        }
                      });
                      FocusScope.of(context).unfocus();
                    }),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Search Bar
  Widget eventsSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search',
        ),
        onChanged: (textVal) {
          setState(() {
            eventKeywordSearch = textVal;
          });
        },
      ),
    );
  }

  // Bottom Navigation Bar
  Widget bottomCustomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(IconData(61545, fontFamily: 'MaterialIcons')),
          label: 'Tasks & Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_work),
          label: 'Members',
        ),
      ],
      currentIndex: barIndex,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: (index) {
        setState(() {
          barIndex = index;

          if (barIndex == 0) // Do nothing, stay in the same page
            return;
          else if (barIndex == 1)
            return;
          else if (barIndex == 2)
            Get.to(MembersView(), transition: Transition.noTransition);
          FocusScope.of(context).unfocus();
        });
        print(index);
      },
    );
  }

  Widget floatingButtons() {
    return SpeedDial(
      // both default to 16
      marginRight: 14,
      marginBottom: 16,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 25.0),
      // this is ignored if animatedIcon is non null
      // child: Icon(Icons.add),
      // If true user is forced to close dial manually
      // by tapping main button and overlay is not rendered.
      closeManually: false,
      curve: Curves.bounceIn,
      overlayOpacity: 0.5,
      onOpen: () => print('OPENING MENU'),
      onClose: () => print('MENU CLOSED'),
      tooltip: 'Menu',
      heroTag: '',
      elevation: 8.0,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
          child: Icon(
            Icons.timeline,
            size: 25,
          ),
          label: 'Upcoming',
          onTap: () => Get.bottomSheet(
            Container(
              child: Column(
                children: [
                  AppBar(
                    title: Text('Timeline'),
                    centerTitle: true,
                    leading: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  Expanded(child: viewTimeLineOfTasksAndEvents()),
                ],
              ),
            ),
            backgroundColor: Get.theme.canvasColor,
            isScrollControlled: true,
            ignoreSafeArea: false,
          ),
        ),
        SpeedDialChild(
          child: Icon(
            Icons.event,
            size: 25,
          ),
          label: 'New Event',
          onTap: () {
            Get.to(CreateEventView(),
                transition: Transition.downToUp,
                duration: Duration(milliseconds: 250));
            FocusScope.of(context).unfocus();
          },
        ),
        SpeedDialChild(
            child: Icon(
              Icons.assignment,
              size: 25,
            ),
            label: 'New Task',
            onTap: () {
              Get.to(CreateTaskView(),
                  transition: Transition.downToUp,
                  duration: Duration(milliseconds: 250));
              FocusScope.of(context).unfocus();
            }),
      ],
    );
  }

  Widget viewTimeLineOfTasksAndEvents() {
    // Load the List of events into memory
    ListOfEventsController eventController =
        Get.put<ListOfEventsController>(ListOfEventsController());

    // Load the List of tasks into memory
    ListOfTasksOfProjectController listOfTasksOfProjectController =
        Get.put<ListOfTasksOfProjectController>(
            ListOfTasksOfProjectController());

    // Merge the Tasks and events list
    var timeLineListOfTasksAndEvents = [
      ...eventController.events,
      ...listOfTasksOfProjectController.tasks
    ];

    // Sort the tasks and events based on due date
    timeLineListOfTasksAndEvents
      ..sort((a, b) {
        if (a is TaskOfProject && b is Event) {
          return a.dueDate.compareTo(b.eventEndDate);
        } else if (a is TaskOfProject && b is TaskOfProject) {
          return a.dueDate.compareTo(b.dueDate);
        } else if (a is Event && b is TaskOfProject) {
          return a.eventEndDate.compareTo(b.dueDate);
        } else if (a is Event && b is Event) {
          return a.eventEndDate.compareTo(b.eventEndDate);
        }
        return -1;
      });

    return Timeline(
        children: List<TimelineModel>.generate(
            (timeLineListOfTasksAndEvents.length), (index) {
          if (timeLineListOfTasksAndEvents[index] is Event) {
            return TimelineModel(
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () async {
                      Get.put<EventController>(EventController(
                          eventID:
                              (timeLineListOfTasksAndEvents[index] as Event)
                                  .eventID));
                      Get.to(EventView(), preventDuplicates: false);
                      FocusScope.of(context).unfocus();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minWidth: 1000, minHeight: 150),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${(timeLineListOfTasksAndEvents[index] as Event).eventName}',
                                style: Get.textTheme.headline6,
                              ),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${(timeLineListOfTasksAndEvents[index] as Event).eventDescription}',
                                style: Get.textTheme.bodyText1,
                              ),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'End date ${(timeLineListOfTasksAndEvents[index] as Event).eventEndDate}',
                                style: Get.textTheme.caption,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                iconBackground: Get.theme.primaryColor,
                position: index % 2 == 0
                    ? TimelineItemPosition.right
                    : TimelineItemPosition.left,
                icon: Icon(
                  Icons.event,
                  color: Get.theme.canvasColor,
                ));
          } else if (timeLineListOfTasksAndEvents[index] is TaskOfProject) {
            return TimelineModel(
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () async {
                      Get.put<TaskOfProjectController>(TaskOfProjectController(
                          taskID: (timeLineListOfTasksAndEvents[index]
                                  as TaskOfProject)
                              .taskID));
                      Get.to(TaskView(), preventDuplicates: false);
                      FocusScope.of(context).unfocus();
                    },
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: ConstrainedBox(
                            constraints:
                                BoxConstraints(minWidth: 1000, minHeight: 150),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${(timeLineListOfTasksAndEvents[index] as TaskOfProject).taskName}',
                                    style: Get.textTheme.headline6,
                                  ),
                                ),
                                Divider(
                                  thickness: 1,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Status: ${(timeLineListOfTasksAndEvents[index] as TaskOfProject).taskStatus}',
                                    style: Get.textTheme.bodyText2,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${(timeLineListOfTasksAndEvents[index] as TaskOfProject).taskPriority} Priority',
                                    style: Get.textTheme.bodyText1,
                                  ),
                                ),
                                Divider(
                                  thickness: 1,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Due date ${(timeLineListOfTasksAndEvents[index] as TaskOfProject).dueDate}',
                                    style: Get.textTheme.caption,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                position: index % 2 == 0
                    ? TimelineItemPosition.right
                    : TimelineItemPosition.left,
                iconBackground: Get.theme.primaryColor,
                icon: Icon(
                  Icons.assignment,
                  color: Get.theme.canvasColor,
                ));
          }

          return null;
        }),
        position: TimelinePosition.Center);
  }

  Widget tasksTab() {
    return Column(
      children: [
        tasksSearchBar(),
        Expanded(child: getListOfTasks()),
      ],
    );
  }

  Widget eventsTab() {
    return Column(
      children: [
        eventsSearchBar(),
        Expanded(child: getListOfEvents()),
      ],
    );
  }

  Widget getListOfTasks() {
    return GetX<ListOfTasksOfProjectController>(
        init: Get.put<ListOfTasksOfProjectController>(
            ListOfTasksOfProjectController()),
        builder:
            (ListOfTasksOfProjectController listOfTasksOfProjectController) {
          if (listOfTasksOfProjectController != null &&
              listOfTasksOfProjectController.tasks != null &&
              listOfTasksOfProjectController.tasks.isNotEmpty) {
            filteredTasksListBySearch = listOfTasksOfProjectController.tasks
                .where((task) => task.taskName
                    .toLowerCase()
                    .contains(taskKeywordSearch.toLowerCase()))
                .toList();

            if (sortByTaskName) {
              filteredTasksListBySearch.sort((a, b) =>
                  a.taskName.toLowerCase().compareTo(b.taskName.toLowerCase()));
            } else if (sortByTaskDueDate) {
              filteredTasksListBySearch
                  .sort((a, b) => b.dueDate.compareTo(a.dueDate));
            } else if (sortByTaskStatus) {
              filteredTasksListBySearch
                  .sort((a, b) => a.taskStatus.compareTo(b.taskStatus));
            } else if (sortByTaskPriority) {
              filteredTasksListBySearch
                  .sort((a, b) => a.taskPriority.compareTo(b.taskPriority));
            }

            if (ascendingSort) {
              filteredTasksListBySearch = filteredTasksListBySearch;
            } else if (descendingSort) {
              filteredTasksListBySearch =
                  filteredTasksListBySearch.reversed.toList();
            }

            return ListView.builder(
                itemCount: filteredTasksListBySearch.length,
                itemBuilder: (context, index) {
                  // Formatting the current date
                  var now = new DateTime.now().subtract(Duration(days: 1));
                  var formatter = new DateFormat('yyyy-MM-dd');
                  String formattedDate = formatter.format(now);
                  Jiffy taskDueDate = Jiffy(
                      filteredTasksListBySearch[index].dueDate, "yyyy-MM-dd");

                  var remainingDays =
                      taskDueDate.diff(formattedDate, Units.DAY);
                  return ListTile(
                    leading: filteredTasksListBySearch[index]
                                .taskStatus
                                .toUpperCase() ==
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
                            : (filteredTasksListBySearch[index]
                                        .taskStatus
                                        .toUpperCase() ==
                                    'NOT-STARTED'
                                ? Icon(
                                    Icons.assignment,
                                    color: Colors.grey,
                                  )
                                : (filteredTasksListBySearch[index]
                                            .taskStatus
                                            .toUpperCase() ==
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
                    title: Text(filteredTasksListBySearch[index].taskName),
                    subtitle:
                        Text('${filteredTasksListBySearch[index].dueDate}'),
                    trailing: Text(
                      '${filteredTasksListBySearch[index].taskPriority.toUpperCase()}',
                      style: TextStyle(
                          color: filteredTasksListBySearch[index]
                                      .taskPriority
                                      .toUpperCase() ==
                                  'LOW'
                              ? Colors.green
                              : (filteredTasksListBySearch[index]
                                          .taskPriority
                                          .toUpperCase() ==
                                      'HIGH'
                                  ? Colors.red
                                  : Colors.orange)),
                    ),
                    onTap: () async {
                      Get.put<TaskOfProjectController>(TaskOfProjectController(
                          taskID: filteredTasksListBySearch[index].taskID));
                      Get.to(TaskView());
                      FocusScope.of(context).unfocus();
                    },
                  );
                });
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text("There is no tasks.")),
          );
        });
  }

  Widget getListOfEvents() {
    return GetX<ListOfEventsController>(
        init: Get.put<ListOfEventsController>(ListOfEventsController()),
        builder: (ListOfEventsController listOfEventsController) {
          if (listOfEventsController != null &&
              listOfEventsController.events != null &&
              listOfEventsController.events.isNotEmpty &&
              !listOfEventsController.events.isNullOrBlank) {
            filteredEventsListBySearch = listOfEventsController.events
                .where((event) => event.eventName
                    .toLowerCase()
                    .contains(eventKeywordSearch.toLowerCase()))
                .toList();
            return ListView.builder(
                itemCount: filteredEventsListBySearch.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.event),
                    title: Text(filteredEventsListBySearch[index].eventName),
                    subtitle: Text(
                        filteredEventsListBySearch[index].eventStartDate +
                            ' to ' +
                            filteredEventsListBySearch[index].eventEndDate),
                    onTap: () async {
                      Get.put<EventController>(EventController(
                          eventID: filteredEventsListBySearch[index].eventID));
                      Get.to(EventView());
                      FocusScope.of(context).unfocus();
                    },
                  );
                });
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text("There is no events.")),
          );
        });
  }
}
