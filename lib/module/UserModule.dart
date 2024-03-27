class UserModule{
  String? uid;
  String? fullname;
  String? email;
  String? gender;
  String? profilepic;
  String? proType;
  String? deviceToken;

  UserModule({this.uid,this.fullname,this.email,this.gender,this.profilepic,this.proType,this.deviceToken});
  
  UserModule.fromMap(Map<String, dynamic> map){
    uid=map["uid"];
    fullname=map["fullname"];
    email=map["email"];
    gender=map["gender"];
    profilepic=map["profilepic"];
    proType=map["proType"];
    deviceToken=map["deviceToken"];
  }

  Map<String, dynamic> toMap(){
    return {
      "uid": uid,
      "fullname": fullname,
      "email": email,
      "gender": gender,
      "profilepic": profilepic,
      "proType": proType,
      "deviceToken": deviceToken,
    };
  }
}