
import 'package:hive/hive.dart';
part 'nonce_unit.g.dart';

@HiveType(typeId: 13)
class NonceUnit {
  @HiveField(0)
  int time;

  @HiveField(1)
  List<int> value;

  NonceUnit({
      this.time, 
      this.value,});

  NonceUnit.fromJson(dynamic json) {
    time = json['time'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['time'] = time;
    map['value'] = value;
    return map;
  }
}