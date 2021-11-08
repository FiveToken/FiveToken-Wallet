/// gasUsed : 0
/// gasLimit : 0
/// blockHeight : 0
/// timestamp : 0

class ChainInfo {
  ChainInfo({
      this.gasUsed, 
      this.gasLimit, 
      this.blockHeight, 
      this.timestamp,});

  ChainInfo.fromJson(dynamic json) {
    gasUsed = json['gasUsed'];
    gasLimit = json['gasLimit'];
    blockHeight = json['blockHeight'];
    timestamp = json['timestamp'];
  }
  int gasUsed;
  int gasLimit;
  int blockHeight;
  int timestamp;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['gasUsed'] = gasUsed;
    map['gasLimit'] = gasLimit;
    map['blockHeight'] = blockHeight;
    map['timestamp'] = timestamp;
    return map;
  }

}