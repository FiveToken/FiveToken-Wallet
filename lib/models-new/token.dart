/// symbol : ""
/// precision : 0
/// address : ""
/// chain : ""
/// rpc : ""
/// balance : ""

class Token {
  Token({
    this.symbol,
    this.precision,
    this.address,
    this.chain,
    this.rpc,
    this.balance,});

  Token.fromJson(dynamic json) {
    symbol = json['symbol'];
    precision = json['precision'];
    address = json['address'];
    chain = json['chain'];
    rpc = json['rpc'];
    balance = json['balance'];
  }
  String symbol;
  int precision;
  String address;
  String chain;
  String rpc;
  String balance;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['symbol'] = symbol;
    map['precision'] = precision;
    map['address'] = address;
    map['chain'] = chain;
    map['rpc'] = rpc;
    map['balance'] = balance;
    return map;
  }

}