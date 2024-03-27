import 'dart:io';

import 'package:baatein/Functions/GetNotifications.dart';
import 'package:baatein/MainScreen.dart';
import 'package:baatein/module/UserModule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController signupemail=TextEditingController();
  TextEditingController signuppass=TextEditingController();
  TextEditingController signupcpass=TextEditingController();
    bool? isChecked=false;

  void checkValues(){
    String email=signupemail.text.trim();
    String pass=signuppass.text.trim();
    String cpass=signupcpass.text.trim();
    if(email=="" || pass=="" || cpass=="" ){
      showDialog(context: context, builder: (context){
        return const AlertDialog(
          content: Text("Fill all fields"),
        );
      });
    }else if(pass!=cpass){
      showDialog(context: context, builder: (context){
        return const AlertDialog(
          content: Text("Password and confirm password does not match"),
        );
      });
    }
    else{
      if(pass.length<8){
        showDialog(context: context, builder: (context){
        return const AlertDialog(
          content: Text("Password must contain 8 letters"),
        );  
      });
      }
      else{
        showDialog(context: context, builder: (context){
        return Center(
          child: CircularProgressIndicator(
            color: HexColor("#4169e9"),
          ),
        );
      });
      signUp(email, pass);
      }
    }
  }

  void signUp(String email,String password) async{
    UserCredential? uCred;
    String typeP="public";
    try{
      uCred=await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch(exc){
      showDialog(context: context, builder: (context){
        return AlertDialog(
          content: Text(exc.code.toString()),
        );  
      });
    }
    if(isChecked==true){
      typeP="private";
    }
    if(uCred!=null){
      String uid=uCred.user!.uid;
      final devToken = await GetNotifications().getDeviceToken();
      UserModule nUserM=UserModule(
        uid:uid,
        email: email,
        fullname: "",
        gender: "",
        profilepic: "",
        deviceToken: devToken,
        proType: typeP
      );
      await FirebaseFirestore.instance.collection("users").doc(typeP).collection("usernames").doc(email).set(nUserM.toMap()).then((value) {print("New User Signed up");Navigator.push(context, MaterialPageRoute(builder: (context){return CompleteSignUp(userM: nUserM, fUser: uCred!.user!);}));});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
          elevation: 0,
          title: const Text(
            "SignUp",
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          height: double.infinity,
          width: double.infinity,
          color: Colors.white,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 25,
                  ),
                  TextFormField(
                    controller: signupemail,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(hintText: "Email"),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  TextFormField(
                    controller: signuppass,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: "Password",
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  TextFormField(
                    controller: signupcpass,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: "Re-enter Password",
                    ),
                  ),
                  
                  const SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Checkbox(value: isChecked,
                  
                  onChanged: (newBool){
                    setState(() {
                      isChecked=newBool;
                    });
                  }),
                  const Text("Private account"),
                    ],
                  ),
                  const SizedBox(
                    height: 25,
                  ),

                  CupertinoButton(child: const Text("SignUp",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,letterSpacing: 1.2),),
                  color: HexColor("#4169e9"),
                  borderRadius: BorderRadius.circular(30),

                  onPressed: () {checkValues();})
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class CompleteSignUp extends StatefulWidget {
  final UserModule userM;
  final User fUser;

  const CompleteSignUp({Key? key, required this.userM,required this.fUser}) : super(key: key);


  @override
  State<CompleteSignUp> createState() => _CompleteSignUpState();
}

class _CompleteSignUpState extends State<CompleteSignUp> {
  CroppedFile? imageFile;
  TextEditingController signupname=TextEditingController();
  TextEditingController signupDOB=TextEditingController();
  TextEditingController signupuname=TextEditingController();
String gender="male";
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

    });
  }

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



void checkValues(){
    String name=signupname.text.trim();
    if(name=="" || gender==""){
      showDialog(context: context, builder: (context){
        return const AlertDialog(
          content: Text("Fill all fields"),
        );
      });
    }
    else if(imageFile==null){
      showDialog(context: context, builder: (context){
        return const AlertDialog(
          content: Text("Attach profile pic by clicking on avatar"),
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
      uploadData(name,gender,imageFile);
    }
  }
  void uploadData(String name,String gender,CroppedFile? imageFile) async{
    File newImg=File(imageFile!.path);
    UploadTask upltsk=FirebaseStorage.instance.ref("PFPs").child(widget.userM.uid.toString()).putFile(newImg);

    TaskSnapshot snp=await upltsk;
    String imgurl=await snp.ref.getDownloadURL();

    widget.userM.fullname=name;
    widget.userM.profilepic=imgurl;
    widget.userM.gender=gender;
    await FirebaseFirestore.instance.collection("users").doc(widget.userM.proType).collection("usernames").doc(widget.userM.email).set(widget.userM.toMap()).then((value) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => MainScreen(userMdl: widget.userM, usr: widget.fUser)
      ));
    });
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{return false;},
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(
              color: Colors.black,
            ),
            elevation: 0,
            title: const Text(
              "SignUp",
              style: TextStyle(color: Colors.black),
            ),
            centerTitle: true,
          ),
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            height: double.infinity,
            width: double.infinity,
            color: Colors.white,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 25,
                    ),
                    CupertinoButton(child: Container(
                      decoration: BoxDecoration(border: Border.all(color: HexColor("#4169e9"),width: 3,),borderRadius: BorderRadius.circular(100)),
                      child: CircleAvatar(
                        radius: 75,
                        backgroundImage: (imageFile != null) ? FileImage(File(imageFile!.path)):null,
                        child: (imageFile==null)?Icon(Icons.person,size:75,color: HexColor("#4169e9"),):null,
                        backgroundColor: Colors.white,
                      ),
                    ), onPressed: (){showOptions();}),
                    const SizedBox(
                      height: 25,
                    ),
                    TextFormField(
                      controller: signupname,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(hintText: "Name"),
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
                    
                    const SizedBox(
                      height: 25,
                    ),
                    
                    const SizedBox(
                      height: 25,
                    ),
    
                    CupertinoButton(child: const Text("Save",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,letterSpacing: 1.2),),
                    color: HexColor("#4169e9"),
                    borderRadius: BorderRadius.circular(30),
    
                    onPressed: () {
                      checkValues();
                    })
                    
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}