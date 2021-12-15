import 'dart:typed_data';
import 'dart:convert';
import 'package:argon2/argon2.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/nonce_unit.dart';

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

Future<String> argon2Hash(String privateKey) async {
  Uint8List res = await argon2encrypt(privateKey);
  return base64Encode(res);
}

Future<Uint8List> argon2encrypt(String privateKey) async {
  Sodium.init();
  var address = '12345678901234567890123456789012';
  var pass = 'ky20210104';
  var nonce = CryptoBox.randomNonce();
  var box = OpenedBox.nonceUnitInstance;
  var secretKey = argon2Crypt(pass);
  NonceUnit n = NonceUnit.fromJson({
    "time": new DateTime.now().millisecondsSinceEpoch,
    "value": nonce..toList(),
  });
  box.put(secretKey, n);
  Uint8List res = CryptoBox.encrypt(
      utf8.encode(privateKey), // value
      nonce, // nonce
      utf8.encode(address), // publicKey
      utf8.encode(secretKey.substring(0,32)) // secretKey
  );
  return res;
}

Future<Uint8List> argon2decrypt(Uint8List privateKey) async {
  Sodium.init();
  var address = '12345678901234567890123456789012';
  var pass = 'ky20210104';
  var nonce = CryptoBox.randomNonce();
  var secretKey = argon2Crypt(pass);
  var box = OpenedBox.nonceUnitInstance;
  NonceUnit n = box.get(secretKey);
  if(n!=null&&n.value!=null){
    nonce = n.value.toUint8List();
  };
  try {
    Uint8List res = CryptoBox.decrypt(
        privateKey, // value
        nonce, // nonce
        utf8.encode(address), // publicKey
        utf8.encode(secretKey.substring(0, 32)) // secretKey
    );
    return res;
  }catch(e){}
}



String encryptSodium(String privateKey, String address, String pass){
  Sodium.init();
  var nonce = CryptoBox.randomNonce();
  var box = OpenedBox.nonceUnitInstance;
  String keys = '${address}filwalllet$pass';
  var secretKey = argon2Crypt(keys);
  NonceUnit n = box.get(secretKey);
  if(n!=null&&n.value!=null){
    nonce = n.value.toUint8List();
  }else{
    NonceUnit n1 = NonceUnit.fromJson({
      "time": new DateTime.now().millisecondsSinceEpoch,
      "value": nonce..toList(),
    });
    box.put(secretKey, n1);
  }
  var value = utf8.encode(privateKey);
  try {
    Uint8List res = CryptoBox.encrypt(
        value, // value
        nonce, // nonce
        utf8.encode(address.substring(0,32)), // publicKey
        utf8.encode(secretKey.substring(0, 32)) // secretKey
    );
    return base64Encode(res);
  }catch(e){
    throw(e);
  }
}

String decryptSodium(String privateKey,String address, String pass){
  var nonce = CryptoBox.randomNonce();
  var box = OpenedBox.nonceUnitInstance;
  String keys = '${address}filwalllet$pass';
  var secretKey = argon2Crypt(keys);
  NonceUnit n = box.get(secretKey);
  if(n!=null&&n.value!=null){
    nonce = n.value.toUint8List();
  };
  var value = base64Decode(privateKey);
  try {
    Uint8List res = CryptoBox.decrypt(
        value, // value
        nonce,
        utf8.encode(address.substring(0,32)), // publicKey
        utf8.encode(secretKey.substring(0,32)) // secretKey
    );
    return base64Encode(res);
  }catch(e){
    throw(e);
  }
}