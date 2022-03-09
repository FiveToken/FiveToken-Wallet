import 'dart:typed_data';

import 'package:fil/common/argon2.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String pass = '12345678';
  String resPass= 'e6e386a000a4469291345ec6617dce20edd4f45339396d599efaf39dc2e96183';
  String res1Pass = 'e6e386a000a4469291345ec6617dce20edd4f45339396d599efaf39dc2e96183';
  test('test common argon2', () async {
     // String encryptPass = argon2Crypt(pass);
     // expect(encryptPass, resPass);
     // Uint8List res2 = await argon2encrypt(pass);
     // print(res2);
  });
  // test('test common argon2hash', () async {
  //   Uint8List aa = await argon2Hash('hello');
  //   print(aa);
  //   expect(aa, aa);
  // });
}