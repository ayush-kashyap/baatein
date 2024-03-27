import 'package:baatein/MessageInterface.dart';
import 'package:baatein/getChatSpaceModule.dart';
import 'package:baatein/module/ChatSpace.dart';
import 'package:baatein/module/UserModule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
class Search extends StatefulWidget {
  final UserModule usrM;
  final User usr;

  const Search({Key? key,required this.usrM,required this.usr}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {

  
  TextEditingController searchTxt =TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          centerTitle: true,
          title: const Text("Search",style: TextStyle(color: Colors.black),),
        ),
        body: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 30),
          child: Column(
            children: [
              TextFormField(
                controller: searchTxt,
                decoration: const InputDecoration(hintText: "Enter email to search"),
              ),
              const SizedBox(height: 25,),
              CupertinoButton(child: const Text("Search",style: TextStyle(fontSize: 20),), onPressed: (){setState(() {
              
              });},
              color: HexColor("#4169e9"),),
              const SizedBox(height: 25,),
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection("users").doc("public").collection("usernames").where("email",isEqualTo: searchTxt.text).where("email",isNotEqualTo: FirebaseAuth.instance.currentUser!.email).snapshots(),
                builder: (context, snapshot) {
                  if(snapshot.connectionState==ConnectionState.active){
                    if(snapshot.hasData){
                      QuerySnapshot qurySnap=snapshot.data as QuerySnapshot;
                      if(qurySnap.docs.isNotEmpty){
                        Map<String,dynamic> usrMap=qurySnap.docs[0].data() as Map<String,dynamic>;
                        UserModule searchedUser = UserModule.fromMap(usrMap);
                        return ListTile(
                          onTap: () async{
                            ChatSpace? chatSpace= await GetChatSpaceModule.getChatSpace(searchedUser,widget.usrM);
                            if(chatSpace!=null){
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>MessageInterface(chatSpace: chatSpace, userModule: widget.usrM, targetUser: searchedUser, usr: widget.usr)));
                            }
                            
                          },
                          leading: CircleAvatar(backgroundColor: Colors.grey,
                          backgroundImage: NetworkImage(searchedUser.profilepic!),
                          ),
                          title: Text(searchedUser.fullname!),
                          subtitle: Text(searchedUser.email!),
                        );
                      }else{
                      return const Text("No user found");
                      }

                    }else if(snapshot.hasError){
                      return const Text("No user found");
                    }else{
                      return const Text("No user found");
                    }
                  }else{
                    return Center(
          child: CircularProgressIndicator(
            color: HexColor("#4169e9"),
          ),
        );
                  }
              })
            ],
          ),
        ),
      ),
    );
  }
}