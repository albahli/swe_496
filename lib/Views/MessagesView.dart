import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multilevel_drawer/multilevel_drawer.dart';
import 'package:swe496/Views/GroupProjectsView.dart';
import 'package:swe496/Views/Messages.dart';
import 'package:swe496/Views/friendsView.dart';
import 'package:swe496/controllers/UserControllers/userController.dart';
import 'package:swe496/controllers/UserControllers/authController.dart';
import 'package:swe496/utils/root.dart';

class MessagesView extends StatefulWidget {
  @override
  _MessagesViewState createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  AuthController authController = Get.find<AuthController>();
  UserController userController = Get.find<UserController>();
  final formKey = GlobalKey<FormState>();
  final TextEditingController _newProjectNameController =
      TextEditingController();
  int barIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      // still not working in landscape mode
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: true,
        actions: <Widget>[],
      ),
      drawer: MultiLevelDrawer(
        header: Container(
          // Header for Drawer
          height: MediaQuery.of(context).size.height * 0.25,
          child: Center(
              child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.account_circle,
                  size: 90,
                ),
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
              ),
              content: Text("My Profile"),
              onClick: () {}),
          MLMenuItem(
            leading: Icon(
              Icons.settings,
            ),
            content: Text("Settings"),
            onClick: () {},
          ),
          MLMenuItem(
              leading: Icon(
                Icons.power_settings_new,
              ),
              content: Text(
                "Log out",
              ),
              onClick: () async {
                authController.signOut();
                Get.offAll(Root());
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
            Expanded(child: getListOfChats()),
          ],
        ),
      ),
      bottomNavigationBar: bottomCustomNavigationBar(),
    );
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

  // split the chat name if for private chats given a name = username1#username2
  String chatNameSpliter(String name, String chattype) {
    if (chattype == 'group') {
      return name;
    } else {
      List<String> array = name.split('#');
      String finalname = '';
      array.forEach((element) {
        if (element.toString() != userController.user.userName &&
            element.toString() != '#') {
          finalname = element.toString();
        }
      });
      return finalname;
    }
  }

  Widget getListOfChats() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('Chats')
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
                child: Center(
                    child: Text("You Don't Have Any Messages At This Moment")),
              );

            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.asset(
                        snapshot.data.documents[index]['type'] == 'group'
                            ? 'lib/assets/groupimage.png'
                            : 'lib/assets/personimage.png'),
                    title: Text(chatNameSpliter(
                        snapshot.data.documents[index]['GroupName'],
                        snapshot.data.documents[index]['type'])),
                    subtitle: Text(
                      snapshot.data.documents[index]['LastMsg'],
                      softWrap: false,
                    ),
                    onTap: () async {
                      Get.to(
                          new chat(
                              snapshot.data.documents[index].documentID,
                              snapshot.data.documents[index]['GroupName'],
                              snapshot.data.documents[index]['type']),
                          transition: Transition.downToUp);
                      /* Get.put<ProjectController>(ProjectController());
                      ProjectController projectController =
                          Get.find<ProjectController>();
                      projectController.project = Project.fromJson(
                          new Map<String, dynamic>.from(
                              snapshot.data.documents[index].data));
                      Get.to(
                          TasksAndEventsView(),
                          transition: Transition.rightToLeft,
                          duration: Duration(milliseconds: 300));
                          */
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
            Get.off(GroupProjectsView(), transition: Transition.noTransition);
          else if (barIndex == 1)
            return;
          else if (barIndex == 2)
            Get.to(FriendsView(), transition: Transition.noTransition);
          else if (barIndex == 3) return;
        });

        print(index);
      },
    );
  }
}
