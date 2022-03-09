import 'dart:typed_data';
import 'dart:convert';
import 'package:fil/init/hive.dart';
import 'package:fil/models/nonce_unit.dart';
import 'package:libsodium/libsodium.dart';

// arguments password
Future<String> argon2Hash(String password) async {
  String str = PasswordHash.hashStringStorage(password);
  return str;
}

// Generates a random nonce for use with secret key encryption.
Uint8List randomNonce() {
  return SecretBox.randomNonce();
}

// get nonce and salt
Future<NonceUnit> getUnit(key) async {
  // var secretKey = await argon2Hash(key);
  var salt = PasswordHash.randomSalt();
  var box = OpenedBox.nonceUnitInstance;
  NonceUnit n = box.get(key);
  if (n != null && n.value != null) {
    return n;
  } else {
    var nonce = SecretBox.randomNonce();
    NonceUnit n1 = NonceUnit.fromJson({
      "time": new DateTime.now().millisecondsSinceEpoch,
      "value": nonce..toList(),
      "salt": base64Encode(salt)
    });
    box.put(key, n1);
    return n1;
  }
}

// Encrypts a string message with a key and a nonce
Future<Uint8List> encryptSodium(
    String value, String address, String password) async {
  String keys = '${address}filwalllet$password';
  NonceUnit unit = await getUnit(keys);
  Uint8List salt = base64Decode(unit.salt);
  print(salt);
  Uint8List secretKey = PasswordHash.hashString(keys, salt,
      alg: PasswordHashAlgorithm.Argon2id13);
  List<int> _secretKey = secretKey.toList();
  _secretKey.addAll(secretKey.toList());
  Uint8List public = Uint8List.fromList(_secretKey);
  Uint8List nonce = Uint8List.fromList(unit.value);
  try {
    Uint8List res = SecretBox.encryptString(
      value, // String
      nonce, // Uint8List
      public, // Uint8List
    );
    return res;
  } catch (e) {
    throw (e);
  }
}

// Verifies and decrypts a cipher text produced by encrypt.
Future<String> decryptSodium(
    String privateKey, String address, String password) async {
  String keys = '${address}filwalllet$password';
  NonceUnit unit = await getUnit(keys);
  Uint8List value = base64Decode(privateKey);
  Uint8List nonce = Uint8List.fromList(unit.value);
  Uint8List salt = base64Decode(unit.salt);
  Uint8List secretKey = PasswordHash.hashString(keys, salt, alg: PasswordHashAlgorithm.Argon2id13);  // secretKey 16 size
  List<int> _secretKey = secretKey.toList();
  _secretKey.addAll(secretKey.toList());
  Uint8List public = Uint8List.fromList(_secretKey); // public should be 32 size
  try {
    String res = SecretBox.decryptString(
      value, // String
      nonce, // Uint8List
      public, // Uint8List
    );
    return res;
  } catch (e) {
    throw (e);
  }
}
