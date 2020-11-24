import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swe496/controllers/ProjectControllers/ActivityLogController.dart';

class ProjectActivityLogView extends StatefulWidget {
  @override
  _ProjectActivityLogViewState createState() => _ProjectActivityLogViewState();
}

class _ProjectActivityLogViewState extends State<ProjectActivityLogView> {
  @override
  void initState() {
    Get.put<ActivityLogController>(ActivityLogController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Log'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(child: getActivityLog()),
    );
  }

  Widget getActivityLog() {
    return GetX<ActivityLogController>(
        init: Get.put<ActivityLogController>(ActivityLogController()),
        builder: (ActivityLogController activityLogController) {
          if (activityLogController != null &&
              activityLogController.activitiesOfProject != null &&
              activityLogController.initialized &&
              activityLogController.activitiesOfProject.isNotEmpty) {
            return ListView.separated(
                itemCount: activityLogController.activitiesOfProject.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(activityLogController
                          .activitiesOfProject[index].doneBy ),
                    ),
                    title: Text(
                      activityLogController
                          .activitiesOfProject[index].typeOfAction,
                      style: Get.textTheme.bodyText2,
                    ),
                    subtitle: Text(activityLogController
                        .activitiesOfProject[index].date
                        .toDate()
                        .toString()
                        .substring(0, 22)),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(thickness: 1,);
                });
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Center(child: Text("There is no activities in the project.")),
          );
        });
  }
}
