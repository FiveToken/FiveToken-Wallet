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
    gasLimit = json['gasLimit'] ?? 0;
    gasPrice = json['gasPrice'] ?? '0';
    gasState = json['gasState'] ?? '0';
    message = json['message'] ?? '';
    gasFeeCap = json['gasFeeCap'] ?? '0';
    gasPremium = json['gasPremium'] ?? '0';
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