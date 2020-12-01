import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swe496/controllers/private_folder_controllers/activity_list_controller.dart';

class ActivityLogView extends StatefulWidget {
  @override
  _ActivityLogViewState createState() => _ActivityLogViewState();
}

class _ActivityLogViewState extends State<ActivityLogView> {
  @override
  void initState() {
    Get.put<ActivityListController>(ActivityListController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity Log'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(child: getActivityLog()),
    );
  }

  Widget getActivityLog() {
    return GetX<ActivityListController>(
      init: Get.put<ActivityListController>(ActivityListController()),
      builder: (ActivityListController activityLogController) {
        if (activityLogController != null &&
            activityLogController.activityList != null &&
            activityLogController.initialized &&
            activityLogController.activityList.isNotEmpty) {
          return ListView.separated(
              itemCount: activityLogController.activityList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  // leading: Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Text(activityLogController
                  //       .activityList[index].),
                  // ),
                  title: Text(
                    activityLogController.activityList[index].actionType,
                    style: Get.textTheme.bodyText2,
                  ),
                  subtitle: Text(
                    activityLogController.activityList[index].actionDate
                        .toString()
                        .substring(0, 16),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return Divider(
                  thickness: 1,
                );
              });
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Center(child: Text("There is no activities in private folder.")),
        );
      },
    );
  }
}
