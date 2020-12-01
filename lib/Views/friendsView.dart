import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multilevel_drawer/multilevel_drawer.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:swe496/utils/root.dart';
import '../Database/UserProfileCollection.dart';
import '../controllers/UserControllers/authController.dart';
import '../controllers/UserControllers/userController.dart';
import 'AccountSettings.dart';

class FriendsView extends StatefulWidget {
  @override
  _FriendsViewState createState() => _FriendsViewState();
}

class _FriendsViewState extends State<FriendsView> {
  int barIndex = 2; // Currently we are at 2 for bottom navigation tabs
  AuthController authController = Get.find<AuthController>();
  UserController userController = Get.find<UserController>();

  final formKey = GlobalKey<FormState>();
  final TextEditingController _friendUsernameController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      // still not working in landscape mode
      appBar: AppBar(
        title: const Text('Friends'),
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
                    ? Text('NULL ?')
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
              onClick: () {
                Get.to(AccountSettings());
              }),
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
        child: SingleChildScrollView(
                  child: Column(
            children: <Widget>[
              _searchBar(),
              getListOfFriends(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: bottomCustomNavigationBar(),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.person_add), onPressed: () => alertAddFriend()),
    );
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

  void alertAddFriend() {
    Alert(
        context: context,
        title: "Edit",
        content: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                validator: (value) =>
                    value.isEmpty ? "username can't be empty" : null,
                controller: _friendUsernameController,
                onSaved: (val) => _friendUsernameController.text = val,
                decoration: InputDecoration(
                  icon: Icon(Icons.edit),
                  focusedBorder: UnderlineInputBorder(),
                  hintText: 'Enter a username',
                ),
              ),
            ],
          ),
        ),
        buttons: [
          DialogButton(
            onPressed: () async {
              formKey.currentState.save();
              if (formKey.currentState.validate()) {
                try {
                  await UserProfileCollection().addFriend(
                      _friendUsernameController.text, userController.user);
                  _friendUsernameController.clear();
                  Navigator.pop(context);
                } catch (e) {
                  Get.snackbar('Error', 'error');
                }
              }
            },
            child: Text(
              "submit",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  Widget getListOfFriends() {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('userProfile')
          .where('friendsIDs', arrayContains: userController.user.userID)
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
                child: Center(child: Text("You don't have any friends")),
              );

            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.supervised_user_circle),
                    title: Text(snapshot.data.documents[index]['userName']),
                    subtitle: Text('Details .......'),
                    onTap: () {},
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
          label: 'Groups',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_turned_in),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.contacts),
          label: 'Friends',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Messages',
        ),
      ],
      currentIndex: barIndex,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: (index) {
        setState(() {
          barIndex = index;

          barIndex = index;

          if (barIndex == 0) // Do nothing, stay in the same page
            Get.to(Root());
          else if (barIndex == 1)
            return;
          else if (barIndex == 2) // Do nothing, stay in the same page
            return;
        });
        print(index);
      },
    );
  }

// Buttons for creating or joining project
}
