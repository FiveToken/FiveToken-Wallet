import 'package:flutter_test/flutter_test.dart';
import 'package:fil/models/nonce_unit.dart';
void main() {
  test("generate model nonce_unit", () async {
    NonceUnit nonce = NonceUnit.fromJson({
      'time': 1639287942265,
      'value': [1,2,3,4,5],
    });
    NonceUnit nonce1 = NonceUnit(time: 1639287942266, value:[1,2,3,4,5,6,7,8]);
    nonce.toJson();
    expect(nonce.value, 1234567890);
    expect(nonce1.value, [1,2,3,4,5]);
  });
}