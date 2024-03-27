import 'package:baatein/module/SMSModule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SeenMessage{
  static void hasSeenMessage(messageId,targetUser,chatId) async{
    final receivedMSG=await FirebaseFirestore.instance.collection("chatspaces").doc(chatId).collection("messages").doc(messageId).get();
    SMSModule receivedMsgModel=SMSModule.fromMap(receivedMSG.data() as Map<String,dynamic>);
  if(receivedMsgModel.sender==targetUser){
    SMSModule seenMsgModule=SMSModule(
      messageid: receivedMsgModel.messageid,
      msg: receivedMsgModel.msg,
      seen: true,
      sender: receivedMsgModel.sender,
      time: receivedMsgModel.time,
      deletedfor: receivedMsgModel.deletedfor,
      image:receivedMsgModel.image,
    );
    await FirebaseFirestore.instance.collection("chatspaces").doc(chatId).collection("messages").doc(messageId).set(seenMsgModule.toMap());
  }
        

    
  }

  
}