class PrivateKey {
  String type;
  String privateKey;
  PrivateKey(this.type,this.privateKey);
  Map<String,dynamic> toJson(){
    return {
      "Type":this.type,
      "PrivateKey":this.privateKey
    };
  }
  PrivateKey.fromMap(Map<String, dynamic> map)
      : type = map["Type"],
        privateKey = map["PrivateKey"];
}