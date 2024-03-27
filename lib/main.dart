import 'dart:async';

import 'package:baatein/Functions/GetNotifications.dart';
import 'package:baatein/GetUser.dart';
import 'package:baatein/MainScreen.dart';
import 'package:baatein/module/UserModule.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'login.dart';

var uuid= const Uuid();
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetNotifications().getNotifications();
  
  var user=FirebaseAuth.instance.currentUser;
  if(user!=null){
    UserModule? userMdl= await GetUser.getUserByEmail(user.email!);
    if(userMdl!=null){
      runApp( MyAppLoggedIn(userMdl: userMdl, usr: user));
    }
    else{
      runApp(const MyApp());
    }
  }else{
    runApp(const MyApp());
  }
  
}
late Image image1;
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Baatein'),
    );
  }
}
class MyAppLoggedIn extends StatelessWidget {
  final UserModule userMdl;
  final User usr ;

  const MyAppLoggedIn({Key? key,required this.userMdl,required this.usr}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      home:  MyHome2(userMdl: userMdl, usr: usr),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    image1 = Image.asset("assets/logo.png", fit: BoxFit.fitWidth);
    Timer(
        const Duration(seconds: 5),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const loginPage())));
  }
  @override
  void didChangeDependencies() {
    precacheImage(image1.image, context);
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    
    return SafeArea(
      child: Scaffold(
        
        body: Center(
          
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.white,
            child: image1,
          ),
        ),
        bottomNavigationBar: BottomAppBar(child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Made with ❤️ by aayu"),
          ],
        ),elevation: 0,),
      ),
    );
  }
}
class MyHome2 extends StatefulWidget {
  final UserModule userMdl;
  final User usr ;

  const MyHome2({Key? key, required this.userMdl,required this.usr}) : super(key: key);

  @override
  State<MyHome2> createState() => _MyHomePageState2();
}

class _MyHomePageState2 extends State<MyHome2> {

  @override
  void initState() {
    super.initState();
    image1 = Image.asset("assets/logo.png", fit: BoxFit.fitWidth);
    Timer(
        const Duration(seconds: 3),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainScreen(userMdl: widget.userMdl, usr: widget.usr))));
  }
  @override
  void didChangeDependencies() {
    precacheImage(image1.image, context);
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    
    return SafeArea(
      child: Scaffold(
        
        body: Center(
          
          child: Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.white,
            child: image1,
          ),
        ),
        bottomNavigationBar: BottomAppBar(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Made with ❤️ by aayu",),
          ],
        ),elevation: 0,),
      ),
    );
  }
}
