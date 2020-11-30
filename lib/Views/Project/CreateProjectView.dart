import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:search_choices/search_choices.dart';
import 'package:swe496/Database/ProjectCollection.dart';
import 'package:swe496/controllers/UserControllers/userController.dart';

class CreateProjectView extends StatefulWidget {
  @override
  _CreateProjectViewState createState() => _CreateProjectViewState();
}

class _CreateProjectViewState extends State<CreateProjectView> {
  final formKey = GlobalKey<FormState>();

  UserController userController = Get.find<UserController>();

  TextEditingController _projectName = new TextEditingController();
  List <String> members = new List();
  List<int> selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Project'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 20, 20, 8),
        child: Container(
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: _projectName,
                    validator: (projectNameVal) => projectNameVal.isEmpty
                        ? "Project name cannot be empty"
                        : null,
                    onSaved: (projectNameVal) => _projectName.text = projectNameVal,
                    decoration: InputDecoration(
                        labelText: 'Project Name',
                        hintText: 'Graduation Project.',
                        prefixIcon: Icon(Icons.edit),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
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
                                        child:
                                            Text("Start adding friends to start a project!")),
                                  );
                                return SearchChoices.multiple(
                                  items:
                                      snapshot.data.documents.toList().map((i) {
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
                                    if(userController.user.userID == newMember)
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
                                    if (selectedItemsForValidator.length <1) {
                                      return ("Must select at least 1");
                                    }
                                    return (null);
                                  },
                                  selectedValueWidgetFn: (memberItem) {
                                    return (Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          side: BorderSide(
                                            width: 0.5,
                                          ),
                                        ),
                                        margin: EdgeInsets.all(5),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Text(memberItem
                                              .toString()
                                              .split(',')[0]),
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
                                  label: members.length > 1 ? "Selected Members" : 'Select Members',
                                  underline: Container(
                                    height: 1.0,
                                    decoration: BoxDecoration(
                                        border: Border.all(width: 1)),
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
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ButtonTheme(
                    minWidth: 20,
                    height: 50.0,
                    child: RaisedButton(
                      textColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(30.0),
                              right: Radius.circular(30.0))),

                      onPressed: members.length < 1 ? null : () async {
                        formKey.currentState.save();
                        if (formKey.currentState.validate()) {
                          print('now');
                          print('members length: ' + members.length.toString());
                          members.forEach((element) {
                            print("submitted: " + element.toString());
                          });

                          ProjectCollection().createNewProject(_projectName.text, members);
                         // Get.back();
                          Get.snackbar('Success !',
                              "Project '${_projectName.text} has been created successfully.'");
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const Text('Create New Project',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w300,
                              )),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
