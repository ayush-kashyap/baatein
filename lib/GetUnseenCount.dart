
import 'package:cloud_firestore/cloud_firestore.dart';
class GetUnseenCount{
  static Future<int> getUnseenCount(chatId,targetUser) async {
    final data= await FirebaseFirestore.instance.collection("chatspaces").doc(chatId).collection("messages").where("sender",isEqualTo: targetUser).where("seen",isEqualTo: false).get();
    // print(data.docs.length);
    // print("data.lengt");
    return data.docs.length;
  }
}