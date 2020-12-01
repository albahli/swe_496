import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

// ignore: camel_case_types
class datebaseMethods{
  datebaseMethods(){
    
  }
  Future uploadImage(var x) async  {
   // StorageReference ref = FirebaseStorage.instance.ref().child("path");
    //StorageUploadTask upload = ref.putFile(x);
   // StorageTaskSnapshot taskSnapshot = await upload.onComplete;
   // if (taskSnapshot != null) {
    //   return true;
    // }
    
  }
  Future retriveimage(String imgName) {
    //StorageReference storage = FirebaseStorage.instance.ref();
    
   //return FirebaseStorage.instance.ref().child(imgName).getDownloadURL();

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
    Firestore.instance.collection('Chats').document(groupid).collection('messages').add(messageMap).catchError((e){print(e.toString());});
  }
  getGroupNameAndImage(String projectid)  async{
    return await Firestore.instance.collection('Chats').document('1').snapshots();
    //.document(projectid).get(); ;
  }

}

