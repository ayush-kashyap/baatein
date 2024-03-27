import 'module/UserModule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class GetUser{
  static Future<UserModule?> getUserByEmail(String email)async{
    UserModule usermNew;

    var userData=await FirebaseFirestore.instance.collection("users").doc("public").collection("usernames").doc(email).get();
    if(userData.exists){
      usermNew=UserModule.fromMap(userData.data() as Map<String,dynamic>);
    }else{
      userData=await FirebaseFirestore.instance.collection("users").doc("private").collection("usernames").doc(email).get();
      usermNew=UserModule.fromMap(userData.data() as Map<String,dynamic>);
    }
    return usermNew;
  }
}