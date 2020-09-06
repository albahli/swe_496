import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:multilevel_drawer/multilevel_drawer.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:swe496/Project/TasksAndEvents.dart';
import 'package:swe496/controllers/authController.dart';
import 'package:swe496/controllers/userController.dart';
import 'package:swe496/models/Project.dart';
import 'package:swe496/models/User.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';
import 'package:uuid/uuid.dart';


class GroupProjects extends StatefulWidget {

  @override
  _GroupProjectsState createState() => _GroupProjectsState();
}

class _GroupProjectsState extends State<GroupProjects> {
  final formKey = GlobalKey<FormState>();

  User initStatedUser ;

  int barIndex = 0;
  String projectName;

 AuthController authController = Get.find<AuthController>();

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
                  CircleAvatar(
                    radius: 40,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GetX<UserController>(builder: (_){
                    return Text(_.user.userName.toString());
                  },)
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
      stream: Firestore.instance.collection('projects').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData && snapshot.data != null) {
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  String projectName =
                      snapshot.data.documents[index]['projectName'];
                  return ListTile(
                    leading: Icon(Icons.account_circle),
                    title: Text(projectName),
                    subtitle: Text('Details ...'),
                    onTap: () {
                      Get.to(TasksAndEvents(projectName: projectName));
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
      currentIndex: barIndex,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedFontSize: 15,
      onTap: (index) {

          barIndex = index;

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
          onTap: () => showTimelineInBottomSheet(context),
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

  void showTimelineInBottomSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Timeline'),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Get.back();
              },
            ),
          ),
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: viewTimeLineOfTasksAndEvents(),
          ),
        );
      },
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
                  onSaved: (projectNameVal) {
                      projectName = projectNameVal;
                  },
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
                  onChanged: (newValue) {
                  },
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
               //   final auth = Provider.of(context).auth;
                //  String uid = await auth.getUserUID();

                  createNewProject(projectName);
                  print('project has been created: $projectName');
                  Get.back();

                  // Display success message
                  Get.snackbar(
                    "Success !", // title
                    "Project '$projectName' has been created successfully.",
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

  Future createNewProject(String projectName) async {

    String projectID =
    Uuid().v1(); // Project ID, UuiD is package that generates random ID

    // Problem that the user is NULL
    print('now inside create method $initStatedUser');
    print(initStatedUser.userName);
    print(initStatedUser.userID);
    print(initStatedUser.password);
    // Add the creator of the project to the members list and assign him as admin
    var member = Members(
      memberUID: initStatedUser.userID,
      isAdmin: true,
    );
    List<Members> membersList = new List();
    membersList.add(member);

    // Create chat for the new project
    var chat = Chat(chatID: projectID);

    // Create the project object
    var newProject = Project(
      projectID: projectID,
      projectName: projectName,
      image: '',
      joiningLink: '$projectID',
      isJoiningLinkEnabled: true,
      pinnedMessage: '',
      chat: chat,
      members: membersList,
    );

    print('the length is : ${initStatedUser.listOfProjects.length}');

    // Add the new project ID to the user's project list
    initStatedUser.listOfProjects.add(newProject.projectID);

    // Convert the project object to be a JSON
    var jsonUser = initStatedUser.toJson();

    // Send the user JSON data to the fire base
    await Firestore.instance.collection('userProfile').document(initStatedUser.userID).setData(jsonUser);

    // Convert the project object to be a JSON
    var jsonProject = newProject.toJson();

    // Send the project JSON data to the fire base
    return await Firestore.instance.collection('projects').document(projectID).setData(jsonProject);
  }
}

class ProjectInDatabase {


  ProjectInDatabase();

  // Collection Reference
  // Checks if there is a collection named profile, if not it creates new one.
  final CollectionReference projectCollection =
      Firestore.instance.collection('projects');


}
