import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:swe496/Views/Messages.dart';
import 'package:swe496/Views/Project/MembersView.dart';

import 'package:swe496/Views/Project/TasksAndEventsView.dart';
import 'package:swe496/controllers/ProjectControllers/projectController.dart';
import 'package:swe496/controllers/UserControllers/userController.dart';
import 'package:swe496/utils/root.dart';
import 'dart:io';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ChatView extends StatefulWidget {
  final String projectID;

  ChatView({Key key, this.projectID}) : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  int barIndex = 1; // Current page index in bottom navigation bar
  ProjectController projectController = Get.find<ProjectController>();
  UserController userController = Get.find<UserController>();

  

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      // still not working in landscape mode
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () {
            Get.offAll(Root());
            Get.delete<ProjectController>();
            print("back to 'Root' from 'chat View'");
          },
        ),
        title: Text(projectController.project.projectName),
        centerTitle: true,
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ChatAreaView(projectController.projectID)),
      bottomNavigationBar: bottomCustomNavigationBar(),
    );
  }

  // Bottom Navigation Bar
  Widget bottomCustomNavigationBar() {
    return BottomNavigationBar(

      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(IconData(61545, fontFamily: 'MaterialIcons')),
          label: 'Tasks & Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group_work),
          label: 'Members',
        ),
      ],
      currentIndex: barIndex,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      onTap: (index) {
        setState(() {
          barIndex = index;

          if (barIndex == 0)
            Get.off(TasksAndEventsView(), transition: Transition.noTransition);
          else if (barIndex == 1)
            return;
          else if (barIndex == 2) // Do nothing, stay in the same page
            Get.off(MembersView(), transition: Transition.noTransition);
        });
        print(index);
      },
    );
  }
}
class ChatAreaView extends StatefulWidget {
  String chatId;
  ChatAreaView(projectid) {
    chatId = projectid;
  }

  @override
  State<ChatAreaView> createState() {
    return ChatAreaViewState();
  }
}

class ChatAreaViewState extends State<ChatAreaView> {
  File _selectedMedia;
  final storage = FirebaseStorage.instance;
  final picker = ImagePicker();
  void getImage(BuildContext context, String type) async {
    PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery);
    if(!pickedFile.isNull){
    File imageFile = File(pickedFile.path);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Send this ?'),
        content: Container(
          child: Image.file(imageFile),
        ),
        actions: [
          FlatButton(
              onPressed: () async {
                var file = File(pickedFile.path);
                if (pickedFile != null) {
                  var snapshot = await storage
                      .ref()
                      .child(widget.chatId + '/')
                      .putFile(file)
                      .onComplete;
                  var downloadurl = await snapshot.ref.getDownloadURL();
                  sendMediaMsg(downloadurl, type);
                  Navigator.of(context).pop();
                } else {
                  print("no image selected");
                  Navigator.of(context).pop();
                }
              },
              child: Text('Yes')),
          FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'))
        ],
      ),
      barrierDismissible: true,
    
    );
    }
  }

  void getVideo() {}

  UserController userController = Get.find<UserController>();
  TextEditingController messageController = new TextEditingController();
  Stream chatMsgStream;
  datebaseMethods dbMethods = new datebaseMethods();
  void donothing() {}
  void sendMediaMsg(String downloadurl, String type) {
    String Ismedia;
    if (type == 'image') {
      Ismedia = 'I_s?i%m@g/';
    } else if (type == 'video') {}

    if (downloadurl != null) {
      Map<String, dynamic> msgmap = {
        "msg": Ismedia + downloadurl,
        "senderName": userController.user.userName,
        "senderId": userController.user.userID,
        "time": DateTime.now().toString(),
        "isFile": true,
      };
      dbMethods.sendmessages(widget.chatId, msgmap);
    }
  }

  void alertMeidaSending(BuildContext context, var image) {
    Alert(
        context: context,
        title: 'Send this file ?',
        closeFunction: () => null,
        style: AlertStyle(
            animationType: AnimationType.fromBottom,
            animationDuration: Duration(milliseconds: 300),
            descStyle: TextStyle(
              fontSize: 12,
            )),
        content: Theme(
            data: Get.theme,
            child: Container(
              child: image,
            )),
        buttons: [
          DialogButton(
            radius: BorderRadius.circular(30),
            onPressed: () async {
              try {} catch (e) {
                print(e.message);
              }
            },
            child: Text(
              "Submit",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
            ),
          )
        ]);
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      Map<String, dynamic> msgmap = {
        "msg": messageController.text,
        "senderName": userController.user.userName,
        "senderId": userController.user.userID,
        "time": DateTime.now().toString(),
        "isFile": false,
      };
      dbMethods.sendmessages(widget.chatId, msgmap);
      messageController.text = "";
    }
  }

  void attchFile(BuildContext context, String filetype) {
    print(filetype);
    if (filetype == 'image') {
      getImage(context, filetype);
    } else if (filetype == 'video') {
      getVideo();
    }
  }

  Widget chatMessageList() {
    return StreamBuilder(
      stream: chatMsgStream,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                shrinkWrap: true,
                //  scrollDirection: Axis.horizontal,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  String timeformating = snapshot
                      .data.documents[index].data['time']
                      .toString()
                      .substring(11, 16);
                  return messageWidget(
                      snapshot.data.documents[index].data['senderId'],
                      snapshot.data.documents[index].data['msg'],
                      snapshot.data.documents[index].data['senderName'],
                      timeformating,
                      snapshot.data.documents[index].data['isFile']);
                })
            : Container();
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    dbMethods.getChatmessages(this.widget.chatId).then((value) {
      chatMsgStream = value;

      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
   //// var maxheight = screenSize.height;
  
    return Scaffold(
      // height: maxheight,

    // backgroundColor: Color.fromARGB(70, 0, 70, 155),
      body: Container(
        child: Stack(
          children: <Widget>[

            Container(
      ////          height: maxheight * 0.765,
            
                padding: EdgeInsets.all(5),
            
                child: chatMessageList()),

            Container(
              margin: EdgeInsets.all(0),
              alignment: Alignment.bottomCenter,
              child: Container(
    ////            height: maxheight,
                alignment: Alignment.bottomCenter,
                // color: Colors.limeAccent[50],
                child: Container(
      ////            height: maxheight * 0.1,
                  //color: Colors.indigo[100],

                
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Row(
                   
                    children: [
                      PopupMenuButton<String>(
                          padding: EdgeInsets.all(0),
                          elevation: 8,
                          offset: Offset(-30, -175),
                          icon: Icon(Icons.attach_file),
                          onSelected: (String filetype) {
                            attchFile(context, filetype);
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                                PopupMenuItem(
                                  value: "Video",
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.video_library,
                                      ),
                                      Text(" Video"),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                    value: "image",
                                    child: Row(
                                      children: [
                                        Icon(Icons.image),
                                        Text(" Image")
                                      ],
                                    )),
                                PopupMenuItem(
                                    value: "file",
                                    child: Row(
                                      children: [
                                        Icon(Icons.insert_drive_file),
                                        Text(" File")
                                      ],
                                    ))
                              ]),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          strutStyle: StrutStyle(),
                          controller: messageController,
                          style: TextStyle(color: Colors.black),
                          maxLines: 2,
                          minLines: 1,
                          
                          decoration: InputDecoration(
                            hintText: "message",
                            // border: InputBorder,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          sendMessage();
                        },
                        child: Container(
                       
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                const Color(0x36FFFFFF),
                                const Color(0x0FFFFFFF),
                              ]),
                              borderRadius: BorderRadius.circular(40)),
                          padding:
                              EdgeInsets.only(top: 15, bottom: 10, left: 5),
                          child: Icon(Icons.send),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class datebaseMethods{
  datebaseMethods(){
    
  }
  Future uploadImage(var x) async  {

    
  }
  Future retriveimage(String imgName) {

  }
  getUserByUserName(String username) async {
    return await 
    Firestore.instance.collection('users').where('name', isEqualTo: username).getDocuments();
  }
  getChatmessages(String chatid) async {
    return await Firestore.instance.collection('Chats').document(chatid).collection('messages'). orderBy('time').snapshots();
  }
  sendmessages(String groupid , messageMap) async {
    print(groupid);
    String lastmsg = '';
    String content = ''; 
    if(messageMap['isFile']){
      content = 'sent a file';
    } else content = messageMap['msg'];
    lastmsg = messageMap['senderName'] + ' : ' + content;
    Firestore.instance.collection('Chats').document(groupid).updateData(({'LastMsg':lastmsg})).catchError((e){print(e.toString());});
    Firestore.instance.collection('Chats').document(groupid).collection('messages').add(messageMap).catchError((e){print(e.toString());});
  }
  getGroupNameAndImage(String projectid)  async{
    return await Firestore.instance.collection('Chats').document('1').snapshots();
    
  }

}


class messageWidget extends StatelessWidget {
  UserController userController = Get.find<UserController>();
  String myusername;
  String msg;
  String senderName;
  bool isFile;
  String time;
  bool selfmsg;
  String downloadurl;
  Alignment msgAlign;
  Color msgcolor;
  double maxwidth;
  double widgetwidth;
  messageWidget(String senderid, String msg, String senderName, String time,
      bool isFile) {
    //bool selfmsg = senderName == 'me';
    this.msg = msg;
    this.senderName = senderName + " :";
    this.time = time;
    this.isFile = isFile;
    if (isFile) {
      downloadurl = msg.substring(10);
    }
    if (senderid == userController.user.userID) {
      msgAlign = Alignment.bottomRight;
      this.senderName = "you :";
      msgcolor = Colors.lightGreen;
    } else {
      msgAlign = Alignment.bottomLeft;
      msgcolor = Colors.white70;
    }
  }
  double widgetWidth(double maxw) {
    // method to return the best widget width depending on message length
    if (this.msg.length <= 6 && this.senderName.length <= 8 && !isFile) {
      return maxw * 0.15;
    } else if ((this.msg.length <= 14 && this.senderName.length <= 14) ||
        isFile) {
      return maxw * 0.3;
    } else if (this.msg.length <= 22 &&
        this.senderName.length <= 22 &&
        !isFile) {
      return maxw * 0.5;
    } else if (this.msg.length <= 30 &&
        this.senderName.length <= 30 &&
        !isFile) {
      return maxw * 0.6;
    } else {
      return maxw * 0.7;
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var maxheight = screenSize.height;
    var _maxWidth = screenSize.width;
    var widgetSize = this.widgetWidth(_maxWidth);
    return Material(
      child: Container(
        //color: Color.fromARGB(70, 0, 70, 155),
        padding: EdgeInsets.only(bottom: 25, right: 2, left: 6),
        alignment: msgAlign,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: widgetSize,
            // minWidth: 10,
          ),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(1),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  //borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15) , topLeft: Radius.circular(15) , topRight: Radius.circular(2), bottomRight: Radius.circular(2)),
                  color: msgcolor,
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                        padding: EdgeInsets.all(8),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          senderName,
                          textAlign: TextAlign.left,
                        )),
                    Container(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        alignment: Alignment.topLeft,
                        child: !isFile
                            ? Text(
                                msg,
                                textAlign: TextAlign.left,
                              )
                            : Container(
                                child: FlatButton(
                                  child: Image.network(downloadurl),
                                  onPressed: () {
                                    showDialog(
                                      // child: FlatButton(onPressed: (){}, child: Icon(Icons.arrow_back)),
                                      barrierColor: Colors.white,
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        content: Container(
                                          child: Image.network(downloadurl),
                                        ),
                                      ),
                                      barrierDismissible: true,
                                    );
                                  },
                                ),
                              )),
                    Container(
                        padding: EdgeInsets.only(right: 5, bottom: 5, top: 5),
                        alignment: Alignment.bottomRight,
                        child: Text(
                          time,
                          maxLines: 1,
                          softWrap: false,
                          textAlign: TextAlign.right,
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
