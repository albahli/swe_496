import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:search_choices/search_choices.dart';
import 'package:swe496/Database/ProjectCollection.dart';
import 'package:swe496/Database/UserProfileCollection.dart';
import 'package:swe496/Views/Project/ProjectSettingsView.dart';
import 'package:swe496/Views/Project/TasksAndEventsView.dart';
import 'package:swe496/controllers/ProjectControllers/projectController.dart';
import 'package:swe496/controllers/UserControllers/userController.dart';
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

  List<String> members = new List();
  List<int> selectedItems = [];
  bool isAdmin = true;

  @override
  Widget build(BuildContext context) {
    projectController.project.members.forEach((member) {
      if (member.memberUID == userController.user.userID && !member.isAdmin) {
        setState(() {
          isAdmin = false;
        });
      }
    });

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      // still not working in landscape mode
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () {
            Get.offAll(Root());
            Get.delete<ProjectController>();
            print("back to 'Root' from 'Members View'");
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
                  },
                )
              : SizedBox()
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
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              child: Icon(Icons.person_add),
              onPressed: () => Get.bottomSheet(addFriendsToGroup(),
                  isScrollControlled: true, ignoreSafeArea: false))
          : SizedBox(),
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

          if (barIndex == 0)
            Get.off(TasksAndEventsView(), transition: Transition.noTransition);
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
      stream: UserProfileCollection()
          .checkUserProjectsIDs(projectController.project.projectID),
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
                  return ListTile(
                    leading: Icon(Icons.account_circle),
                    title: Text(mappedMembersList[index].memberUID),
                    subtitle:
                        Text(mappedMembersList[index].isAdmin ? 'Leader' : ''),
                    onTap: userController.user.userName ==
                            mappedMembersList[index].memberUID
                        ? null
                        : ( isAdmin ? () {
                            showModalBottomSheet(
                                context: context,
                                builder: (BuildContext bc) {
                                  return Container(
                                    child: new Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: <Widget>[
                                        new ListTile(
                                          title: new Text(
                                              mappedMembersList[index]
                                                  .memberUID),
                                        ),
                                        Divider(),
                                        mappedMembersList[index].isAdmin
                                            ? new ListTile(
                                                title: new Text(
                                                    'Dismiss As Leader'),
                                                onTap: () {
                                                  ProjectCollection()
                                                      .changeMemberRole(
                                                          projectController
                                                              .projectID,
                                                          snapshot.data
                                                                  .documents[
                                                              index]['userID'],
                                                          true);
                                                  Get.back();
                                                  setState(() {});
                                                },
                                              )
                                            : new ListTile(
                                                title: new Text(
                                                    'Promote As Leader'),
                                                onTap: () {
                                                  ProjectCollection()
                                                      .changeMemberRole(
                                                          projectController
                                                              .projectID,
                                                          snapshot.data
                                                                  .documents[
                                                              index]['userID'],
                                                          false);
                                                  Get.back();
                                                  setState(() {});
                                                },
                                              ),
                                        new ListTile(
                                          title: new Text(
                                            'Remove From Project',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                          onTap: () {
                                            ProjectCollection()
                                                .removeMemberFromProject(
                                                    projectController
                                                        .project.projectID,
                                                    snapshot.data
                                                            .documents[index]
                                                        ['userID'],
                                                    mappedMembersList[index]
                                                        .isAdmin);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          } : () => null
                          ),
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

  addFriendsToGroup() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add new members'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        child: InkWell(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance
                          .collection('userProfile')
                          .where('friendsIDs',
                              arrayContains: userController.user.userID)
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.hasData && snapshot.data != null) {
                            if (snapshot.data.documents.length == 0)
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                    child: Text(
                                        "Start adding friends to join this project!")),
                              );
                            return SearchChoices.multiple(
                              items: snapshot.data.documents.toList().map((i) {
                                return (DropdownMenuItem(
                                  child: Text(i.data['userName']),
                                  value: i.data['userName'] +
                                      ',' +
                                      i.data['userID'],
                                  onTap: () {},
                                ));
                              }).toList(),
                              hint: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text("Select any"),
                              ),
                              searchHint: "Select any",
                              selectedItems: selectedItems,
                              onChanged: (value) {
                                setState(() {
                                  selectedItems = value;
                                });
                              },
                              displayItem: (item, selected) {
                                var newMember =
                                    item.value.toString().split(',')[1];

                                if (selected && members.isEmpty) {
                                  members.add(newMember);
                                } else if (selected &&
                                    !members.contains(newMember)) {
                                  members.add(newMember);
                                } else if (!selected &&
                                    members.contains(newMember)) {
                                  members.remove(newMember);
                                }

                                for (int i = 0;
                                    i <
                                        projectController
                                            .project.members.length;
                                    i++) {
                                  if (projectController
                                          .project.members[i].memberUID ==
                                      newMember) {
                                    return SizedBox();
                                  }
                                }

                                if (userController.user.userID == newMember)
                                  return SizedBox();

                                return (Row(children: [
                                  selected
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.green,
                                        )
                                      : Icon(
                                          Icons.check_box_outline_blank,
                                          color: Colors.grey,
                                        ),
                                  SizedBox(width: 7),
                                  Expanded(
                                    child: item,
                                  ),
                                ]));
                              },
                              validator: (selectedItemsForValidator) {
                                if (selectedItemsForValidator.length < 1) {
                                  return ("Must select at least 1");
                                }
                                return (null);
                              },
                              selectedValueWidgetFn: (memberItem) {
                                return (Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        width: 0.5,
                                      ),
                                    ),
                                    margin: EdgeInsets.all(5),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Text(
                                          memberItem.toString().split(',')[0]),
                                    )));
                              },
                              doneButton: (selectedItemsDone, doneContext) {
                                return (RaisedButton(
                                    onPressed: () {
                                      Navigator.pop(doneContext);
                                      setState(() {});
                                    },
                                    child: Text("Save")));
                              },
                              closeButton: null,
                              searchFn: (String keyword, items) {
                                List<int> ret = List<int>();
                                if (keyword != null &&
                                    items != null &&
                                    keyword.isNotEmpty) {
                                  keyword.split(" ").forEach((k) {
                                    int i = 0;
                                    items.forEach((item) {
                                      if (k.isNotEmpty &&
                                          (item.value
                                              .toString()
                                              .toLowerCase()
                                              .contains(k.toLowerCase()))) {
                                        ret.add(i);
                                      }
                                      i++;
                                    });
                                  });
                                }
                                if (keyword.isEmpty) {
                                  ret = Iterable<int>.generate(items.length)
                                      .toList();
                                }
                                return (ret);
                              },
                              clearIcon: Icon(Icons.clear),
                              onClear: () => members.clear(),
                              icon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.arrow_drop_down_circle),
                              ),
                              label: members.length > 1
                                  ? "Selected Members"
                                  : 'Select Members',
                              underline: Container(
                                height: 1.0,
                                decoration:
                                    BoxDecoration(border: Border.all(width: 1)),
                              ),
                              isCaseSensitiveSearch: false,
                              iconDisabledColor: Colors.red,
                              iconEnabledColor: Get.theme.primaryColor,
                              isExpanded: true,
                            );
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
                      }),
                ),
                ButtonTheme(
                  minWidth: 20,
                  height: 50.0,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(30.0),
                            right: Radius.circular(30.0))),
                    onPressed: () async {
                      if (members.length == 0 || members.isEmpty) {
                        return;
                      }
                      print('now');
                      print('members length: ' + members.length.toString());
                      members.forEach((element) {
                        print("submitted: " + element.toString());
                      });
                      ProjectCollection().addNewMembersToProject(
                          projectController.projectID, members);
                      Get.back();
                      Get.snackbar('Success ',
                          'New members has been added successfully.');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Text('Add New Members',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
