/// from : ""
/// nonce : 0

class MessagePending {
  MessagePending({
      this.from, 
      this.nonce,});

  MessagePending.fromJson(dynamic json) {
    from = json['from'];
    nonce = json['nonce'];
  }
  String from;
  int nonce;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['from'] = from;
    map['nonce'] = nonce;
    return map;
  }

}