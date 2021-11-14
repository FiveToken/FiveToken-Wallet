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
  });

  ChainInfo.fromJson(dynamic json) {
    gasUsed = hexToDartInt(json['gasUsed']);
    gasLimit = hexToDartInt(json['gasLimit']);
    number = hexToDartInt(json['number']);
    timestamp = hexToDartInt(json['timestamp']);
  }

  int gasUsed;
  int gasLimit;
  int number;
  int timestamp;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['gasUsed'] = gasUsed.toString();
    map['gasLimit'] = gasLimit.toString();
    map['number'] = number.toString();
    map['timestamp'] = timestamp.toString();
    return map;
  }
}
