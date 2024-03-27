import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';
const serverKey="hidden";

class GetNotifications{
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  Future<void> getNotifications() async{
    await messaging.requestPermission(
      alert: true,
      sound: true,
      provisional: true,
      carPlay: true,
      announcement: true,
      criticalAlert: true,
      badge: true,
    );
  }
Future<String> getDeviceToken() async{
  final FCMToken = await messaging.getToken();
  return FCMToken.toString();
}

  void sendNotification(sender,msg,sendTo,image) async{
    var data={
      'to': sendTo,
      'priority':'high',
      'notification':{
        'title': sender,
        'body':msg,
        'image':image
      }
    };
    await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
    body: jsonEncode(data),
    headers: {
      'Content-Type':'application/json; charset=UTF-8',
      'Authorization':'key=$serverKey'
    }
    );
  }

}
