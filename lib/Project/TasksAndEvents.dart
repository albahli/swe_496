import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:swe496/Views/GroupProjectsView.dart';
import 'package:swe496/Project/membersView.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';

class TasksAndEvents extends StatefulWidget {
  final String projectName;
  TasksAndEvents({Key key, this.projectName}) : super(key: key);

  @override
  _TasksAndEvents createState() => _TasksAndEvents();
}

class _TasksAndEvents extends State<TasksAndEvents> {
  int barIndex = 0; // Current page index in bottom navigation bar

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
            Get.offAll(GroupProjects());
            print("back to Group Projects");
          },
        ),
        title: Text(widget.projectName),
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

          if(barIndex == 0) // Do nothing, stay in the same page
            return;
          else if(barIndex == 1)
            return;
          else if(barIndex == 2)
            Get.offAll(MembersView(projectName: widget.projectName,));

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
        // Show bottom sheet to display Timeline page
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
      TimelineModel(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: (){

              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey[250],
                  boxShadow: [
                    BoxShadow(color: Colors.black12, spreadRadius: 0.5),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth:300, minWidth: 200, minHeight: 200),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text('Task name: ', style: TextStyle(color: Colors.black),),
                        Text('Description: ', style: TextStyle(color: Colors.black),),
                        Text('Status: ', style: TextStyle(color: Colors.black),),
                        Text('Priority: ', style: TextStyle(color: Colors.black),),
                        Text('Start date: ', style: TextStyle(color: Colors.black),),
                        Text('End date: ', style: TextStyle(color: Colors.black),),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          position: TimelineItemPosition.right,
          iconBackground: Colors.red,
          isFirst: true,
          icon: Icon(Icons.assignment, color: Colors.white,)),
      TimelineModel(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: (){

              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey[250],
                  boxShadow: [
                    BoxShadow(color: Colors.black12, spreadRadius: 0.5),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth:300, minWidth: 200, minHeight: 200),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text('Event name: ', style: TextStyle(color: Colors.black),),
                        Text('Description: ', style: TextStyle(color: Colors.black),),
                        Text('Loaction: (optional) ', style: TextStyle(color: Colors.black),),
                        Text('Date: ', style: TextStyle(color: Colors.black),),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          position: TimelineItemPosition.left,
          iconBackground: Colors.red,
          isFirst: true,
          icon: Icon(Icons.event, color: Colors.white,)),
      TimelineModel(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: (){

              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey[250],
                  boxShadow: [
                    BoxShadow(color: Colors.black12, spreadRadius: 0.5),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth:300, minWidth: 200, minHeight: 200),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text('Task name: ', style: TextStyle(color: Colors.black),),
                        Text('Description: ', style: TextStyle(color: Colors.black),),
                        Text('Status: ', style: TextStyle(color: Colors.black),),
                        Text('Priority: ', style: TextStyle(color: Colors.black),),
                        Text('Start date: ', style: TextStyle(color: Colors.black),),
                        Text('End date: ', style: TextStyle(color: Colors.black),),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          position: TimelineItemPosition.right,
          iconBackground: Colors.red,
          isFirst: true,
          icon: Icon(Icons.assignment, color: Colors.white,)),
    ];

    return Timeline(children: items, position: TimelinePosition.Center);
  }
}
