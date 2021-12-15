
import 'package:fil/chain/lock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  var lockJson = {
    'lockscreen': true,
    'password': '123456',
    'status': 'update'
  };
  test("test chain lock", () {
    LockBox lock = LockBox.fromJson(lockJson);
    var resJson  = lock.toJson();
    expect(lockJson,resJson);
  });
}