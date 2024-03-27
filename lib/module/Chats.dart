class Chats{
  String? chatId;
  String? nameChat;
  String? lastMsg;
  String? lastMsgDate;
  int? unseenCount;
  String? pfp;
  String? emailtarget;

  Chats({this.chatId,this.nameChat,this.lastMsg,this.lastMsgDate,this.unseenCount,this.pfp,this.emailtarget});

  Chats.fromMap(Map<String,dynamic> map){
    chatId=map["chatId"];
    nameChat=map["nameChat"];
    lastMsg=map["lastMsg"];
    lastMsgDate=map["lastMsgDate"];
    unseenCount=map["unseenCount"];
    pfp=map["pfp"];
    emailtarget=map["emailtarget"];
  }
  Map<String,dynamic> toMap(){
    return{
      "chatId":chatId,
      "nameChat":nameChat,
      "lastMsg":lastMsg,
      "lastMsgDate":lastMsgDate,
      "unseenCount":unseenCount,
      "pfp":pfp,
      "emailtarget":emailtarget,
    };
  }
}