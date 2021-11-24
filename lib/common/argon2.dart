import 'dart:typed_data';
import 'dart:convert';
import 'package:argon2/argon2.dart';

import 'package:libsodium/libsodium.dart';

String argon2Crypt(String password){
  var salt = 'someSalt'.toBytesLatin1();
  var parameters = Argon2Parameters(
    Argon2Parameters.ARGON2_i,
    salt,
    version: Argon2Parameters.ARGON2_VERSION_10,
    iterations: 2,
    memoryPowerOf2: 16,
  );
  var argon2 = Argon2BytesGenerator();
  argon2.init(parameters);
  var passwordBytes = parameters.converter.convert(password);
  var result = Uint8List(32);
  argon2.generateBytes(passwordBytes, result, 0, result.length);
  var resultHex = result.toHexString();
  return resultHex;
}

Uint8List encryptSodium(String privateKey, String address, String pass){
  Sodium.init();
  var nonce = CryptoBox.randomNonce();
  var secretKey = argon2Crypt(pass);
  return CryptoBox.encrypt(
      utf8.encode(privateKey), // value
      nonce, // nonce
      utf8.encode(address), // publicKey
      utf8.encode(secretKey) // secretKey
  );
}