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
    gasLimit = json['gasLimit'] as int ?? 0;
    gasPrice = json['gasPrice'] as String ?? '0';
    gasState = json['gasState'] as String?? '0';
    message = json['message'] as String ?? '';
    gasFeeCap = json['gasFeeCap'] as String ?? '0';
    gasPremium = json['gasPremium'] as String?? '0';
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