/// gasPrice : ""
/// gasPremium : ""
/// gasLimit : 0
/// level : 0

class ChainGas {
  ChainGas({
    this.gasPrice,
    this.gasPremium,
    this.gasLimit,
    this.level,});

  ChainGas.fromJson(dynamic json) {
    gasPrice = json['gasPrice'];
    gasPremium = json['gasPremium'];
    gasLimit = json['gasLimit'];
    level = json['level'];
  }
  String gasPrice;
  String gasPremium;
  int gasLimit;
  int level;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['gasPrice'] = gasPrice;
    map['gasPremium'] = gasPremium;
    map['gasLimit'] = gasLimit;
    map['level'] = level;
    return map;
  }

}