import 'package:baatein/Functions/GetNotifications.dart';
import 'package:baatein/MainScreen.dart';
import 'package:baatein/main.dart';
import 'package:baatein/module/UserModule.dart';
import 'package:baatein/signUp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class loginPage extends StatefulWidget {
  const loginPage({Key? key}) : super(key: key);

  @override
  State<loginPage> createState() => _loginPageState();
}

class _loginPageState extends State<loginPage> {
  TextEditingController emailC=TextEditingController();
  TextEditingController passC=TextEditingController();
  String typeUser = "public";
  void checkValues(){
    
    
    String email=emailC.text.trim();
    String pass=passC.text.trim();
    if(email==""||pass==""){
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
      login(email,pass);

    }
  }

  void login(String email,String password) async{

    UserCredential? ucreds;

    try{
      ucreds=await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

    }on FirebaseAuthException catch(exc){
      Navigator.pop(context);
      showDialog(context: context, builder: (context){
        return AlertDialog(
          content: Text(exc.code.toString()),
        );  
      });
    }
    if(ucreds!=null){
      try{
        DocumentSnapshot userData=await FirebaseFirestore.instance.collection("users").doc(typeUser).collection("usernames").doc(email).get();
        if(userData.exists)
          {
            print(ucreds.user!.email);
            final devToken = await GetNotifications().getDeviceToken();
        UserModule userMo=UserModule.fromMap(userData.data() as Map<String,dynamic>);
        if (userMo.deviceToken!= devToken){
          userMo.deviceToken=devToken;
          await FirebaseFirestore.instance.collection("users").doc(typeUser).collection("usernames").doc(email).set(userMo.toMap());
        }
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
          return MainScreen(userMdl: userMo, usr: ucreds!.user!);
        }));
          
        }
        else{
          Navigator.pop(context);
          await FirebaseAuth.instance.signOut();
          showDialog(context: context, builder: (context){
        return const AlertDialog(
          content: Text("User does not exist"),
        );  
      });
        }
      } on FirebaseAuthException catch(exc){
      showDialog(context: context, builder: (context){
        return AlertDialog(
          content: Text(exc.code.toString()),
        );  
      });
      }
      
    }
  }

  bool pVisible = true;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{return false;},
      child: SafeArea(
        child: Scaffold(
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
                    image1,
                    const SizedBox(
                      height: 25,
                    ),
                    TextFormField(
                      controller: emailC,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(hintText: "Email"),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    TextFormField(
                      controller: passC,
                      obscureText: pVisible,
                      textAlign: TextAlign.center,
                      
                      decoration: InputDecoration(
                        
                        hintText: "Password",
                        suffixIcon: IconButton(
                                  padding: const EdgeInsets.only(right: 20),
                                  onPressed: () {
                                    setState(() {
                                      pVisible ? pVisible = false : pVisible = true;
                                    });
                                  },
                                  icon: const Icon(Icons.remove_red_eye_outlined),
                                ),
                      ),
                    ),
                    const SizedBox(height: 25,),
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
                    const SizedBox(
                      height: 25,
                    ),
                    CupertinoButton(
                        child: const Text(
                          "LogIn",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2),
                        ),
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
          bottomNavigationBar: Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "don't have an account?",
                  style: TextStyle(fontSize: 16),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return const SignUpPage();
                      }));
                    },
                    child: Text("SignUp",
                        style:
                            TextStyle(fontSize: 16, color: HexColor("#4169e9"))))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
