/// cid : ""
/// message : ""

class TransactionResponse {
  TransactionResponse({
      this.cid, 
      this.message,});

  TransactionResponse.fromJson(dynamic json) {
    cid = json['cid'];
    message = json['message'];
  }
  String cid;
  String message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['cid'] = cid;
    map['message'] = message;
    return map;
  }

}