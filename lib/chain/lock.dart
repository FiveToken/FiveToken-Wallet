import 'package:hive/hive.dart';
part 'lock.g.dart';
/// lockscreen : true
/// password : ""

@HiveType(typeId: 15)
class LockBox {
  @HiveField(0)
  bool lockscreen;
  @HiveField(1)
  String password;
  LockBox({
      this.lockscreen, 
      this.password,});

  LockBox.fromJson(dynamic json) {
    lockscreen = json['lockscreen'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['lockscreen'] = lockscreen;
    map['password'] = password;
    return map;
  }

}