import 'module/UserModule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'module/Chats.dart';
import 'module/ChatSpace.dart';

class GetChatSpaceModule{
  static Future<ChatSpace?> getChatSpace(UserModule targetUser,UserModule currUser)async{
    ChatSpace? chatSpace;
    String uidU=currUser.uid!;
    String uidT=targetUser.uid!;
    QuerySnapshot snap= await FirebaseFirestore.instance.collection("chatspaces").where("per1",isEqualTo: currUser.uid).where("per2",isEqualTo: targetUser.uid).get();
    QuerySnapshot snap2= await FirebaseFirestore.instance.collection("chatspaces").where("per2",isEqualTo: currUser.uid).where("per1",isEqualTo: targetUser.uid).get();
    if(snap.docs.isNotEmpty){
      var docData=snap.docs[0].data();
      ChatSpace existingSpace=ChatSpace.fromMap(docData as Map<String,dynamic>);
      chatSpace=existingSpace;
    }else if(snap2.docs.isNotEmpty){
      var docData=snap2.docs[0].data();
      ChatSpace existingSpace=ChatSpace.fromMap(docData as Map<String,dynamic>);
      chatSpace=existingSpace;
    }else{
      ChatSpace newSpace=ChatSpace(
        chatId: uuid.v1(),
        lastmsg: "",
        per1: currUser.uid,
        per2: targetUser.uid,
        status:false,
        blockBy:""
      );
      Chats newChat=Chats(
        chatId: newSpace.chatId,
        lastMsg: newSpace.lastmsg,
        lastMsgDate: DateTime.now().toString(),
        unseenCount: 0,
        pfp: targetUser.profilepic,
        nameChat: targetUser.fullname,
        emailtarget: targetUser.email,
      );
      Chats newTChat=Chats(
        chatId: newSpace.chatId,
        lastMsg: newSpace.lastmsg,
        lastMsgDate: DateTime.now().toString(),
        unseenCount: 0,
        pfp: currUser.profilepic,
        nameChat: currUser.fullname,
        emailtarget: currUser.email,
      );
      await FirebaseFirestore.instance.collection("chatspaces").doc(newSpace.chatId).set(newSpace.toMap());
      await FirebaseFirestore.instance.collection("chats").doc("users").collection(currUser.email!).doc(newSpace.chatId).set(newChat.toMap());
      await FirebaseFirestore.instance.collection("chats").doc("users").collection(targetUser.email!).doc(newSpace.chatId).set(newTChat.toMap());
      chatSpace=newSpace;
    }
    return chatSpace;
  }
}