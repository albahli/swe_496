import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swe496/Project/Project.dart';
import 'package:swe496/SignIn.dart';
import 'package:swe496/provider_widget.dart';
import 'package:swe496/services/auth_service.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class GroupProjects extends StatefulWidget {
  GroupProjects({Key key}) : super(key: key);

  @override
  _GroupProjects createState() => _GroupProjects();
}

class _GroupProjects extends State<GroupProjects> {
  int i = 0;
  int barIndex = 0 ;

  var listOfProjects;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomPadding: false,
        // still not working in landscape mode
        appBar: AppBar(
          leading: Transform.rotate(
            angle: 180 * 3.14 / 180,
            child: IconButton(
              icon: Icon(
                Icons.exit_to_app,
                size: 30,
                color: Colors.white,
              ),
              onPressed: () async {
                try {
                  AuthService auth = Provider.of(context).auth;
                  await auth.signOut();
                  Get.off(SignIn());
                  print("Signed Out");
                } catch (e) {
                  print(e.toString());
                }
              },
            ),
          ),
          title: const Text('Group Projects'),
          centerTitle: true,
          backgroundColor: Colors.red,
          actions: <Widget>[
          ],
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              _searchBar(),
              Expanded(
                child: getListOfProjects(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: bottomCustomNavigationBar(),
        floatingActionButton: floatingButtons()
    );
  }

  // Search Bar
  _searchBar(){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search'
        ),
        onChanged: (textVal){
          textVal = textVal.toLowerCase();
          setState(() {
          });
        },
      ),
    );
  }

  List<String> getListElement(){
    int length = 30; // Number of projects, ex: 30.
    var items = List<String>.generate(length, (counter){
      counter++;
      return 'Project $counter';
    });
    return items;
  }

  Widget getListOfProjects(){

     listOfProjects = getListElement();
    return ListView.builder(
        itemCount: listOfProjects.length,
        itemBuilder: (context, index){
          return ListTile(
            leading: Icon(Icons.account_circle),
            title: Text(listOfProjects[index]),
            subtitle: Text('Details ...'),
            onTap: (){
              Get.to(ProjectPage());
            },
          );
        }

    );
  }

  // Bottom Navigation Bar

    Widget bottomCustomNavigationBar() {
      return BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            title: Text('Groups'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            title: Text('Personal'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            title: Text('Search'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            title: Text('Messages'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            title: Text('Account'),
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


  // Form to create new project
  void alertCreateProjectForm(BuildContext context) {
    Alert(
        context: context,
        title: 'Create New Project',
        desc:
            "We will send you a link to your account's email to reset your password.",
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
          child: Column(
            children: <Widget>[
              TextFormField(
                validator: (value) {
                  return;
                },
                onSaved: (value) {
                  setState(() {});
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
        buttons: [
          DialogButton(
            color: Colors.red,
            radius: BorderRadius.circular(30),
            onPressed: () async {},
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
