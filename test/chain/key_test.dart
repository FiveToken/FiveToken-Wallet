
import 'dart:math';
import 'dart:typed_data';

import 'package:fil/chain/key.dart';
import 'package:fil/store/store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

void main() {
  Get.put(StoreController());
  $store.setEncryptionType('argon2');
  test("test chain key", () {
    EncryptKey key = EncryptKey(
        kek: 'hEngKhJBmohbCLgELlcOnYe3EKdL7AMsna1RruIf6yg0oe6dRn6UHcEzDsPnT0Pdb7EtM64cmK1Udc/+kG/IW1poEdzBuTz0jjeYCL4XB9M=',
        digest: 'pjopmwVs2Of9A86xPX0dYg==',
        address: '0xa45bc341e17e7bb8c3183644f6293e0a6d16071e',
        // private: 'qTldT00zVmRPO4ULQBmnvg6eQz+xh07BaDemzpLhfhdbetB8='
    );
    Uint8List argon2Key;
    EncryptArgon  encryptArgon = EncryptArgon(encryptKey: key, argon2Key: argon2Key);
    var enkey = encryptArgon.getKey();
    expect(enkey, null);

    $store.setEncryptionType('sha256');
    var shakey = encryptArgon.getKey();
    expect(shakey, key);
  });
}