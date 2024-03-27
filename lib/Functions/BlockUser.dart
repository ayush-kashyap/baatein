import 'package:baatein/module/blockModule.dart';
import 'package:baatein/module/ChatSpace.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BlockUser{
  static void blockUser(chatSpace,currUser,targetUser) async {
    var newChatSpace = ChatSpace(
        chatId: chatSpace.chatId,
        lastmsg: chatSpace.lastmsg,
        status: true,
        per1: chatSpace.per1,
        per2: chatSpace.per2,
        blockBy: currUser.uid

        );

        blockModule newBlock=blockModule(
          blockedUseremail: targetUser.email,
          blockedUserid: targetUser.uid,
          blockedUsername: targetUser.fullname,
          blockedUserpfp: targetUser.profilepic
        );
        await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser.proType)
        .collection("usernames")
        .doc(currUser.email)
        .collection("blockedusers")
        .doc(chatSpace.chatId)
        .set(newBlock.toMap());


    await FirebaseFirestore.instance
        .collection("chatspaces")
        .doc(chatSpace.chatId)
        .set(newChatSpace.toMap());
    
  }

  static void unblockUser(chatSpace,currUser) async {
    var newChatSpace = ChatSpace(
        chatId: chatSpace.chatId,
        lastmsg: chatSpace.lastmsg,
        status: false,
        per1: chatSpace.per1,
        per2: chatSpace.per2,
        blockBy: ""
        );
        await FirebaseFirestore.instance
        .collection("users")
        .doc(currUser.proType)
        .collection("usernames")
        .doc(currUser.email)
        .collection("blockedusers")
        .doc(chatSpace.chatId).delete();
    await FirebaseFirestore.instance
        .collection("chatspaces")
        .doc(chatSpace.chatId)
        .set(newChatSpace.toMap());
    
  }
}