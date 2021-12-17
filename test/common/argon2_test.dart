import 'dart:typed_data';

import 'package:fil/common/argon2.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String pass = '123456';
  String resPass= '58ba3b6b227ec846312bdeff789e8469c9f128abac898daa07bf3f0e0355f638';
  test('test common argon2', () async {
     String encryptPass = argon2Crypt(pass);
     expect(encryptPass, resPass);
  });
}