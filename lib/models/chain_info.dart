import 'package:web3dart/crypto.dart';

/// gasUsed : 0
/// gasLimit : 0
/// blockHeight : 0
/// timestamp : 0

class ChainInfo {
  ChainInfo({
    this.gasUsed,
    this.gasLimit,
    this.number,
    this.timestamp,
    this.baseFeePerGas,
  });

  ChainInfo.fromJson(dynamic json) {
    gasUsed = hexToDartInt(json['gasUsed'] as String);
    gasLimit = hexToDartInt(json['gasLimit'] as String);
    number = hexToDartInt(json['number'] as String);
    timestamp = hexToDartInt(json['timestamp'] as String);
    baseFeePerGas = hexToDartInt(json['baseFeePerGas']as String);
  }

  int gasUsed;
  int gasLimit;
  int number;
  int timestamp;
  int baseFeePerGas;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['gasUsed'] = gasUsed.toString();
    map['gasLimit'] = gasLimit.toString();
    map['number'] = number.toString();
    map['timestamp'] = timestamp.toString();
    map['baseFeePerGas'] = baseFeePerGas.toString();
    return map;
  }
}
