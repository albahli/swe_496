import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:swe496/Database/ProjectCollection.dart';
import 'package:swe496/controllers/projectController.dart';
import 'package:get/get.dart';
import 'package:clipboard/clipboard.dart';

class ProjectSettingsView extends StatefulWidget {
  @override
  _ProjectSettingsViewState createState() => _ProjectSettingsViewState();
}

class _ProjectSettingsViewState extends State<ProjectSettingsView> {
  ProjectController _projectController = Get.find<ProjectController>();
  TextEditingController _editedProjectNameController =
      new TextEditingController();
  TextEditingController _editedPinnedMessageController =
      new TextEditingController();
  bool _isJoiningLinkEnabled;

  // Form key for updating the new settings
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _editedProjectNameController.text = _projectController.project.projectName;
    _editedPinnedMessageController.text =
        _projectController.project.pinnedMessage;
    _isJoiningLinkEnabled = _projectController.project.isJoiningLinkEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () {
            Get.back();
            print("back to 'Project view' from 'Settings'");
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.restore),
            tooltip: 'Restore fields',
            onPressed: () {
              setState(() {
                _editedProjectNameController.text =
                    _projectController.project.projectName;
                _editedPinnedMessageController.text =
                    _projectController.project.pinnedMessage;
                _isJoiningLinkEnabled =
                    _projectController.project.isJoiningLinkEnabled;
              });
            },
          )
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _editedProjectNameController,
                      decoration: InputDecoration(
                        labelText: 'Project name',
                        hintText: _projectController.project.projectName,
                        prefixIcon: Icon(Icons.edit),
                      ),
                      validator: (editedProjectNameVal) =>
                          editedProjectNameVal.isEmpty
                              ? 'Project name cannot be empty'
                              : null,
                    ),
                    TextFormField(
                      controller: _editedPinnedMessageController,
                      decoration: InputDecoration(
                        labelText: 'Pinned message',
                        hintText: _projectController.project.pinnedMessage,
                        prefixIcon: Icon(IconData(58270, fontFamily: 'MaterialIcons')),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.link),
                        ),
                        Text('Joining link enabled'),
                        Switch(
                            value: _isJoiningLinkEnabled,
                            onChanged: (value) {
                              setState(() {
                                _isJoiningLinkEnabled = value;
                                print(_isJoiningLinkEnabled);
                              });
                            }),
                        Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.content_copy,
                          ),
                          tooltip: 'Copy link',
                          onPressed: () {
                            FlutterClipboard.copy(
                                    _projectController.project.joiningLink)
                                .then((value) => Get.snackbar('Link copied',
                                    '${_projectController.project.joiningLink}',
                                    titleText: Text(
                                      'Link copied',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    snackPosition: SnackPosition.BOTTOM,
                                    icon: Icon(Icons.done),
                                    margin: EdgeInsets.all(6)));
                          },
                        )
                      ],
                    ),
                    Divider(
                      thickness: 1,
                    ),
                    //TODO: Implement notification settings.
                    ButtonBar(
                      children: [
                        FlatButton(
                          child: const Text('Save'),
                          onPressed: () {
                            ProjectCollection().updateProjectSettings(
                                _projectController.project.projectID,
                                _editedProjectNameController.text,
                                _editedPinnedMessageController.text,
                                _isJoiningLinkEnabled);
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
