import 'dart:typed_data';

import 'package:fil/store/store.dart';

class EncryptArgon {

   EncryptKey encryptKey;
   Uint8List argon2Key;

  EncryptArgon({this.encryptKey,this.argon2Key});

  dynamic getKey () {
    switch($store.encryptionType.value){
      case 'argon2':
       return argon2Key;
        break;
      default:
        return encryptKey;
    }
  }
}

class EncryptKey {
  String kek;
  String digest;
  String address;
  String private;
  EncryptKey({this.kek, this.digest, this.address, this.private});
}
