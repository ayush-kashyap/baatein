import 'dart:io';

import 'package:baatein/MainScreen.dart';
import 'package:baatein/module/Chats.dart';
import 'package:baatein/module/UserModule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'login.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';


class Profile extends StatefulWidget {
  final UserModule userPm;
  final User userCred;

  const Profile({Key? key,required this.userPm,required this.userCred}) : super(key: key);


  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController fName =TextEditingController();
  TextEditingController emailP =TextEditingController();
  TextEditingController gender =TextEditingController();
  TextEditingController editEmail =TextEditingController();
  TextEditingController editcEmail =TextEditingController();
  TextEditingController newPass =TextEditingController();
  TextEditingController newCPass =TextEditingController();
  bool jaisaKaho=true;

  @override
  void initState() {
    fName.text=widget.userPm.fullname!;
    emailP.text=widget.userPm.email!;
    gender.text=widget.userPm.gender!;
    super.initState();
    
  }

  void logoutt()async{
    showDialog(context: context, builder: (context){
        return Center(
          child: CircularProgressIndicator(
            color: HexColor("#4169e9"),
          ),
        );
      });
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const loginPage()));
  }

  void editProfile(){
    showDialog(context: context, builder: (context){
      return AlertDialog(content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            onTap: (){Navigator.pop(context); changeEmail();},
            title: const Text("Change email"),
          ),
          ListTile(
            onTap: (){Navigator.pop(context); changePass();},
            title: const Text("Change password"),
          ),
          ListTile(
            onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context){return updProfile(userUp: widget.userPm);}));},
            title: const Text("Change profile details"),
          )
        ],
      ),);
    });
  }
  void checkValues(){
    String ediEmail=editEmail.text.trim();
    String edicEmail=editcEmail.text.trim();
    if(ediEmail==""||edicEmail==""){
      showDialog(context: context, builder: (context){
        return const AlertDialog(
          content: Text("Fill all fields"),
        );
      });
    }else if(ediEmail!=edicEmail){
      showDialog(context: context, builder: (context){
        return const AlertDialog(
          content: Text("Email and confirm email do not match"),
        );
      });
    }else{
      showDialog(context: context, builder: (context){
        return Center(
          child: CircularProgressIndicator(
            color: HexColor("#4169e9"),
          ),
        );
      });
      updEmail(ediEmail);
    }
  }
  void updEmail(String newEmail) async{
    bool updated=false;
  try{
    await widget.userCred.updateEmail(newEmail);
    updated=true;
  }on FirebaseAuthException catch(ex){
    Navigator.pop(context);
    showDialog(context: context, builder: (context){
      return AlertDialog(
        content: Text(ex.code.toString()),
      );
    });
  }
    if(updated){
      UserModule newUserM=UserModule(
      email: newEmail,
      uid:widget.userPm.uid,
      fullname: widget.userPm.fullname,
      gender: widget.userPm.gender,
      profilepic: widget.userPm.profilepic,
      proType: widget.userPm.proType,
      deviceToken: widget.userPm.deviceToken
    );
    final chats = await FirebaseFirestore.instance.collection('chats').doc('users').collection(widget.userPm.email!).get();
    if(chats.docs.length>0){
      for (var i = 0; i < chats.docs.length; i++) {
        final chatsModel=Chats.fromMap(chats.docs[i].data());
        
        final targetchat= await FirebaseFirestore.instance.collection('chats').doc('users').collection(chatsModel.emailtarget!).doc(chatsModel.chatId).get();
         final targetChatModel= Chats.fromMap(targetchat.data() as Map<String,dynamic>);
         targetChatModel.emailtarget=newEmail;

        FirebaseFirestore.instance.collection('chats').doc('users').collection(chatsModel.emailtarget!).doc(chatsModel.chatId).set(targetChatModel.toMap());
        FirebaseFirestore.instance.collection('chats').doc('users').collection(newEmail).doc(chatsModel.chatId).set(chatsModel.toMap());
        FirebaseFirestore.instance.collection('chats').doc('users').collection(widget.userPm.email!).doc(chatsModel.chatId).delete();

      }
    }
    await FirebaseFirestore.instance.collection("users").doc(widget.userPm.proType).collection("usernames").doc(newEmail).set(newUserM.toMap()).then((value) {Navigator.pop(context); 
    Navigator.push(context, MaterialPageRoute(builder: (context)=> MainScreen(userMdl: newUserM, usr: widget.userCred)
    ));
    });
    await FirebaseFirestore.instance.collection("users").doc(widget.userPm.proType).collection("usernames").doc(widget.userPm.email).delete();
    }
}

  void changeEmail(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: editEmail,
              decoration: const InputDecoration(
                hintText: "Enter new email"
              ),
            ),
            const SizedBox(height: 30,),
            TextFormField(
              controller: editcEmail,
              decoration: const InputDecoration(
                hintText: "Enter confirm email"
              ),
            ),
            const SizedBox(height: 30,),
            CupertinoButton(child: const Text("Save",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,letterSpacing: 1.2),),
                  color: HexColor("#4169e9"),
                  borderRadius: BorderRadius.circular(30),

                  onPressed: () {
                    Navigator.pop(context);
                    checkValues();
                  })
          ],
        ),
      );
    });
  }
  void changePass(){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: newPass,
              decoration: const InputDecoration(
                hintText: "Enter new pass"
              ),
            ),
            const SizedBox(height: 30,),
            TextFormField(
              controller: newCPass,
              decoration: const InputDecoration(
                hintText: "Enter confirm pass"
              ),
            ),
            const SizedBox(height: 30,),
            CupertinoButton(child: const Text("Save",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,letterSpacing: 1.2),),
                  color: HexColor("#4169e9"),
                  borderRadius: BorderRadius.circular(30),

                  onPressed: () {
                    Navigator.pop(context);
                    updPass();
                  })
          ],
        ),
      );
    });
  }
  void updPass() async{
    String newP = newPass.text.trim();
    String newC = newCPass.text.trim();
    if(newP==""||newC==""){
      showDialog(context: context, builder: (context){
        return const AlertDialog(
          content: Text("Fill all fields"),
        );
      });
    }else if(newP!=newC)
      {showDialog(context: context, builder: (context){
        return const AlertDialog(
          content: Text("Fill all fields"),
        );
      });}
      else{
        showDialog(context: context, builder: (context){
        return Center(
          child: CircularProgressIndicator(
            color: HexColor("#4169e9"),
          ),
        );
      });
        await widget.userCred.updatePassword(newP).then((value) {
          Navigator.pop(context);
        });
      }
  }



  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text("Profile",style: TextStyle(color: Colors.black,fontSize: 20),),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
          actions: [
            IconButton(onPressed: (){editProfile();}, icon: const Icon(Icons.edit))

          ],
        ),
        body: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(50),
          child: Center(
            
            child: SingleChildScrollView(
              child: Column(
                
                children: [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                    radius: 65,
                    backgroundImage: NetworkImage(widget.userPm.profilepic!),
                  ),
                  const SizedBox(
                      height: 25,
                    ),
                    
                    TextFormField(
                      
                      controller: fName,
                      readOnly: jaisaKaho,
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
                      readOnly: jaisaKaho,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(labelText: "Gender"),
                      
                    ),
              ]),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 0,
          child: TextButton(onPressed: (){logoutt();}, child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [const Text("LogOut ",style: TextStyle(color: Colors.black,fontSize: 18),),Icon(Icons.logout,color: HexColor("#4169e9"),)],),),
          
        ),
      ),
    );
  }
}

class updProfile extends StatefulWidget {
  final UserModule userUp;

  const updProfile({Key? key,required this.userUp}) : super(key: key);

  @override
  State<updProfile> createState() => _updProfileState();
}

class _updProfileState extends State<updProfile> {

  TextEditingController fUpName =TextEditingController();
  bool jaisaKaho=false;
  String typeUser="";
  String gender="";
  var img;
  
  void saveDetails() async{
    String imgurl=widget.userUp.profilepic!;
    String newName=fUpName.text.trim();
    if(newName==""||gender==""){
      showDialog(context: context, builder: (context){
        return const AlertDialog(
          content: Text("Fill all fields"),
        );
      });
    }else{
      showDialog(context: context, builder: (context){
        return Center(
          child: CircularProgressIndicator(
            color: HexColor("#4169e9"),
          ),
        );
      });
      if(imageFile!=null){
        File newImg=File(imageFile!.path);
        
    UploadTask upltsk=FirebaseStorage.instance.ref("PFPs").child(widget.userUp.uid.toString()).putFile(newImg);

    TaskSnapshot snp=await upltsk;
    imgurl=await snp.ref.getDownloadURL();
      }
      UserModule newModule=UserModule(
        uid: widget.userUp.uid,
        email: widget.userUp.email,
        proType: typeUser,
        fullname: newName,
        profilepic: imgurl,
        gender: gender,
      );
      if(typeUser!=widget.userUp.proType){
        await FirebaseFirestore.instance.collection("users").doc(widget.userUp.proType).collection("usernames").doc(widget.userUp.email).delete();
      }
        await FirebaseFirestore.instance.collection("users").doc(typeUser).collection("usernames").doc(newModule.email).set(newModule.toMap()).then((value) {
          Navigator.push(context, MaterialPageRoute(builder: (context){
            return MainScreen(userMdl: newModule, usr: FirebaseAuth.instance.currentUser!);
          }));
        });
    }
  }
  CroppedFile? imageFile;
    @override
  void initState() {
    fUpName.text=widget.userUp.fullname!;
    gender=widget.userUp.gender!;
    typeUser=widget.userUp.proType!;
    img=NetworkImage(widget.userUp.profilepic!);
    super.initState();
    
  }

  void showOptions(){
  showDialog(context: context, builder: (context) {
    return AlertDialog(
      title: const Text("Select option"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            onTap: (){
              Navigator.pop(context);
              selectImage(ImageSource.gallery);
            },
            leading: const Icon(Icons.photo),
            title: const Text("Select from gallery"),
          ),
          ListTile(
            onTap: (){
              Navigator.pop(context);
              selectImage(ImageSource.camera);
              
            },
            leading: const Icon(Icons.camera_alt),
            title: const Text("Take a photo"),
          )
        ],
      ),
    );
  });
}
void selectImage(ImageSource source) async{
  XFile? imageSelected = await ImagePicker().pickImage(source: source);
  if(imageSelected!=null){
    cropImage(imageSelected);
  }
}

void cropImage(XFile imageSelected) async{
  CroppedFile? croppedImg = await ImageCropper().cropImage(
    sourcePath: imageSelected.path,
    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    compressQuality: 20,
  );
  if(croppedImg!=null){
    setState(() {
      imageFile=croppedImg;
      img=FileImage(File(imageFile!.path));

    });
  }

}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text("Profile",style: TextStyle(color: Colors.black,fontSize: 20),),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          elevation: 0,
          
        ),
        body: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(50),
          child: Center(
            
            child: SingleChildScrollView(
              child: Column(
                
                children: [
                CupertinoButton(
                  child: CircleAvatar(
                    backgroundColor: Colors.grey,
                      radius: 65,
                      backgroundImage: img,
                    ),
                    onPressed: (){showOptions();},
                ),
                  const SizedBox(
                      height: 25,
                    ),
                    
                    TextFormField(
                      
                      controller: fUpName,
                      readOnly: jaisaKaho,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(labelText: "Name"),
                    ),
                  
                  const SizedBox(
                      height: 25,
                    ),
                    Row(
                      children: [
                        Radio(value: "male", groupValue: gender, onChanged: (value){
                          setState(() {
                            gender=value.toString();
                          });
                        }),
                        const Text("Male"),
                        Radio(value: "female", groupValue: gender, onChanged: (value){
                          setState(() {
                            gender=value.toString();
                          });
                        }),
                        const Text("Female"),
                      ],
                    ),
                    Row(
                      children: [
                        Radio(value: "public", groupValue: typeUser, onChanged: (value){
                          setState(() {
                            typeUser=value.toString();
                          });
                        }),
                        const Text("public"),
                        Radio(value: "private", groupValue: typeUser, onChanged: (value){
                          setState(() {
                            typeUser=value.toString();
                          });
                        }),
                        const Text("private"),
                      ],
                    ),
              ]),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 0,
          child: TextButton(onPressed: (){saveDetails();}, child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [Text("Save",style: TextStyle(color: Colors.black,fontSize: 18),)],),),
          
        ),
      ),
    );
  }
}