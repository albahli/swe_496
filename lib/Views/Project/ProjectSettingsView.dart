import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:swe496/Database/ProjectCollection.dart';
import 'package:swe496/Views/Project/ProjectActivityLogView.dart';
import 'package:get/get.dart';
import 'package:clipboard/clipboard.dart';
import 'package:swe496/controllers/ProjectControllers/ActivityLogController.dart';
import 'package:swe496/controllers/ProjectControllers/projectController.dart';
import 'package:swe496/utils/root.dart';

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
  final formProjectSettingsKey = GlobalKey<FormState>();

  // Form key for updating the new settings
  final formDeletingKey = GlobalKey<FormState>();

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
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text('Settings'),
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
              key: formProjectSettingsKey,
              child: Card(
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
                        prefixIcon:
                        Icon(IconData(58270, fontFamily: 'MaterialIcons')),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            // TODO: Generate the sharable link
                          },
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
                                .then((value) =>
                                Get.snackbar('Link copied',
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
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Get.put<ActivityLogController>(ActivityLogController());
                Get.to(ProjectActivityLogView());
              },
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(
                              IconData(
                                58790,
                                fontFamily: 'MaterialIcons',
                              ),
                              color: Get.textTheme.caption.color),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Activity Log',
                              style: Get.textTheme.bodyText2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Contains all the activities related to tasks and events.',
                        style: Get.textTheme.caption,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Form(
              key: formDeletingKey,
              child: Card(
                shadowColor: Colors.transparent,
                shape: new RoundedRectangleBorder(
              side: new BorderSide(color: Colors.red[600], width: 1.0),
                borderRadius: BorderRadius.circular(4.0)),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(IconData(57642, fontFamily: 'MaterialIcons'),
                              color: Get.textTheme.caption.color),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Delete Project',
                              style: Get.textTheme.bodyText2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'The project with all the tasks, events and members will be erased completely and cannot be restored.',
                        style: Get.textTheme.caption,
                      ),
                    ),
                    ButtonBar(
                      children: [
                        FlatButton(
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (BuildContext bc) {
                                  return Wrap(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          color: Get.theme.canvasColor,
                                          child: Column(
                                            children: [
                                              ListTile(
                                                title: Text('Delete Project?'),
                                                trailing: FlatButton(
                                                  child: const Text(
                                                    'DELETE',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                  onPressed: () async {
                                                    Get.offAll(Root());
                                                    await ProjectCollection()
                                                        .deleteProject(
                                                        _projectController
                                                            .projectID);
                                                    Get.delete<
                                                        ProjectController>();
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
