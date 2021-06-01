import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

Future<List<int>> genSalt(String addr, String pass) async {
  var str = '${addr}filwalllet$pass';
  final message = utf8.encode(str);
  final hash = await sha256.hash(
    message,
  );
  return hash.bytes;
}

Future<String> genPrivateKeyDigest(String privateKey) async {
  final hash = await sha256.hash(
    base64Decode(privateKey),
  );
  return base64Encode(hash.bytes.sublist(0, 16));
}

Future<Uint8List> genKek(String addr, String pass, {int size = 32}) async {
  final pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac(sha256),
    iterations: 10000,
    bits: size * 8,
  );
  final nonce = await genSalt(addr, pass);
  final newSecretKey = await pbkdf2.deriveBits(
    utf8.encode(pass),
    nonce: Nonce(nonce),
  );
  return newSecretKey;
}

Uint8List decodePrivate(String pk) {
  return base64Decode(pk);
}

String xor(Uint8List first, Uint8List second, {int size = 32}) {
  var list = <int>[];
  for (var i = 0; i < first.length; i++) {
    var ele = first[i];
    var ele2 = second[i];
    var res = ele ^ ele2;
    list.add(res);
  }
  return base64Encode(list);
}

Future<bool> validatePrivateKey(
    String addr, String pass, String skKek, String dig) async {
  var sk = await getPrivateKey(addr, pass, skKek);
  var digest = await genPrivateKeyDigest(sk);
  if (dig != digest) {
    return false;
  } else {
    return true;
  }
}

Future<String> getPrivateKey(
  String addr,
  String pass,
  String skKek,
) async {
  var skBytes = base64Decode(skKek);
  var kek = await genKek(addr, pass);
  var sk = xor(skBytes, kek);
  return sk;
}
