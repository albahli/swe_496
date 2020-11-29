import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:swe496/controllers/UserControllers/userController.dart';
import 'helpFunctions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class chat extends StatelessWidget {
  String chatid;
  String name;
  String type;

  chat(String id , String n , String t) {
    chatid = id;
    this.name = n;
    this.type = t;
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var maxheight = screenSize.height;
    var _maxWidth = screenSize.width;
    print(this.chatid);
    print('in group chat');
    print(name + type);
    return Material(
      // height: maxheight,
      // width: _maxWidth,
      // child: Scaffold(
      // resizeToAvoidBottomInset: true,

      child: SingleChildScrollView(
        child: Column(
          children: [
           
            infoRow(name , type),
            Container(
              height: maxheight * 0.865,
              width: _maxWidth,
              child: Scaffold(
                body: ChatArea(this.chatid),
                resizeToAvoidBottomInset: true,
              ),
            ),
          ],
        ),
      ),

      // ),
    );
  }
}

class membersView extends StatelessWidget {
  membersView();

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var maxheight = screenSize.height;
    var maxwidth = screenSize.width;
    void copylink() {}
    void editChatInfo() {}
    void backToChat() {
      Get.back();
    }

    return Material(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue,
          //borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: Container(
          //color: Color.fromARGB(70, 0, 70, 155),
          decoration: BoxDecoration(
            color: Colors.white70,
            // borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          height: maxheight,
          width: maxwidth,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  height: maxheight * 0.25,
                  child: Stack(
                    overflow: Overflow.clip,
                    children: <Widget>[
                      Container(
                        width: maxwidth,
                        //  child: Image(image: AssetImage("C:/Users/ABOD/Desktop/photos/images.jfif", ) , fit: BoxFit.fill,),
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        height: maxheight * 0.1,
                        width: maxwidth * 0.15,
                        //  color: Colors.black,
                        child: FlatButton(
                          //  margin: EdgeInsets.only(left: maxwidth*0.07 , top: maxheight*0.035),
                          //     color: Colors.white,
                          onPressed: backToChat,
                          child: Icon(
                            Icons.arrow_back,
                            size: 35,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        //    color: Colors.white,
                        height: maxheight * 0.1,
                        width: maxwidth,
                        child: FlatButton(
                          onPressed: editChatInfo,
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 30,
                          ),
                          padding: EdgeInsets.only(left: 5),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  // name container
                  //    color: Color.fromARGB(70, 0, 70, 155),
                  alignment: Alignment.topLeft,
                  padding:
                      EdgeInsets.only(left: 25, top: 15, right: 20, bottom: 15),

                  child: Text(
                    "Group name: 123456789012345678901234567890123456789012345678901234567890",
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),
                Divider(
                  //  color: Color.fromARGB(70, 0, 70, 155),
                  color: Colors.black,
                  thickness: 1,
                ),
                Container(
                  //descreption container
                  //        color: Color.fromARGB(70, 0, 70, 155),
                  alignment: Alignment.topLeft,
                  padding:
                      EdgeInsets.only(left: 25, top: 5, right: 20, bottom: 5),
                  child: Text(
                    "description  : sssssssssssssssssssssssssssssssssssssssssssssssssss",
                    style: TextStyle(color: Colors.black, fontSize: 20),
                  ),
                ),
                Divider(
                  //  color: Color.fromARGB(70, 0, 70, 155),
                  color: Colors.black,
                  thickness: 1,
                ),
                Container(
                  //link container
                  //  margin: EdgeInsets.only(right: 5),
                  width: maxwidth,
                  alignment: Alignment.centerLeft,
                  // color: Color.fromARGB(70, 0, 70, 155),

                  child: Row(
                    children: <Widget>[
                      //   SingleChildScrollView(
                      //  scrollDirection: Axis.horizontal,
                      //child:
                      Container(
                        //   color: Color.fromARGB(70, 0, 70, 155),
                        width: maxwidth * 0.9,
                        padding: EdgeInsets.only(left: 25),
                        child: Text(
                          "group link",
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                      // ),
                      Container(
                        //   color: Colors.blue,
                        width: maxwidth * 0.1,
                        child: FlatButton(
                            padding: EdgeInsets.only(right: 5, left: 5),

                            //  color: Color.fromARGB(70, 0, 70, 155),
                            onPressed: copylink,
                            child: Icon(Icons.content_copy)),
                      )
                    ],
                  ),
                ),
                Divider(
                  //  color: Color.fromARGB(70, 0, 70, 155),
                  color: Colors.black,
                  thickness: 1,
                ),
                Container(
                  width: maxwidth,
                  alignment: Alignment.topLeft,
                  //    margin: EdgeInsets.all(10),
                  padding: EdgeInsets.only(left: 5, right: 5, top: 8),
                  // height: 500,
                  //  color: Color.fromARGB(70, 0, 70, 155),
                  child: Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.only(left: 20, bottom: 5),
                        child: Text(
                          "Members :",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      //  Divider(
                      //   color: Colors.black,
                      //   thickness: 0.7,
                      //    ),
                      Container(
                        padding: EdgeInsets.only(top: 5),
                        margin: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white70,
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Column(
                          children: <Widget>[
                            member(true),
                            //    Text('data'),
                            member(true),
                            member(false),
                            member(false),
                            member(false), member(false),
                            member(false),
                            member(false),

                            //   Text('data'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                //  Text("xxxxxxxxxxxxxx")
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class member extends StatelessWidget {
  Icon adminIcon;
  String name = "nameeeeeeeeeeeeeeeeeeeeeeeeeeeeee";
  member(bool admin) {
    adminIcon = Icon(Icons.settings);
    if (!admin) {
      adminIcon = null;
    } else
      name = "admin";
  }
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var maxheight = screenSize.height;
    var maxwidth = screenSize.width;
    return Container(
      decoration: BoxDecoration(
        // color: Colors.white70,

        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      padding: EdgeInsets.only(left: 5, right: 5, top: 1),
      height: maxheight * 0.1,
      //color: Colors.amber,
      child: Column(
        children: <Widget>[
          //Divider(color: Colors.black,),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  height: maxheight * 0.07,
                  width: maxheight * 0.07,
                  decoration: BoxDecoration(
                    //  color: Colors.blue,
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(
                          "C:/Users/ABOD/Desktop/photos/images.jfif"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,

                  padding: EdgeInsets.only(left: 5),
                  child: Text(
                    name,
                    style: TextStyle(fontSize: 25),
                  ),
                  //color: Colors.blue,
                  //  alignment: Alignment.center,
                  //  height: 30,
                  // width: maxwidth*0.6,
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Container(
                    child: adminIcon,
                  )),
            ],
          ),
          Divider(
            color: Colors.black,
            thickness: 1.1,
          )
        ],
      ),
    );
  }
}

class GroupchatUpperBar extends StatefulWidget {
  String chatname;
  String type;
  GroupchatUpperBar(String name , String type) {
    this.chatname = name;
    this.type = type;
  }

  @override
  _GroupchatUpperBarState createState() => _GroupchatUpperBarState();
}

class infoRow extends StatefulWidget {
  String type;
  String name;
  infoRow(String name, String type) {
    this.name = name;
    this.type = type;
  }
  infoRow.def(String na) {
    this.name = 'error';
  }

  @override
  _infoRowState createState() => _infoRowState();
}

class _infoRowState extends State<infoRow> {
  ImageStream x;
 // ImageProvider m = AssetImage('images/assets/whiteimage.png');

  //NetworkImage g;
  //bool isloading = true;
  //AssetImage defaltImg = AssetImage('C:/Users/ABOD/Desktop/photos/images.jfif');
  @override
  initState() {
    /*
    print('object');
    if (!widget.imgsrc.isNull) {
      print(widget.imgsrc);
      try {
        g = NetworkImage(widget.imgsrc);
        g
            .resolve(new ImageConfiguration())
            .addListener(ImageStreamListener((info, call) {
          if (mounted) {
            setState(() {
              isloading = false;
            });
          }
        }));
      } catch (e) {
        print(e.message);
      }
    }
    */
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var maxheight = screenSize.height;
    var _maxWidth = screenSize.width;

    return Material(
      child: Container(
        padding: EdgeInsets.only(bottom: 6),
        color: Colors.lightBlue,
        width: _maxWidth,
        child: Column(
          children: <Widget>[
            // Container(
            //  color: Colors.redAccent,
            // // height: maxheight*0.045,
            // ),
            Container(
                // padding: EdgeInsets.only(top: maxheight*0.035),
                padding: EdgeInsets.only(top: maxheight * 0.035),
                color: Colors.lightBlue,
                height: maxheight * 0.13,
                width: _maxWidth,
                child: Container(
                    // padding: EdgeInsets.only(left: 5),
                    // onPressed: ViewGroupinfo,
                    child: Row(
                  children: <Widget>[
                    Expanded(
                        flex: 2,
                        child: FlatButton(
                          //   color: Colors.blue,
                          //  padding: EdgeInsets.all(4),
                          onPressed: null, //ViewGroupinfo,
                          colorBrightness: Brightness.dark,
                          highlightColor: Colors.redAccent,
                          child: Container(
                            // height: maxheight*0.1,
                            // width: maxheight*0.1,
                            //color: Colors.blue,

                            //height: 60,
                            // margin: EdgeInsets.all(5),

                            decoration: widget.type=='group'
                                ? BoxDecoration(
                                    //  color: Colors.blue,
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                    image : Image.asset('lib/assets/groupimage.png').image,
                                      fit: BoxFit.fill,
                                    ),
                                  )
                                : BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                    image :  Image.asset('lib/assets/personimage.png').image,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                            // child: Image(image: AssetImage("C:/Users/ABOD/Desktop/photos/2.png")),
                          ),
                        )),
                    Expanded(
                        flex: 5,
                        child: Container(
                          //  colorBrightness: Brightness.dark,
                          //   highlightColor: Colors.redAccent,
                          //   onPressed: null ,// ViewGroupinfo,
                          child: Container(
                            //  color: Colors.green,
                            // alignment:AlignmentDirectional.center ,
                            // name max length 69
                            child: Text(
                              widget.name,
                              maxLines: 3,
                              textAlign: TextAlign.left,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        )),
                    Expanded(
                        flex: 1,
                        child: Container(
                          //   color: Colors.orange,
                          //    color: Colors.redAccent,
                          alignment: Alignment.centerLeft,

                          // child:  DropdownButton( items: null, onChanged: null , icon: Icon(Icons.more_vert) , iconSize: 30, ),
                        )),
                  ],
                ))),
          ],
        ),
      ),
    );
  }
}

class _GroupchatUpperBarState extends State<GroupchatUpperBar> {
  Stream barStream;
  datebaseMethods db = new datebaseMethods();
  String imgsrc;
  var name;
 // NetworkImage zg;
  Widget info() {
    return StreamBuilder(
        stream: barStream,
        builder: (context, snapshot) {
          //   if(true ){
          print('next try');
          String imgsrc;
          //print(snapshot.data['image']);
          if (snapshot.hasData) {
            return snapshot.hasData
                ? infoRow('', 'project name ')
                : infoRow('', 'namee');
          } else
            return Container();
          //imgsrc = snapshot.data['image']:{};
          //  print(imgsrc);
          //   db.retriveimage(imgsrc).whenComplete(() {} ).then((value) {
          //  print(value.toString());

          //  return Container(
          //  child: infoRow( snapshot.data['image'] , snapshot.data['name'].toString()) ,
          // );
        }
        // });}
        ////
        //    },
        );
  }
/*
    void dl() async{
    var pic = FirebaseStorage.instance.ref().child('2.png');
     pic.getDownloadURL().then((value) => {
     print(value),
       this.setState(() {
    imgsrc = value.toString();
      //final http.Response downloadData= await http.get(value);
      //this.img = downloadData.body;
    })
  });
  }
*/

  void dx() async {
    setState(() {});
  }

  @override
  void initState() {
    //db.getGroupNameAndImage(widget.projectId).then((value) {
    //  barStream = value;
    //  setState(() {});
   // }
   // );
    super.initState();
  }

  void ViewGroupinfo() {
    Get.to(membersView());
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var maxheight = screenSize.height;

    var _maxWidth = screenSize.width;
    return info();
  }
}

class ChatArea extends StatefulWidget {
  String chatId;
  ChatArea(projectid) {
    chatId = projectid;
  }

  @override
  State<StatefulWidget> createState() {
    return ChatAreaState();
  }
}

class MediaView extends StatelessWidget {
  PickedFile media;
  MediaView(PickedFile media) {
    this.media = media;
  }
  void send() {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            // color: Colors.red,
            alignment: Alignment.center,
            height: 500,
            width: 500,
            //  child: Image.file(PickedFile) ,
          ),
          Container(
            child: FlatButton(onPressed: send, child: Text('send')),
          )
        ],
      ),
    );
  }
}

class ChatAreaState extends State<ChatArea> {
  File _selectedMedia;
  final storage = FirebaseStorage.instance;
  final picker = ImagePicker();
  void getImage(BuildContext context, String type) async {
    PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery);
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
    // File imageFile = File(PickedFile.path);
    // Get.to(new MediaView(PickedFile));
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
    dbMethods.getChatmessages(widget.chatId).then((value) {
      chatMsgStream = value;

      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var maxheight = screenSize.height;
    var _maxWidth = screenSize.width;

    return Scaffold(
      // height: maxheight,

      backgroundColor: Color.fromARGB(70, 0, 70, 155),
      body: Container(
        child: Stack(
          // alignment: Alignment.bottomCenter,
          //crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            //     Container(
            // height: maxheight*0.765,
            // padding: EdgeInsets.only(bottom:5  , top: 5 , left: 2 , right: 8),
            //   color: Color.fromARGB(70, 0, 70, 155),
            //     SingleChildScrollView (
            //      primary: false,
            //     scrollDirection: Axis.vertical,
            Container(
                height: maxheight * 0.765,
                padding: EdgeInsets.all(5),
                //  color: Colors.amber,
                child: chatMessageList()),
            //   color: Color.fromARGB(70, 0, 70, 155),
            //   height: maxheight*0.765 ,
            //     color: Colors.pink,
            //  width: _maxWidth,
            //   child: Column(
            //   padding: EdgeInsets.only(bottom:5  , top: 5 , left: 2 , right: 8),
            //   children: <Widget>[
            //    SingleChildScrollView(child: Container(child: chatMessageList())),
            //   ],

            //   )

            //   ),
            //   ) ,

            // SingleChildScrollView(child: chatMessageList()),
            // alignment: Alignment.bottomCenter,

            Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: maxheight,
                alignment: Alignment.bottomCenter,
                // color: Colors.limeAccent[50],
                child: Container(
                  height: maxheight * 0.1,
                  //color: Colors.indigo[100],
                  color: Colors.white,

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
                          //textAlignVertical: TextAlignVertical.top,
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
                          //height: 40,
                          // width: 40,
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
        color: Color.fromARGB(70, 0, 70, 155),
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
