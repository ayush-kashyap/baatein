import 'package:baatein/GetChatSpaceModule.dart';
import 'package:baatein/GetUser.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:baatein/module/ChatSpace.dart';
import 'package:baatein/module/UserModule.dart';
import 'package:baatein/module/blockModule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class BlockedUsers extends StatefulWidget {
  final UserModule currUser;

  const BlockedUsers({Key? key,required this.currUser}) : super(key: key);

  @override
  State<BlockedUsers> createState() => _BlockedUsersState();
}

class _BlockedUsersState extends State<BlockedUsers> {
  void unblockUser(email) async {
    var targetUser=await GetUser.getUserByEmail(email);
    var chatSpace= await GetChatSpaceModule.getChatSpace(targetUser!, widget.currUser);
    var newChatSpace = ChatSpace(
        chatId: chatSpace!.chatId,
        lastmsg: chatSpace.lastmsg,
        status: false,
        per1: chatSpace.per1,
        per2: chatSpace.per2);
        await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.currUser.proType)
        .collection("usernames")
        .doc(widget.currUser.email)
        .collection("blockedusers")
        .doc(chatSpace.chatId).delete();
    await FirebaseFirestore.instance
        .collection("chatspaces")
        .doc(chatSpace.chatId)
        .set(newChatSpace.toMap());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: HexColor("#4169e9"),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 2,
          title: Text("Blocked users"),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
          .collection("users")
          .doc(widget.currUser.proType)
          .collection("usernames")
          .doc(widget.currUser.email)
          .collection("blockedusers").snapshots(),
            builder: ( context,  snapshot){
              if (snapshot.connectionState == ConnectionState.active){
                if(snapshot.hasData){
                    QuerySnapshot docSnap =snapshot.data as QuerySnapshot;
                    return ListView.builder(
                              itemCount: docSnap.docs.length,
                              itemBuilder: (context, index) {
                                var currsnap= blockModule.fromMap(docSnap.docs[index].data() as Map<String,dynamic>);

                                return ListTile(
                                  leading: CircleAvatar(backgroundImage: NetworkImage(currsnap.blockedUserpfp!),),
                                  title: Text(currsnap.blockedUsername!),
                                  subtitle: Text(currsnap.blockedUseremail!),
                                  trailing: IconButton(icon: Icon(Icons.block),onPressed: (){
                                    unblockUser(currsnap.blockedUseremail);
                                  },),
                                );
                              });
                }else if(snapshot.hasError){
                return Text("Some Error occurred");
                }else{
                  return Text("No users blocked");
                }
              }else{
                return Text("Some Error occurred");
              }
              
            },
          ),
        ),
        ),
    );
  }
}