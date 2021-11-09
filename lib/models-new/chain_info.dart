import 'package:web3dart/crypto.dart';

/// gasUsed : 0
/// gasLimit : 0
/// blockHeight : 0
/// timestamp : 0

class ChainInfo {
  ChainInfo({
    this.gasUsed,
    this.gasLimit,
    this.blockHeight,
    this.timestamp,
  });

  ChainInfo.fromJson(dynamic json) {
    gasUsed = hexToInt(json['gasUsed']);
    gasLimit = hexToInt(json['gasLimit']);
    blockHeight = hexToInt(json['number']);
    timestamp = hexToInt(json['timestamp']);
  }

  BigInt gasUsed;
  BigInt gasLimit;
  BigInt blockHeight;
  BigInt timestamp;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['gasUsed'] = gasUsed.toString();
    map['gasLimit'] = gasLimit.toString();
    map['number'] = blockHeight.toString();
    map['timestamp'] = timestamp.toString();
    return map;
  }
}
