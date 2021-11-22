import 'dart:core';
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
import 'package:fil/models-new/chain_gas.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fil/utils/enum.dart';

const messageBox = 'message';
const addressBox = 'address';
const addressBookBox = 'addressBookBox';
const nonceBox = 'nonceBox';
const gasBox = 'gasBox';
const netBox = 'netBox';
const tokenBox = 'tokenBox';
const walletBox = 'walletBox';
const cacheMessageBox = 'cacheMessageBox';

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
  final String hiveKey = 'key';
  final String secret = 'secret';
  var containsEncryptionKey = await secureStorage.containsKey(key: hiveKey);
  if (!containsEncryptionKey) {
    var key = Hive.generateSecureKey();
    await secureStorage.write(key: hiveKey, value: base64UrlEncode(key));
  }
  var encryptionKey = base64Url.decode(await secureStorage.read(key: hiveKey));

  Map<String, dynamic> map = {};


  var keys = HiveBoxType.getMap().keys.toList();

  print(keys);

  // await Hive.openBox('nonceBox',encryptionCipher: HiveAesCipher(encryptionKey));

  final one = await Future.wait(HiveBoxType.getMap().keys.map((value) =>
      Hive.openBox(value,
      encryptionCipher: HiveAesCipher(encryptionKey))));
  print(one);
  for(var i = 0 ; i < one.length; i++){
    var itemBox = one[i];
    itemBox.put(secret,hiveKey);
    map[keys[i]] = itemBox;
  }

  // HiveBoxType.getMap().keys.forEach((value)async{
  //   var itemBox = await Hive.openBox(
  //     value, encryptionCipher: HiveAesCipher(encryptionKey));
  //    itemBox.put(secret, hiveKey);
  //   map[value] = itemBox;
  // });


  //
  // boxAddress.put(secret, hiveKey);
  // boxNook.put(secret, hiveKey);
  // boxNonce.put(secret, hiveKey);
  // boxGas.put(secret, hiveKey);
  // boxNetwork.put(secret, hiveKey);
  // boxToken.put(secret, hiveKey);
  // boxWallet.put(secret, hiveKey);
  // boxMessage.put(secret, hiveKey);
  // await OpenedBox.walletInstance.deleteFromDisk();
  // await OpenedBox.get<CacheMessage>().deleteFromDisk();
  // await OpenedBox.tokenInstance.deleteFromDisk();
  OpenedBox.initBox(map);
}

class OpenedBox {
  // static Box<Wallet> addressInsance;
  // static Box<ContactAddress> addressBookInsance;
  // static Box<Nonce> nonceInsance;
  // static Box<ChainGas> gasInsance;
  // static Box<Network> netInstance;
  // static Box<Token> tokenInstance;
  // static Box<ChainWallet> walletInstance;
  // static Box<CacheMessage> mesInstance;


  static Map<String, Box<dynamic>> _mmap={};



  static Box<T> get<T>() {
    Box box;
    var types = HiveBoxType.getType();
    _mmap.forEach((key, value) {
      if (types[key] == T.toString()) {
        box = value as Box<dynamic>;
        return;
      }
    });
    return box;
  }
  // final one = OpenedBox.get<Wallet>()


  static void initBox(Map<String, dynamic> map) {
     map.forEach((key, value) { _mmap[key] = value;});
    // OpenedBox.addressInsance = boxAddress.get(key);
    // OpenedBox.addressBookInsance = boxNook.get(key);
    // OpenedBox.nonceInsance = boxNonce.get(key);
    // OpenedBox.gasInsance = boxGas.get(key);
    // OpenedBox.netInstance = boxNetwork.get(key);
    // OpenedBox.tokenInstance = boxToken.get(key);
    // OpenedBox.walletInstance = boxWallet.get(key);
    // OpenedBox.mesInstance = boxMessage.get(key)
    // );
// OpenedBox.addressInsance = Hive.box<Wallet>(addressBox);
// OpenedBox.addressBookInsance = Hive.box<ContactAddress>(addressBookBox);
// OpenedBox.nonceInsance = Hive.box<Nonce>(nonceBox);
// OpenedBox.gasInsance = Hive.box<ChainGas>(gasBox);
// OpenedBox.netInstance = Hive.box<Network>(netBox);
// OpenedBox.tokenInstance = Hive.box<Token>(tokenBox);
// OpenedBox.walletInstance = Hive.box<ChainWallet>(walletBox);
// OpenedBox.mesInstance = Hive.box<CacheMessage>(cacheMessageBox);
  }
}
