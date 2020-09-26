import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:swe496/Database/UserProfileCollection.dart';
import 'package:swe496/Views/Project/TasksAndEventsView.dart';
import 'package:swe496/controllers/projectController.dart';
import 'package:swe496/controllers/userController.dart';
import 'package:swe496/models/Members.dart';
import 'package:swe496/utils/root.dart';

class MembersView extends StatefulWidget {
  final String projectID;

  MembersView({Key key, this.projectID}) : super(key: key);

  @override
  _MembersViewState createState() => _MembersViewState();
}

class _MembersViewState extends State<MembersView> {
  int barIndex = 2; // Current page index in bottom navigation bar
  ProjectController projectController = Get.find<ProjectController>();
  UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      // still not working in landscape mode
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 30,
          ),
          onPressed: () {
            Get.offAll(Root());
            projectController.clear();
            print("back to 'Root' from 'Members View'");
          },
        ),
        title: Text(projectController.project.projectName),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Open project settings page
            },
          )
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            _searchBar(),
            Expanded(child: _getListOfMembers()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.person_add),
          onPressed: () => alertAddNewMemberWindow()),
      bottomNavigationBar: bottomCustomNavigationBar(),
    );
  }

  // Search Bar
  Widget _searchBar() {
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

  // Bottom Navigation Bar
  Widget bottomCustomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_turned_in),
          title: Text('Tasks & Events'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          title: Text('Chat'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_work),
          title: Text('Members'),
        ),
      ],
      currentIndex: barIndex,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: (index) {
        setState(() {
          barIndex = index;

          if (barIndex == 0)
            Get.off(
                TasksAndEventsView(
                ),
                transition: Transition.noTransition);
          else if (barIndex == 1)
            return;
          else if (barIndex == 2) // Do nothing, stay in the same page
            return;
        });
        print(index);
      },
    );
  }

  Widget _getListOfMembers() {
    return StreamBuilder<QuerySnapshot>(
      stream: UserProfileCollection().checkUserProjectsIDs(projectController.project.projectID),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }

        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData && snapshot.data != null) {
            if (snapshot.data.documents.length == 0)
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: Text("No members in the project")),
              );
            List<Member> mappedMembersList =
                new List(); // List containing the username and the role
            List<String> userIDs = new List(); // List containing the user IDs
            for (int i = 0; i < snapshot.data.documents.length; i++) {
              for (int j = 0;
                  j < projectController.project.members.length;
                  j++) {
                if (snapshot.data.documents[i]['userID'] ==
                    projectController.project.members[j].memberUID) {
                  mappedMembersList.add(new Member(
                      memberUID: snapshot.data.documents[i]['userName'],
                      isAdmin: projectController.project.members[j].isAdmin));
                  userIDs.add(snapshot.data.documents[i]['userID']);
                }
              }
            }
            return ListView.builder(
                itemCount: mappedMembersList.length,
                itemBuilder: (context, index) {
                  //TODO: Modify the members list view to show the username and the role. check the below comment, if the current id of the user == member id then the he can't do anything such as (promote as admin, remove from project ...)
                  //userController.user.userID == userIDs[index]
                   return ListTile(
                    leading: Icon(Icons.account_circle),
                    title: Text(mappedMembersList[index].memberUID),
                    subtitle:
                        Text(mappedMembersList[index].isAdmin ? 'Admin' : ''),
                    onTap: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (BuildContext bc) {
                            return Container(
                              child: new Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: <Widget>[
                                  new ListTile(
                                    title: new Text(
                                        mappedMembersList[index].memberUID),
                                  ),
                                  Divider(),
                                  mappedMembersList[index].isAdmin
                                      ? new ListTile(
                                          title: new Text('Dismiss As Admin'),
                                          onTap: () => {},
                                        )
                                      : new ListTile(
                                          title: new Text('Promote As Admin'),
                                          onTap: () => {},
                                        ),
                                  new ListTile(
                                    title: new Text('Remove From Project', style: TextStyle(color: Colors.red),),
                                    onTap: () => {},
                                  ),
                                ],
                              ),
                            );
                          });
                    },
                  );
                });
          }
        }
        return Container(
          child: Center(
            child: CircularProgressIndicator(
              semanticsLabel: 'Loading',
              strokeWidth: 4,
            ),
          ),
        );
      },
    );
  }

  alertMembersOptions(String username, String userID, bool isAdmin) {
    Alert(
        context: context,
        title: username,
        closeFunction: () => null,
        style: AlertStyle(
            animationType: AnimationType.fromBottom,
            animationDuration: Duration(milliseconds: 300),
            descStyle: TextStyle(
              fontSize: 12,
            )),
        content: Theme(
          data: Get.theme,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                FlatButton(
                  onPressed: () async {},
                  child: Row(
                    children: [
                      Icon(Icons.people),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        userID,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
                Divider(),
                FlatButton(
                  onPressed: () async {},
                  child: Row(
                    children: [
                      Icon(Icons.alternate_email),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        isAdmin.toString(),
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
                Divider(),
                FlatButton(
                  onPressed: () async {},
                  child: Row(
                    children: [
                      Icon(Icons.link),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Copy project joining link",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )).show();
  }

  alertAddNewMemberWindow() {
    Alert(
        context: context,
        title: 'Add New Member',
        closeFunction: () => null,
        style: AlertStyle(
            animationType: AnimationType.fromBottom,
            animationDuration: Duration(milliseconds: 300),
            descStyle: TextStyle(
              fontSize: 12,
            )),
        content: Theme(
          data: Get.theme,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                FlatButton(
                  onPressed: () async {},
                  child: Row(
                    children: [
                      Icon(Icons.people),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Add from friends list",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
                Divider(),
                FlatButton(
                  onPressed: () async {},
                  child: Row(
                    children: [
                      Icon(Icons.alternate_email),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Add by username",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
                Divider(),
                FlatButton(
                  onPressed: () async {},
                  child: Row(
                    children: [
                      Icon(Icons.link),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Copy project joining link",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )).show();
  }
}
