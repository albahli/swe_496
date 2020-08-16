import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swe496/provider_widget.dart';
import 'package:swe496/services/auth_service.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';

class ProjectPage extends StatefulWidget {
  ProjectPage({Key key}) : super(key: key);

  @override
  _ProjectPage createState() => _ProjectPage();
}

class _ProjectPage extends State<ProjectPage> {
  int i = 0;
  int barIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      // still not working in landscape mode
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 30,
            color: Colors.white,
          ),
          onPressed: () {
            Get.back();
            print("back to Group Projects");
          },
        ),
        title: const Text('Project Example'),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            color: Colors.white,
            onPressed: () {
              // Open project settings page
            },
          )
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: <Widget>[
            _searchBar(),
          ],
        ),
      ),
      bottomNavigationBar: bottomCustomNavigationBar(),
      floatingActionButton: floatingButton(),
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

  // Bottom Navigation Bar
  Widget bottomCustomNavigationBar() {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_turned_in),
          title: Text('Tasks & Events'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          title: Text('Chat'),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_work),
          title: Text('Members'),
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
  Widget floatingButton() {
    return FloatingActionButton(
      child: Icon(
        Icons.calendar_today,
        color: Colors.white,
      ),
      backgroundColor: Colors.red,
      tooltip: 'Timeline',
      onPressed: () {
        // Go to Timeline page
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Timeline'),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ),
              body: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: viewTimeLineOfTasksAndEvents()),
            );
          },
          isScrollControlled: true,
        );
      },
    );
  }

  Widget viewTimeLineOfTasksAndEvents() {
    List<TimelineModel> items = [
      TimelineModel(Placeholder(),
          position: TimelineItemPosition.right,
          iconBackground: Colors.redAccent,
          icon: Icon(Icons.assignment)),
      TimelineModel(Placeholder(),
          position: TimelineItemPosition.left,
          iconBackground: Colors.redAccent,
          icon: Icon(Icons.event)),
      TimelineModel(Placeholder(),
          position: TimelineItemPosition.right,
          iconBackground: Colors.redAccent,
          icon: Icon(Icons.event)),
    ];

    return Timeline(children: items, position: TimelinePosition.Center);
  }
}
