/// gasLimit : 0
/// gasPrice : ""
/// gasState : ""
/// message : ""
/// gasFeeCap : ""
/// gasPremium : ""

class GasResponse {
  GasResponse({
      this.gasLimit, 
      this.gasPrice, 
      this.gasState, 
      this.message, 
      this.gasFeeCap, 
      this.gasPremium,});

  GasResponse.fromJson(dynamic json) {
    gasLimit = json['gasLimit'];
    gasPrice = json['gasPrice'];
    gasState = json['gasState'];
    message = json['message'];
    gasFeeCap = json['gasFeeCap'];
    gasPremium = json['gasPremium'];
  }
  int gasLimit;
  String gasPrice;
  String gasState;
  String message;
  String gasFeeCap;
  String gasPremium;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['gasLimit'] = gasLimit;
    map['gasPrice'] = gasPrice;
    map['gasState'] = gasState;
    map['message'] = message;
    map['gasFeeCap'] = gasFeeCap;
    map['gasPremium'] = gasPremium;
    return map;
  }

}