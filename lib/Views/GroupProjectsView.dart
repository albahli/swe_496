import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:multilevel_drawer/multilevel_drawer.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:swe496/Database/ProjectCollection.dart';
import 'package:swe496/Views/friendsView.dart';
import 'package:swe496/Views/Project/TasksAndEventsView.dart';
import 'package:swe496/controllers/authController.dart';
import 'package:swe496/controllers/projectController.dart';
import 'package:swe496/controllers/userController.dart';
import 'package:swe496/models/Project.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';

class GroupProjectsView extends StatefulWidget {
  @override
  _GroupProjectsViewState createState() => _GroupProjectsViewState();
}

class _GroupProjectsViewState extends State<GroupProjectsView> {
  AuthController authController = Get.find<AuthController>();
  UserController userController = Get.find<UserController>();
  final formKey = GlobalKey<FormState>();
  final TextEditingController _newProjectNameController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        // still not working in landscape mode
        appBar: AppBar(
          title: const Text('Group Projects'),
          centerTitle: true,
          backgroundColor: Colors.red,
          actions: <Widget>[],
        ),
        drawer: MultiLevelDrawer(
          backgroundColor: Colors.white,
          rippleColor: Colors.grey.shade100,
          subMenuBackgroundColor: Colors.grey.shade100,
          divisionColor: Colors.black12,
          header: Container(
            // Header for Drawer
            height: MediaQuery.of(context).size.height * 0.25,
            child: Center(
                child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.account_circle, size: 90, color: Colors.grey,),
                  SizedBox(
                    height: 10,
                  ),
                  userController.user.userName == null
                      ? Text('NULL ??')
                      : Text('${userController.user.userName}'),
                ],
              ),
            )),
          ),
          children: [
            // Child Elements for Each Drawer Item
            MLMenuItem(
                leading: Icon(
                  Icons.person,
                  color: Colors.red,
                ),
                content: Text(
                  "My Profile",
                ),
                onClick: () {}),
            MLMenuItem(
              leading: Icon(Icons.settings, color: Colors.red),
              content: Text("Settings"),
              onClick: () {},
            ),
            MLMenuItem(
                leading: Icon(Icons.power_settings_new, color: Colors.red),
                content: Text(
                  "Log out",
                ),
                onClick: () async {
                  authController.signOut();
                  print("Signed Out");
                }),
          ],
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              _searchBar(),
              Expanded(child: getListOfProjects()),
            ],
          ),
        ),
        bottomNavigationBar: bottomCustomNavigationBar(),
        floatingActionButton: floatingButtons(context));
  }

  _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(hintText: 'Search'),
        onChanged: (textVal) {
          textVal = textVal.toLowerCase();
        },
      ),
    );
  }

  Widget getListOfProjects() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('projects')
          .where('membersIDs', arrayContains: userController.user.userID)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData && snapshot.data != null) {
            if (snapshot.data.documents.length == 0)
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: Text("You don't have any projects")),
              );

            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.supervised_user_circle),
                    title: Text(snapshot.data.documents[index]['projectName']),
                    subtitle: Text('Details ...'),
                    onTap: () async {
                      Get.put<ProjectController>(ProjectController());
                      ProjectController projectController =
                          Get.find<ProjectController>();
                      projectController.project = Project.fromJson(
                          new Map<String, dynamic>.from(
                              snapshot.data.documents[index].data));
                      Get.to(
                          TasksAndEventsView(
                              projectID: projectController.project.projectID),
                          transition: Transition.rightToLeft,
                          duration: Duration(milliseconds: 300));
                    },
                  );
                });
          }
        }
        return Container(
          child: Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.grey,
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
              semanticsLabel: 'Loading',
              strokeWidth: 4,
            ),
          ),
        );
      },
    );
  }

  Widget bottomCustomNavigationBar() {
    return BottomNavigationBar(
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
        /* BottomNavigationBarItem(
          icon: Icon(Icons.person_pin),
          title: Text('Account'),
        ),*/
      ],
      currentIndex: 0,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedFontSize: 15,
      onTap: (index) {
        if (index == 0) return; // Do nothing because we are in the same page

        // if(index == 1 )
        //  return Get.off(page);

        if (index == 2) Get.off(FriendsView());

        if (index == 3) return;

        print(index);
      },
    );
  }

  Widget floatingButtons(BuildContext context) {
    return SpeedDial(
      // both default to 16
      marginRight: 18,
      marginBottom: 20,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 25.0),
      // this is ignored if animatedIcon is non null
      // child: Icon(Icons.add),
      // If true user is forced to close dial manually
      // by tapping main button and overlay is not rendered.
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.3,
      onOpen: () => print('OPENING MENU'),
      onClose: () => print('MENU CLOSED'),
      tooltip: 'Menu',
      heroTag: '',
      backgroundColor: Colors.white,
      foregroundColor: Colors.red,
      elevation: 8.0,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
          child: Icon(
            Icons.calendar_today,
            size: 25,
          ),
          backgroundColor: Colors.red,
          label: 'Upcoming',
          labelStyle: TextStyle(fontSize: 16.0),
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
            isScrollControlled: true,
            ignoreSafeArea: false,
            backgroundColor: Colors.white,
          ),
        ),
        SpeedDialChild(
          child: Icon(
            Icons.add,
            size: 25,
          ),
          backgroundColor: Colors.red,
          label: 'New Project',
          labelStyle: TextStyle(fontSize: 16.0),
          onTap: () => alertCreateProjectForm(context),
        ),
        SpeedDialChild(
          child: Icon(
            Icons.group_add,
            size: 25,
          ),
          backgroundColor: Colors.red,
          label: 'Join Project',
          labelStyle: TextStyle(fontSize: 16.0),
          onTap: () => print('SECOND CHILD'),
        ),
      ],
    );
  }

  Widget viewTimeLineOfTasksAndEvents() {
    List<TimelineModel> items = [
      TimelineModel(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey[250],
                  boxShadow: [
                    BoxShadow(color: Colors.black12, spreadRadius: 0.5),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: 300, minWidth: 200, minHeight: 200),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Task name: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Description: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Status: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Priority: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Start date: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'End date: ',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          position: TimelineItemPosition.right,
          iconBackground: Colors.red,
          isFirst: true,
          icon: Icon(
            Icons.assignment,
            color: Colors.white,
          )),
      TimelineModel(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey[250],
                  boxShadow: [
                    BoxShadow(color: Colors.black12, spreadRadius: 0.5),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: 300, minWidth: 200, minHeight: 200),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Event name: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Description: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Location: (optional) ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Date: ',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          position: TimelineItemPosition.left,
          iconBackground: Colors.red,
          isFirst: true,
          icon: Icon(
            Icons.event,
            color: Colors.white,
          )),
      TimelineModel(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey[250],
                  boxShadow: [
                    BoxShadow(color: Colors.black12, spreadRadius: 0.5),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: 300, minWidth: 200, minHeight: 200),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Task name: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Description: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Status: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Priority: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'Start date: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        Text(
                          'End date: ',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          position: TimelineItemPosition.right,
          iconBackground: Colors.red,
          isFirst: true,
          icon: Icon(
            Icons.assignment,
            color: Colors.white,
          )),
    ];

    return Timeline(children: items, position: TimelinePosition.Center);
  }

  void alertCreateProjectForm(BuildContext context) {
    Alert(
        context: context,
        title: 'Create New Project',
        closeFunction: () => null,
        style: AlertStyle(
            animationType: AnimationType.fromBottom,
            animationDuration: Duration(milliseconds: 300),
            descStyle: TextStyle(
              fontSize: 12,
            )),
        content: Theme(
          data: ThemeData(
            primaryColor: Colors.red,
          ),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  validator: (value) =>
                      value.isEmpty ? "Project name can't be empty" : null,
                  controller: _newProjectNameController,
                  onSaved: (projectNameVal) =>
                      _newProjectNameController.text = projectNameVal,
                  decoration: InputDecoration(
                    icon: Icon(Icons.edit),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    hintText: 'Graduation Project',
                    labelText: 'Project Name',
                  ),
                ),
                CheckboxListTile(
                  title: Text("title text"),
                  value: false,
                  onChanged: (newValue) {},
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                )
              ],
            ),
          ),
        ),
        buttons: [
          DialogButton(
            color: Colors.red,
            radius: BorderRadius.circular(30),
            onPressed: () async {
              formKey.currentState.save();
              if (formKey.currentState.validate()) {
                try {
                  ProjectCollection().createNewProject(
                      _newProjectNameController.text, userController.user);
                  Get.back();
                  // Display success message
                  Get.snackbar(
                    "Success !", // title
                    "Project '${_newProjectNameController.text}' has been created successfully.",
                    // message
                    icon: Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                    shouldIconPulse: true,
                    borderColor: Colors.green,
                    borderWidth: 1,
                    barBlur: 20,
                    isDismissible: true,
                    duration: Duration(seconds: 5),
                  );
                  _newProjectNameController.clear();
                } catch (e) {
                  print(e.message);
                }
              }
            },
            child: Text(
              "Submit",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w300),
            ),
          )
        ]).show();
  }
}
