
import 'package:hive/hive.dart';
part 'nonce_unit.g.dart';

@HiveType(typeId: 13)
class NonceUnit {
  @HiveField(0)
  int time;

  @HiveField(1)
  List<int> value;

  @HiveField(2)
  String salt;

  NonceUnit({
      this.time, 
      this.value,
      this.salt
  });

  NonceUnit.fromJson(dynamic json) {
    time = json['time'] as int;
    value = json['value'] as List<int>;
    salt = json['salt'] as String;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['time'] = time;
    map['value'] = value;
    map['salt'] = salt;
    return map;
  }
}