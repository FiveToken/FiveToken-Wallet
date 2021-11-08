class Block {
  int gasUsed;
  int gasLimit;
  int number;
  int timestamp;
  Block.fromMap(Map<String, dynamic> map) {
    gasUsed = int.parse(map['gasUsed'] as String);
    gasLimit = int.parse(map['gasLimit'] as String);
    number = int.parse(map['number'] as String);
    timestamp = int.parse(map['timestamp'] as String);
  }
}