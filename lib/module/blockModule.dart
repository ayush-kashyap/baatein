class blockModule{
  String? blockedUsername;
  String? blockedUserid;
  String? blockedUseremail;
  String? blockedUserpfp;

  blockModule({this.blockedUsername,this.blockedUserid,this.blockedUseremail,this.blockedUserpfp});

  blockModule.fromMap(Map<String,dynamic> map){
    blockedUsername=map["blockedUsername"];
    blockedUserid=map["blockedUserid"];
    blockedUseremail=map["blockedUseremail"];
    blockedUserpfp=map["blockedUserpfp"];
  }
  Map<String,dynamic> toMap(){
    return{
      "blockedUsername":blockedUsername,
        "blockedUserid":blockedUserid,
        "blockedUseremail":blockedUseremail,
        "blockedUserpfp":blockedUserpfp
    };
  }
}