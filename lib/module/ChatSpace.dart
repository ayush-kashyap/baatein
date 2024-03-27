class ChatSpace{
  String? chatId;
  String? per1;
  String? per2;
  bool? status;
  String? blockBy;
  String? lastmsg;

  ChatSpace({this.chatId,this.per1,this.per2,this.blockBy,this.status,this.lastmsg});
  ChatSpace.fromMap(Map<String,dynamic>map){
    chatId=map["chatId"];
    lastmsg=map["lastmsg"];
    per1=map["per1"];
    per2=map["per2"];
    blockBy=map["blockBy"];
    status=map["status"];
  }
  Map<String,dynamic> toMap(){
    return{
      "chatId": chatId,
      "lastmsg":lastmsg,
      "per1":per1,
      "per2":per2,
      "blockBy":blockBy,
      "status":status,
    };
  }
}