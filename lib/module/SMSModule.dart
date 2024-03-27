class SMSModule{
  String? messageid;
  String? sender;
  String? msg;
  String? time;
  String? image;
  String? deletedfor;
  bool? seen;

  SMSModule({this.messageid,this.sender,this.image,this.deletedfor,this.msg,this.time,this.seen});
  SMSModule.fromMap(Map<String,dynamic>map){
    messageid=map["messageid"];
    sender=map["sender"];
    image=map["image"];
    deletedfor=map["deletedfor"];
    msg=map["msg"];
    time=map["time"];
    seen=map["seen"];
  }
  Map<String,dynamic> toMap(){
    return{
      "messageid":messageid,
      "sender":sender,
      "image":image,
      "deletedfor":deletedfor,
      "msg":msg,
      "time":time,
      "seen":seen,
    };
  }
}