import 'package:hive/hive.dart';
part 'lock.g.dart';
/// lockscreen : true
/// password : ""
/// status : ""

@HiveType(typeId: 15)
class LockBox {
  @HiveField(0)
  bool lockscreen;
  @HiveField(1)
  String password;
  @HiveField(2)
  String status;
  LockBox({
      this.lockscreen, 
      this.password,
      this.status
  });

  LockBox.fromJson(dynamic json) {
    lockscreen = json['lockscreen'];
    password = json['password'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['lockscreen'] = lockscreen;
    map['password'] = password;
    map['status'] = status;
    return map;
  }

}