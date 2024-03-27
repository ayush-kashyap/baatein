import 'package:baatein/BlockedUsers.dart';
import 'package:baatein/Functions/GetNotifications.dart';
import 'package:baatein/GetUser.dart';
import 'package:baatein/MessageInterface.dart';
import 'package:baatein/Profile.dart';
import 'package:baatein/Search.dart';
import 'package:baatein/getChatSpaceModule.dart';
import 'package:baatein/module/Chats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baatein/module/UserModule.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'login.dart';

class MainScreen extends StatefulWidget {
  final UserModule userMdl;
  final User usr;
  @override
  const MainScreen({Key? key, required this.userMdl, required this.usr})
      : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // @override
  // void initState() {
  //   callV();
  //   super.initState();

  // }
  // FileImage? img;
  // void callV() async{
  //   img= FileImage(File(widget.pf));

  // }

  // GetNotifications notifier =GetNotifications();
  @override
  void initState() {
    super.initState();
    // notifier.getNotifications();
  }

  var target;
  var chatSpace;

  void logoutt() async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(
              color: HexColor("#4169e9"),
            ),
          );
        });
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const loginPage()));
  }
  

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Image.asset("assets/headlogo.png"),
              backgroundColor: HexColor("#4169e9"),
              toolbarHeight: 75,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              )),
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Search(
                          usrM: widget.userMdl,
                          usr: widget.usr,
                        );
                      }));
                    },
                    icon: const Icon(
                      Icons.search,
                    )),
                const SizedBox(
                  width: 15,
                )
              ],
            ),
            drawer: Drawer(
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      
                      child:
                          ListView(padding: const EdgeInsets.all(0), children: [
                        DrawerHeader(
                          decoration: BoxDecoration(
                            color: HexColor("#4169e9"),
                          ),
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            CircleAvatar(
                              radius: 45,
                              backgroundImage:
                                  NetworkImage(widget.userMdl.profilepic!),
                            ),
                            Text(
                              widget.userMdl.fullname!,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            Text(
                              widget.userMdl.email!,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            )
                          ]),
                        ),
                        ListTile(
                          leading: Icon(Icons.person),
                          title: Text(
                            "View Profile",
                            style: TextStyle(fontSize: 16),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Profile(
                                        userPm: widget.userMdl,
                                        userCred: widget.usr)));
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.share),
                          title: Text(
                            "Share this app",
                            style: TextStyle(fontSize: 16),
                          ),
                          onTap: () {
                            showDialog(context: context, builder: (context){
                              return AlertDialog(
                                title: Text("Scan QR code to download"),
                                content: Image.asset("assets/qrcode.png"),
                              );
                            });
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.block),
                          title: Text(
                            "Blocked users",
                            style: TextStyle(fontSize: 16),
                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>BlockedUsers(currUser: widget.userMdl)));
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.code),
                          title: const Text(
                            "About developer",
                            style: TextStyle(fontSize: 16),
                          ),
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    insetPadding: EdgeInsets.all(10),
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const[
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              "https://firebasestorage.googleapis.com/v0/b/baatein-f1db4.appspot.com/o/PFPs%2F97QOGAa4IfNgKrzaJ28eM90Vo7n2?alt=media&token=f609c7e1-2836-45ef-8f25-4d3ba8cc048f"),
                                          radius: 45,
                                        ),
                                      ],
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        
                                        Row(
                                          children: const[
                                            Icon(Icons.person),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "Ayush Kashyap",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  decoration:
                                                      TextDecoration.none),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: const [
                                            Icon(Icons.phone),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "+91 7850890531",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  decoration:
                                                      TextDecoration.none),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: const [
                                            Icon(Icons.mail),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "ayushkashyap0507@gmail.com",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  decoration:
                                                      TextDecoration.none),
                                            )
                                          ],
                                        ),
                                        
                                      ],
                                    ),
                                  );
                                });
                          },
                        ),
                        
                        
                      ]),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      logoutt();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "LogOut ",
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                        Icon(
                          Icons.logout,
                          color: HexColor("#4169e9"),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  )
                ],
              ),
            ),
            body: Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20
                ),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection("chats").doc("users").collection(widget.userMdl.email!)
                        .orderBy("lastMsgDate", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          QuerySnapshot docSnap =
                              snapshot.data as QuerySnapshot;
                          if (docSnap.docs.isNotEmpty) {
                            return ListView.builder(
                              itemCount: docSnap.docs.length,
                              itemBuilder: (context, index) {
                                Chats currentChat = Chats.fromMap(
                                    docSnap.docs[index].data()
                                        as Map<String, dynamic>);

                                return ListTile(
                                  
                                    onTap: () async {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Center(
                                              child: CircularProgressIndicator(
                                                color: HexColor("#4169e9"),
                                              ),
                                            );
                                          });
                                      target = await GetUser.getUserByEmail(
                                          currentChat.emailtarget!);
                                      chatSpace =
                                          await GetChatSpaceModule.getChatSpace(
                                              target, widget.userMdl);
                                      Navigator.pop(context);
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return MessageInterface(
                                            chatSpace: chatSpace,
                                            userModule: widget.userMdl,
                                            targetUser: target,
                                            usr: widget.usr);
                                      }));
                                    },
                                    leading: CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(currentChat.pfp!)),
                                    title: Text(currentChat.nameChat!),
                                    subtitle: Text(currentChat.lastMsg!,
                                        style: TextStyle(
                                            color:
                                                (currentChat.unseenCount == 0)
                                                    ? Colors.grey
                                                    : HexColor("#4169e9"),
                                            fontWeight:
                                                (currentChat.unseenCount == 0)
                                                    ? FontWeight.normal
                                                    : FontWeight.bold)),
                                    trailing: CircleAvatar(
                                      backgroundColor:
                                          (currentChat.unseenCount != 0)
                                              ? HexColor("#4169e9")
                                              : Colors.white,
                                      radius: 10,
                                      child: (currentChat.unseenCount != 0)
                                          ? Text(
                                              currentChat.unseenCount
                                                  .toString(),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : const Text(""),
                                    ));
                              },
                            );
                          } else {
                            return const Center(
                              child: Text("Start a new Chat"),
                            );
                          }
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Text("Error occured"),
                          );
                        } else {
                          return const Center(
                            child: Text("Start a new Chat"),
                          );
                        }
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            color: HexColor("#4169e9"),
                            
                          ),
                        );
                      }
                    },
                  ))
                ],
              ),
            ),
            floatingActionButton: CircleAvatar(
              backgroundColor: HexColor("#4169e9"),
              radius: 25,
              child: IconButton(onPressed: (){Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Search(
                          usrM: widget.userMdl,
                          usr: widget.usr,
                        );
                      }));}, icon: Icon(Icons.message_outlined),
                      color: HexColor("#ffffff"),
                      ),
            ),
          ),
        ));
  }
}
