import 'dart:core';
import 'package:fil/chain/gas.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/index.dart';
import 'package:fil/models/address.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:fil/models/nonce.dart';
import 'package:fil/models/wallet.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fil/utils/enum.dart';

Future initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(NonceAdapter());
  Hive.registerAdapter(CacheGasAdapter());
  Hive.registerAdapter(NetworkAdapter());
  Hive.registerAdapter(TokenAdapter());
  Hive.registerAdapter(ChainWalletAdapter());
  Hive.registerAdapter(ContactAddressAdapter());
  Hive.registerAdapter(CacheMessageAdapter());
  Hive.registerAdapter(ChainGasAdapter());

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final String key1 = HiveKey.key;
  final String secret = HiveKey.secret;
  var containsEncryptionKey = await secureStorage.containsKey(key: 'key');
  if (!containsEncryptionKey) {
    var key = Hive.generateSecureKey();
    await secureStorage.write(key: 'key', value: base64UrlEncode(key));
  }
  var encryptionKey = base64Url.decode(await secureStorage.read(key: 'key'));

  Map<String, Box<dynamic>> map = {};
  var keys = HiveBoxType.getMap().keys.toList();
  final one = await Future.wait(HiveBoxType.getMap().keys.map(
      (value) => Hive.openBox(value, encryptionCipher: HiveAesCipher(encryptionKey))
    )
  );
  for(var i = 0 ; i < one.length; i++){
    var itemBox = one[i];
    map[keys[i]] = itemBox;
  }
  OpenedBox.initBox(map);
}

class OpenedBox {
  static Map<String, Box<dynamic>> _mmap={};
  static Box<dynamic> get<T>() {
    Box box;
    var types = HiveBoxType.getType();
    _mmap.forEach((key, value) {
      if (types[key] == T.toString()) {
        box = value;
        return;
      }
    });
    return box;
  }

  static void initBox(Map<String, dynamic> map) {
     map.forEach((key, value) {
       _mmap[key] = value;
     });
  }
}
