import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swe496/SignIn.dart';
import 'package:swe496/provider_widget.dart';
import 'package:swe496/services/auth_service.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class GroupProjects extends StatefulWidget {
  GroupProjects({Key key}) : super(key: key);

  @override
  _GroupProjects createState() => _GroupProjects();
}

class _GroupProjects extends State<GroupProjects> {
  int i = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false, // still not working in landscape mode
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
          IconButton(
            icon: Icon(
              Icons.search,
              size: 30,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(),
                  Center(
                    child: Row(
                      children: <Widget>[
                        RaisedButton(
                          color: Colors.white,
                          textColor: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(30.0),
                                  right: Radius.circular(0.0)),
                              side: BorderSide(color: Colors.red)),
                          onPressed: () {
                            createProjectAlert(context);
                          },
                          child: Row(
                            children: <Widget>[
                              const Text('Create Project ',
                                  style: TextStyle(fontSize: 15)),
                              Icon(Icons.add),
                            ],
                          ),
                        ),
                        //const SizedBox(height: 30, width: 20,),
                        RaisedButton(
                          color: Colors.white,
                          textColor: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(0.0),
                                  right: Radius.circular(30.0)),
                              side: BorderSide(color: Colors.red)),
                          onPressed: () {},
                          child: Row(
                            children: <Widget>[
                              const Text('Join Project  ',
                                  style: TextStyle(fontSize: 15)),
                              Icon(Icons.group_add),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Container(
                height: 490,
                child: ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: 50,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 50,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          child: Text(
                            'Project ${++i}',
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.red,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            title: Text('Group Projects'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            title: Text('Personal Projects'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('Account / Settings'),
          ),
        ],
      ),
    );
  }

  void createProjectAlert(BuildContext context) {
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
                controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
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
