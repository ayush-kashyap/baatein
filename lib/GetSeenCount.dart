
import 'package:baatein/module/Chats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GetSeenCount{
  static void getSeenCount(accType,userEmail,chatId,targetUser)async {
    final chats = await FirebaseFirestore.instance.collection("chats").doc("users").collection(userEmail).doc(chatId).get();
    Chats newChat = Chats.fromMap(chats.data() as Map<String,dynamic>);
    Chats LatestChat=Chats(
      lastMsg: newChat.lastMsg,
      chatId: newChat.chatId,
      nameChat: newChat.nameChat,
      lastMsgDate: newChat.lastMsgDate,
      unseenCount: 0,
      emailtarget: newChat.emailtarget,
      pfp: newChat.pfp
    );
    FirebaseFirestore.instance.collection("chats").doc("users").collection(userEmail).doc(chatId).set(LatestChat.toMap());
  }
}