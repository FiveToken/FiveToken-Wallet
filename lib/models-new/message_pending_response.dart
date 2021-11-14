/// cid : ""
/// origin_cid : ""

class MessagePendingResponse {
  MessagePendingResponse({
      this.cid, 
      this.originCid,});

  MessagePendingResponse.fromJson(dynamic json) {
    cid = json['cid'];
    originCid = json['origin_cid'];
  }
  String cid;
  String originCid;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['cid'] = cid;
    map['origin_cid'] = originCid;
    return map;
  }

}