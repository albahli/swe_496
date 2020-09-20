import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swe496/Views/Project/TasksAndEventsView.dart';
import 'package:swe496/controllers/projectController.dart';
import 'package:swe496/controllers/userController.dart';
import 'package:swe496/utils/root.dart';


class MembersView extends StatefulWidget {

  final String projectID;
  MembersView({Key key, this.projectID}) : super(key: key);

  @override
  _MembersViewState createState() => _MembersViewState();
}

class _MembersViewState extends State<MembersView> {
  int barIndex = 0; // Current page index in bottom navigation bar
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
            color: Colors.white,
          ),
          onPressed: () {
            Get.offAll(Root());
            projectController.clear();
            print("back to 'Root' from 'Members View'");
          },
        ),
        title: Text(projectController.project.projectName),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            color: Colors.white,
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
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: (index) {
        setState(() {
          barIndex = index;

          if(barIndex == 0)
            Get.off(TasksAndEventsView(projectID: widget.projectID,), transition: Transition.noTransition);
          else if(barIndex == 1)
            return;
          else if(barIndex == 2) // Do nothing, stay in the same page
            return;

        });
        print(index);
      },
    );
  }

  Widget _getListOfMembers() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('userProfile')
          .where('userProjectsIDs', arrayContains: projectController.project.projectID)
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
                child: Center(child: Text("No members in the project")),
              );
            print('snap shots before sorting');
            snapshot.data.documents.forEach((DocumentSnapshot documentSnapshot) {
              print(documentSnapshot.data);
            });
            print('snap shots after sorting');
            snapshot.data.documents.forEach((DocumentSnapshot documentSnapshot) {
              print(documentSnapshot.data);
            });

            projectController.project.members.sort();
            // String userID = projectController.project.members.firstWhere((i) => i.memberUID == );
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  //TODO: Modify the members list view to show the username and the role.
                  // Stopped here
                 // Member member =  projectController.project.members.s;
                  return ListTile(
                    leading: Icon(Icons.account_circle),
                    title: Text(snapshot.data.documents[index]['userName']),
                    subtitle: Text(''),
                    onTap: () async{
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
}
/*
  */

