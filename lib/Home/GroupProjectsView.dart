import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:multilevel_drawer/multilevel_drawer.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:swe496/Project/TasksAndEvents.dart';
import 'package:swe496/SignIn.dart';
import 'package:swe496/provider_widget.dart';
import 'package:swe496/services/auth_service.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';
import 'package:uuid/uuid.dart';


class GroupProjects extends StatefulWidget {
  GroupProjects({Key key}) : super(key: key);

  @override
  _GroupProjects createState() => _GroupProjects();
}

class _GroupProjects extends State<GroupProjects> {
  final formKey = GlobalKey<FormState>();
  final uid = AuthService().getUserUID();
  int barIndex = 0; // fot bottom navigation tabs
  String projectName;

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
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 40,
                ),
                SizedBox(
                  height: 10,
                ),
                Text("username example")
              ],
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
                  try {
                    AuthService auth = Provider.of(context).auth;
                    await auth.signOut();
                    Get.off(SignIn());
                    print("Signed Out");
                  } catch (e) {
                    print(e.toString());
                  }
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
        floatingActionButton: floatingButtons());
  }

  // Search Bar
  _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(hintText: 'Search'),
        onChanged: (textVal) {
          textVal = textVal.toLowerCase();
          setState(() {});
        },
      ),
    );
  }

  Widget getListOfProjects() {
    return StreamBuilder(
      stream: Firestore.instance.collection('projects').snapshots(),
      builder: (context, snapshot) {
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

  // Bottom Navigation Bar

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
        setState(() {
          barIndex = index;
        });
        print(index);
      },
    );
  }

  // Buttons for creating or joining project
  Widget floatingButtons() {
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
          onTap: () => showTimelineInBottomSheet(),
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

  // Displays a bottom sheet contains a timeline of all the user's tasks in each group/personal project
  void showTimelineInBottomSheet() {
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

  // Used in showTimelineInBottomSheet()
  Widget viewTimeLineOfTasksAndEvents() {
    List<TimelineModel> items = [
      TimelineModel(Placeholder(),
          position: TimelineItemPosition.right,
          iconBackground: Colors.redAccent,
          icon: Icon(Icons.assignment)),
      TimelineModel(Placeholder(),
          position: TimelineItemPosition.left,
          iconBackground: Colors.redAccent,
          icon: Icon(Icons.event)),
      TimelineModel(Placeholder(),
          position: TimelineItemPosition.right,
          iconBackground: Colors.redAccent,
          icon: Icon(Icons.event)),
    ];

    return Timeline(children: items, position: TimelinePosition.Center);
  }

  // Form to create new project
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
                    setState(() {
                      projectName = projectNameVal;
                    });
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
                    setState(() {
                      // checkedValue = newValue;
                    });
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
                  final auth = Provider.of(context).auth;
                  String uid = await auth.getUserUID();
                  ProjectInDatabase(uid: uid).createNewProject(projectName);
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
}

class ProjectInDatabase {
  final String uid;

  ProjectInDatabase({this.uid});

  // Collection Reference
  // Checks if there is a collection named profile, if not it creates new one.
  final CollectionReference projectCollection =
      Firestore.instance.collection('projects');

  Future createNewProject(String projectName) async {
    String projectID =
        Uuid().v1(); // Project ID, UuiD is package that generates random ID

    await projectCollection.document(projectID).setData({
      'projectName': projectName,
      'Owner': uid,
      'ImageIcon': '',
      'IsJoiningEnabled': true,
      'joiningLink': projectID,
      'pinnedMessage':'',
    });
    await projectCollection.document(projectID).collection('chat').document().setData({}); // creating chat as sub collection
    await projectCollection.document(projectID).collection('events').document().setData({}); // creating events as sub collection
    await projectCollection.document(projectID).collection('members').document().setData({
      '$uid' : {
        'role' : 'admin'
      }
    }); // creating members as sub collection
   return await projectCollection.document(projectID).collection('tasks').document().setData({}); // creating tasks as sub collection
  }
}
