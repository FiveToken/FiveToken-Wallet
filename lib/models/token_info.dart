/// symbol : ""
/// precision : "0"

class TokenInfo {
  TokenInfo({
      this.symbol, 
      this.precision,});

  TokenInfo.fromJson(dynamic json) {
    symbol = json['symbol'] as String;
    precision = json['precision'] as String;
  }
  String symbol;
  String precision;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['symbol'] = symbol;
    map['precision'] = precision;
    return map;
  }

}