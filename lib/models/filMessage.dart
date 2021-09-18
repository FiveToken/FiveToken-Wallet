import 'package:fil/index.dart';
import 'package:hive/hive.dart';
part 'filMessage.g.dart';

@HiveType(typeId: 1)
class TMessage {
  @HiveField(0)
  String to;
  @HiveField(1)
  String from;
  @HiveField(2)
  String value;
  @HiveField(3)
  String gasFeeCap;
  @HiveField(4)
  String params;
  @HiveField(5)
  String gasPremium;
  @HiveField(6)
  num version;
  @HiveField(7)
  num nonce;
  @HiveField(8)
  num method;
  @HiveField(9)
  num gasLimit;
  @HiveField(10)
  String args;

  TMessage(
      {this.version,
      this.to,
      this.from,
      this.value,
      this.gasFeeCap,
      this.gasPremium,
      this.gasLimit,
      this.params,
      this.nonce,
      this.args,
      this.method});

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "Version": this.version,
      "To": this.to,
      "From": this.from,
      "Value": this.value,
      "GasFeeCap": this.gasFeeCap,
      "GasPremium": this.gasPremium,
      "GasLimit": this.gasLimit,
      "Params": this.params,
      "Nonce": this.nonce,
      "Method": this.method,
      "Args": this.args
    };
  }

  Map<String, dynamic> toLotusMessage() {
    return <String, dynamic>{
      "Version": this.version,
      "To": this.to,
      "From": this.from,
      "Value": this.value,
      "GasFeeCap": this.gasFeeCap,
      "GasPremium": this.gasPremium,
      "GasLimit": this.gasLimit,
      "Params": this.params,
      "Nonce": this.nonce,
      "Method": this.method,
    };
  }

  bool get valid {
    try {
      var feeCapNum = int.parse(gasFeeCap);
      var premium = int.parse(gasPremium);
      var valueNum = int.parse(value);
      return version is int &&
          to is String &&
          from is String &&
          feeCapNum is int &&
          valueNum is int &&
          premium is int &&
          gasLimit is int &&
          nonce is int &&
          method is int;
    } catch (e) {
      return false;
    }
  }
}

@HiveType(typeId: 2)
class Signature {
  @HiveField(0)
  String data;
  @HiveField(1)
  num type;

  Signature(this.type, this.data);

  Signature.fromJson(Map<String, dynamic> json)
      : this.type = json['Type'],
        this.data = json['Data'];

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "Type": this.type,
      "Data": this.data,
    };
  }
}

@HiveType(typeId: 0)
class SignedMessage {
  @HiveField(0)
  TMessage message;
  @HiveField(1)
  Signature signature;

  SignedMessage(this.message, this.signature);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "Message": this.message,
      "Signature": this.signature,
    };
  }

  Map<String, dynamic> toLotusSignedMessage() {
    return <String, dynamic>{
      "Message": this.message.toLotusMessage(),
      "Signature": this.signature,
    };
  }
}
