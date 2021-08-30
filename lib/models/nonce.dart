import 'package:fil/index.dart';
import 'package:hive/hive.dart';
part 'nonce.g.dart';

@HiveType(typeId: 5)
class Nonce {
  @HiveField(0)
  int time;
  @HiveField(1)
  int value;
  Nonce({this.time, this.value});
  Nonce.fromJson(Map<dynamic, dynamic> json) {
    time = json['time'];
    value = json['value'];
  }
  Map<String, dynamic> toJson() {
    return <String, int>{'time': time, 'value': value};
  }
}

@HiveType(typeId: 6)
class CacheGas {
  @HiveField(0)
  String feeCap;
  @HiveField(1)
  String premium;
  @HiveField(2)
  String cid;
  @HiveField(3)
  num gasLimit;
  CacheGas({this.feeCap, this.premium, this.cid, this.gasLimit});
}

