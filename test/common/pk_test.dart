import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constant.dart';

void main() {
  var addr = FilAddr;
  var pass = WalletLabel;
  var pk = FilPrivate;
  var skKek = 'Z5tz8fHqUqGNMHb47KCzPaAq0tKMgxEAcCOk5ri6ysE=';
  var digest = 'yCjEF6kR8IgjHm/xz4GLpA==';
  var saltList = [
    11,
    175,
    41,
    203,
    181,
    234,
    193,
    67,
    162,
    235,
    28,
    22,
    23,
    78,
    38,
    117,
    124,
    241,
    77,
    85,
    92,
    4,
    234,
    125,
    234,
    80,
    12,
    161,
    220,
    14,
    143,
    225
  ];
  var kekList = [
    100,
    220,
    167,
    26,
    95,
    130,
    52,
    165,
    129,
    37,
    159,
    232,
    224,
    130,
    70,
    187,
    186,
    238,
    64,
    35,
    193,
    142,
    148,
    47,
    255,
    254,
    66,
    203,
    255,
    19,
    25,
    227
  ];
  test("generate salt", () async {
    var list = await genSalt(addr, pass);
    expect(list, equals(saltList));
  });
  test('generate privatekey digest', () async {
    var res = await genPrivateKeyDigest(pk);
    expect(res, digest);
  });
  test('generate kek', () async {
    var list = await genKek(addr, pass);
    expect(list, equals(kekList));
  });
  test('test xor', () {
    var res = xor(kekList, decodePrivate(pk));
    expect(res, skKek);
  });
  test('test get privatekey by pass', () async {
    var res = await getPrivateKey(addr, pass, skKek);
    expect(res, res);
  });
}
