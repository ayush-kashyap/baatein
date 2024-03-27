import 'dart:io';
import 'package:baatein/Functions/GetNotifications.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:baatein/Functions/BlockUser.dart';
import 'package:baatein/getUnseenCount.dart';
import 'package:baatein/main.dart';
import 'package:baatein/module/ChatSpace.dart';
import 'package:baatein/module/Chats.dart';
import 'package:baatein/module/SMSModule.dart';
import 'package:baatein/module/UserModule.dart';
import 'package:baatein/module/blockModule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'GetSeenCount.dart';
import 'package:hexcolor/hexcolor.dart';
import 'SeenMessage.dart';
import 'package:photo_view/photo_view.dart';

class MessageInterface extends StatefulWidget {
  final ChatSpace chatSpace;
  final UserModule userModule;
  final UserModule targetUser;
  final User usr;
  final Chats? chats;

  const MessageInterface(
      {Key? key,
      this.chats,
      required this.chatSpace,
      required this.userModule,
      required this.targetUser,
      required this.usr})
      : super(key: key);

  @override
  State<MessageInterface> createState() => _MessageInterfaceState();
}

class _MessageInterfaceState extends State<MessageInterface> {
  var last = "";
  bool blockState = false;
  TextEditingController msgSend = TextEditingController();

  void sendText(msg, imagepath) async {
    msg == "" ? last = "📷image" : last = msg;
    Chats newChat;
    Chats newTChat;
    SMSModule newMsgM = SMSModule(
      messageid: uuid.v1(),
      msg: msg,
      seen: false,
      sender: widget.userModule.uid,
      image: imagepath,
      deletedfor: "",
      time: DateTime.now().toString(),
    );
    FirebaseFirestore.instance
        .collection("chatspaces")
        .doc(widget.chatSpace.chatId)
        .collection("messages")
        .doc(newMsgM.messageid)
        .set(newMsgM.toMap());
    ChatSpace newChatspace = ChatSpace(
        chatId: widget.chatSpace.chatId,
        per1: widget.chatSpace.per1,
        per2: widget.chatSpace.per2,
        lastmsg: last,
        blockBy: "",
        status: widget.chatSpace.status);
    FirebaseFirestore.instance
        .collection("chatspaces")
        .doc(widget.chatSpace.chatId)
        .set(newChatspace.toMap());
    if (widget.chats == null) {
      var count;
      var Tcount;
      if (widget.chatSpace.per1 == widget.userModule.uid) {
        count = await GetUnseenCount.getUnseenCount(
            widget.chatSpace.chatId, widget.chatSpace.per1);
        Tcount = await GetUnseenCount.getUnseenCount(
            widget.chatSpace.chatId, widget.chatSpace.per2);
      } else {
        count = await GetUnseenCount.getUnseenCount(
            widget.chatSpace.chatId, widget.chatSpace.per2);
        Tcount = await GetUnseenCount.getUnseenCount(
            widget.chatSpace.chatId, widget.chatSpace.per1);
      }
      var ch = await FirebaseFirestore.instance
          .collection("chats")
          .doc("users")
          .collection(widget.userModule.email!)
          .doc(widget.chatSpace.chatId)
          .get();
      Chats neChat = Chats.fromMap(ch.data() as Map<String, dynamic>);
      newChat = Chats(
        chatId: neChat.chatId,
        lastMsg: last,
        lastMsgDate: DateTime.now().toString(),
        unseenCount: int.parse(Tcount.toString()),
        pfp: neChat.pfp,
        nameChat: neChat.nameChat,
        emailtarget: neChat.emailtarget,
      );
      newTChat = Chats(
        chatId: neChat.chatId,
        lastMsg: last,
        lastMsgDate: DateTime.now().toString(),
        pfp: widget.userModule.profilepic,
        unseenCount: int.parse(count.toString()),
        nameChat: widget.userModule.fullname,
        emailtarget: widget.userModule.email,
      );
    } else {
      newChat = Chats(
        chatId: widget.chats!.chatId,
        lastMsg: last,
        lastMsgDate: DateTime.now().toString(),
        unseenCount: 0,
        pfp: widget.chats!.pfp,
        nameChat: widget.chats!.nameChat,
        emailtarget: widget.chats!.emailtarget,
      );
      newTChat = Chats(
        chatId: widget.chats!.chatId,
        lastMsg: last,
        lastMsgDate: DateTime.now().toString(),
        unseenCount: 0,
        pfp: widget.userModule.profilepic,
        nameChat: widget.userModule.fullname,
        emailtarget: widget.userModule.email,
      );
    }

    FirebaseFirestore.instance
        .collection("chats")
        .doc("users")
        .collection(widget.userModule.email!)
        .doc(widget.chatSpace.chatId)
        .set(newChat.toMap());
    FirebaseFirestore.instance
        .collection("chats")
        .doc("users")
        .collection(widget.targetUser.email!)
        .doc(widget.chatSpace.chatId)
        .set(newTChat.toMap());
    GetNotifications().sendNotification(widget.userModule.fullname, last,
        widget.targetUser.deviceToken, widget.userModule.profilepic);
  }

  void sendMsg() async {
    String msg = msgSend.text.trim();
    msgSend.clear();
    if (widget.chatSpace.status == false) {
      if (msg != "") {
        sendText(msg, "");
      }
    }
  }

  void deleteMsg(msg) {
    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: (msg.msg.toString() != "")
                ? Text(msg.msg.toString())
                : Text("Image"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      var deletedMsg = SMSModule(
                          msg: msg.msg,
                          messageid: msg.messageid,
                          seen: msg.seen,
                          sender: msg.sender,
                          image: msg.image,
                          deletedfor: widget.userModule.uid,
                          time: msg.time);
                      await FirebaseFirestore.instance
                          .collection("chatspaces")
                          .doc(widget.chatSpace.chatId)
                          .collection("messages")
                          .doc(msg.messageid)
                          .set(deletedMsg.toMap());
                    },
                    child: Text(
                      "Delete for me",
                      style: TextStyle(color: HexColor("#4169e9")),
                    )),
                (widget.userModule.uid == msg.sender)
                    ? TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await FirebaseFirestore.instance
                              .collection("chatspaces")
                              .doc(widget.chatSpace.chatId)
                              .collection("messages")
                              .doc(msg.messageid)
                              .delete();
                        },
                        child: Text(
                          "Delete for everyone",
                          style: TextStyle(color: HexColor("#4169e9")),
                        ))
                    : Container(),
              ],
            ),
          );
        });
  }

  bool menuOpen = false;
  OverlayEntry? ovrlentry;
  void showMenu(BuildContext context) {
    ovrlentry = OverlayEntry(
      builder: (context) {
        return Positioned(
            top: 80.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.only(bottomLeft: Radius.circular(20)),
                color: HexColor("#4169e9"),
              ),
              padding: EdgeInsets.only(right: 10, left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  (widget.chatSpace.status!)
                      ? (widget.chatSpace.blockBy == widget.userModule.uid)
                          ? TextButton(
                              onPressed: () {
                                BlockUser.unblockUser(
                                    widget.chatSpace, widget.userModule);
                                menuOpen = false;
                                ovrlentry!.remove();
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Unblock",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          : TextButton(
                              onPressed: () {},
                              child: Text(
                                "Action unavailable",
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                      : TextButton(
                          onPressed: () {
                            BlockUser.blockUser(widget.chatSpace,
                                widget.userModule, widget.targetUser);
                            menuOpen = false;
                            ovrlentry!.remove();
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Block",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                  TextButton(
                      onPressed: () {
                        removeMenu();
                      },
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        color: Colors.white,
                      )),
                ],
              ),
            ));
      },
    );
    Overlay.of(context)!.insert(ovrlentry!);
  }

  void sendImage(XFile imageFile) async {
    var msg = msgSend.text;
    msgSend.clear();
    var id = uuid.v1();
    File newImg = File(imageFile.path);
    UploadTask upltsk = FirebaseStorage.instance
        .ref("Chats")
        .child(widget.chatSpace.chatId.toString())
        .child(id)
        .putFile(newImg);

    TaskSnapshot snp = await upltsk;
    String imgurl = await snp.ref.getDownloadURL();

    sendText(msg, imgurl);
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void selectImage(ImageSource source) async {
    XFile? imageSelected = await ImagePicker().pickImage(source: source);
    if (imageSelected != null) {
      showDialog(
          context: context,
          builder: (context) {
            return SafeArea(
                child: Scaffold(
              appBar: AppBar(
                title: Text("Send to " + widget.targetUser.fullname!),
                backgroundColor: Colors.black,
              ),
              body: Container(
                child: Column(
                  children: [
                    Expanded(
                      child: PhotoView(
                        imageProvider:
                            Image.file(File(imageSelected.path)).image,
                        maxScale: PhotoViewComputedScale.covered,
                        minScale: PhotoViewComputedScale.contained,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 15),
                      child: Row(
                        children: [
                          Flexible(
                            child: TextFormField(
                              readOnly: blockState,
                              controller: msgSend,
                              decoration: const InputDecoration(
                                hintText: "Enter message",
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          color: HexColor("#4169e9"),
                                        ),
                                      );
                                    });
                                sendImage(imageSelected);
                              },
                              icon: Icon(
                                Icons.send,
                                color: HexColor("#4169e9"),
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
          });
    }
  }

  void removeMenu() {
    menuOpen = false;
    ovrlentry!.remove();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: HexColor("#4169e9"),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 2,
          title: TextButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => showDrawer(
                          targetUser: widget.targetUser,
                          chatSpace: widget.chatSpace,
                          currUser: widget.userModule)));
            },
            style: const ButtonStyle(
                tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            child: Row(children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.targetUser.profilepic!),
                backgroundColor: Colors.grey,
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                widget.targetUser.fullname!,
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ]),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  if (menuOpen) {
                    menuOpen = false;
                    ovrlentry!.remove();
                  } else {
                    menuOpen = true;
                    showMenu(context);
                  }
                },
                icon: Icon(Icons.more_vert))
          ],
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("chatspaces")
                        .doc(widget.chatSpace.chatId)
                        .collection("messages")
                        .orderBy("time", descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          QuerySnapshot docSnap =
                              snapshot.data as QuerySnapshot;

                          return ListView.builder(
                            reverse: true,
                            itemCount: docSnap.docs.length,
                            itemBuilder: (context, index) {
                              SMSModule currentMsg = SMSModule.fromMap(
                                  docSnap.docs[index].data()
                                      as Map<String, dynamic>);

                              SeenMessage.hasSeenMessage(
                                  currentMsg.messageid,
                                  widget.targetUser.uid,
                                  widget.chatSpace.chatId);
                              GetSeenCount.getSeenCount(
                                  widget.userModule.proType,
                                  widget.userModule.email,
                                  widget.chatSpace.chatId,
                                  widget.targetUser.uid);
                              if ((widget.userModule.uid) !=
                                  currentMsg.deletedfor) {
                                return ListTile(
                                  onLongPress: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: (currentMsg.msg.toString() !=
                                                    "")
                                                ? Text(
                                                    currentMsg.msg.toString(),
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  )
                                                : Text("Image"),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                TextButton(
                                                    onPressed: () {
                                                      deleteMsg(currentMsg);
                                                    },
                                                    child: Text(
                                                      "Delete",
                                                      style: TextStyle(
                                                        color:
                                                            HexColor("#4169e9"),
                                                      ),
                                                    )),
                                                TextButton(
                                                    onPressed: () {},
                                                    child: Text(
                                                      "View info",
                                                      style: TextStyle(
                                                        color:
                                                            HexColor("#4169e9"),
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          );
                                        });
                                  },
                                  title: Row(
                                    mainAxisAlignment: (currentMsg.sender ==
                                            widget.userModule.uid)
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: (currentMsg.sender ==
                                                  widget.userModule.uid)
                                              ? HexColor("#4169e9")
                                              : HexColor("#aabfff"),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 15),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            ((currentMsg.image.toString()) !=
                                                    "")
                                                ? CupertinoButton(
                                                    padding: EdgeInsets.all(2),
                                                    onPressed: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return SafeArea(
                                                              child: Scaffold(
                                                                appBar: AppBar(
                                                                  title: Text((currentMsg
                                                                              .sender ==
                                                                          widget
                                                                              .userModule
                                                                              .uid)
                                                                      ? "You"
                                                                      : widget
                                                                          .targetUser
                                                                          .fullname!),
                                                                  backgroundColor:
                                                                      Colors
                                                                          .black,
                                                                ),
                                                                body: PhotoView(
                                                                  imageProvider:
                                                                      NetworkImage(
                                                                          currentMsg
                                                                              .image!),
                                                                  maxScale:
                                                                      PhotoViewComputedScale
                                                                          .covered,
                                                                  minScale:
                                                                      PhotoViewComputedScale
                                                                          .contained,
                                                                ),
                                                              ),
                                                            );
                                                          });
                                                    },
                                                    child: Container(
                                                      height: 180,
                                                      width: 180,
                                                      child: Image.network(
                                                        currentMsg.image
                                                            .toString(),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  currentMsg.msg.toString(),
                                                  softWrap: true,
                                                  maxLines: 3,
                                                  style: TextStyle(
                                                      color: (currentMsg
                                                                  .sender ==
                                                              widget.userModule
                                                                  .uid)
                                                          ? Colors.white
                                                          : Colors.black,
                                                      fontSize: 15),
                                                ),
                                                (currentMsg.sender ==
                                                        widget.userModule.uid)
                                                    ? Icon(
                                                        Icons.check,
                                                        size: 15,
                                                        color:
                                                            (currentMsg.seen!)
                                                                ? Colors.green
                                                                : HexColor(
                                                                    "#aabfff"),
                                                      )
                                                    : const Icon(
                                                        Icons.check,
                                                        size: 0,
                                                      ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            },
                          );
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Text("Error occured! please restart app"),
                          );
                        } else {
                          return const Center(
                            child: Text("Say Hii!!"),
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
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                child: (widget.chatSpace.status!)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("You can't reply to this conversation"),
                        ],
                      )
                    : Row(
                        children: [
                          Flexible(
                            child: TextFormField(
                              readOnly: blockState,
                              controller: msgSend,
                              decoration: InputDecoration(
                                hintText: "Enter message",
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                suffixIcon: IconButton(
                                    padding: const EdgeInsets.only(right: 20),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ListTile(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        selectImage(ImageSource
                                                            .gallery);
                                                      },
                                                      leading:
                                                          Icon(Icons.image),
                                                      title: Text(
                                                        "Pick image from gallery",
                                                        style: TextStyle(
                                                            color: HexColor(
                                                                "#4169e9")),
                                                      )),
                                                  ListTile(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                        selectImage(
                                                            ImageSource.camera);
                                                      },
                                                      leading: Icon(Icons
                                                          .camera_alt_rounded),
                                                      title: Text(
                                                        "Take a photo",
                                                        style: TextStyle(
                                                            color: HexColor(
                                                                "#4169e9")),
                                                      )),
                                                ],
                                              ),
                                            );
                                          });
                                    },
                                    icon: const Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                    )),
                              ),
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                sendMsg();
                              },
                              icon: Icon(
                                Icons.send,
                                color: HexColor("#4169e9"),
                              )),
                        ],
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class showDrawer extends StatefulWidget {
  final UserModule targetUser;
  final UserModule currUser;
  final ChatSpace chatSpace;

  const showDrawer(
      {Key? key,
      required this.targetUser,
      required this.currUser,
      required this.chatSpace})
      : super(key: key);

  @override
  State<showDrawer> createState() => _showDrawerState();
}

class _showDrawerState extends State<showDrawer> {
  TextEditingController fName = TextEditingController();
  TextEditingController emailP = TextEditingController();
  TextEditingController gender = TextEditingController();
  void initState() {
    fName.text = widget.targetUser.fullname!;
    emailP.text = widget.targetUser.email!;
    gender.text = widget.targetUser.gender!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: HexColor("#4169e9"),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 2,
          title: Text("Contact Details"),
        ),
        body: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(50),
          child: Center(
            child: SingleChildScrollView(
              child: Column(children: [
                CupertinoButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Scaffold(
                              appBar: AppBar(
                                backgroundColor: HexColor("#000"),
                                iconTheme:
                                    const IconThemeData(color: Colors.white),
                                elevation: 2,
                                title: Text(widget.targetUser.fullname!),
                              ),
                              body: PhotoView(
                                  maxScale: PhotoViewComputedScale.covered * 1,
                                  minScale:
                                      PhotoViewComputedScale.contained * 1,
                                  imageProvider: NetworkImage(
                                      widget.targetUser.profilepic!)));
                        });
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 65,
                    backgroundImage:
                        NetworkImage(widget.targetUser.profilepic!),
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                TextFormField(
                  controller: fName,
                  readOnly: true,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                const SizedBox(
                  height: 25,
                ),
                TextFormField(
                  controller: emailP,
                  readOnly: true,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                const SizedBox(
                  height: 25,
                ),
                TextFormField(
                  controller: gender,
                  readOnly: true,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(labelText: "Gender"),
                ),
              ]),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 0,
          child: (widget.chatSpace.status!)
              ? (widget.chatSpace.blockBy == widget.currUser.uid)
                  ? TextButton(
                      onPressed: () {
                        BlockUser.unblockUser(
                            widget.chatSpace, widget.currUser);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Unblock ",
                            style: TextStyle(color: Colors.green, fontSize: 18),
                          ),
                          Icon(
                            Icons.block,
                            color: Colors.green,
                          ),
                          SizedBox(width: 10),
                          Text(
                            widget.targetUser.fullname!,
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          )
                        ],
                      ),
                    )
                  : null
              : TextButton(
                  onPressed: () {
                    BlockUser.blockUser(
                        widget.chatSpace, widget.currUser, widget.targetUser);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Block ",
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      ),
                      Icon(
                        Icons.block,
                        color: Colors.red,
                      ),
                      SizedBox(width: 10),
                      Text(
                        widget.targetUser.fullname!,
                        style: TextStyle(color: Colors.black, fontSize: 18),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
