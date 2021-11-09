/// symbol : ""
/// precision : 0
/// address : ""
/// chain : ""
/// rpc : ""
/// balance : ""
/// currency : ""
/// tokenType : ""

class Token {
  Token({
    this.symbol,
    this.precision,
    this.address,
    this.chain,
    this.rpc,
    this.balance,
    this.currency,
    this.tokenType
  });

  Token.fromJson(dynamic json) {
    symbol = json['symbol'];
    precision = json['precision'];
    address = json['address'];
    chain = json['chain'];
    rpc = json['rpc'];
    balance = json['balance'];
    currency = json['currency'];
    tokenType = json['tokenType'];
  }
  String symbol;
  int precision;
  String address;
  String chain;
  String rpc;
  String balance;
  String currency;
  String tokenType;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['symbol'] = symbol;
    map['precision'] = precision;
    map['address'] = address;
    map['chain'] = chain;
    map['rpc'] = rpc;
    map['balance'] = balance;
    map['currency'] = currency;
    map['tokenType'] = tokenType;
    return map;
  }
}