import 'dart:convert';
import 'dart:core';
import 'package:fil/chain/gas.dart';
import 'package:fil/chain/lock.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/models/address.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:fil/models/nonce.dart';
import 'package:fil/models/nonce_unit.dart';
import 'package:fil/models/wallet.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fil/utils/enum.dart';

List<int> encryptionKey;

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
  Hive.registerAdapter(NonceUnitAdapter());
  Hive.registerAdapter(LockBoxAdapter());

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  // final String key1 = HiveKey.key;
  // final String secret = HiveKey.secret;
  var containsEncryptionKey = await secureStorage.read(key: 'key');
  if (containsEncryptionKey == null || containsEncryptionKey == '') {
    var key = Hive.generateSecureKey();
    await secureStorage.write(key: 'key', value: base64UrlEncode(key));
  }
  encryptionKey = base64Url.decode(await secureStorage.read(key: 'key'));
  await OpenedBox.initBox();
}

class OpenedBox {
  static Box<Wallet> addressInsance;
  static Box<ContactAddress> addressBookInsance;
  static Box<Nonce> nonceInsance;
  static Box<ChainGas> gasInsance;
  static Box<Network> netInstance;
  static Box<Token> tokenInstance;
  static Box<ChainWallet> walletInstance;
  static Box<CacheMessage> mesInstance;
  static Box<NonceUnit> nonceUnitInstance;
  static Box<LockBox> lockInstance;

  static Future initBox() async{
     addressInsance  = await Hive.openBox<Wallet>(HiveBoxType.addressBox, encryptionCipher: HiveAesCipher(encryptionKey));
     addressBookInsance = await Hive.openBox<ContactAddress>(HiveBoxType.addressBookBox, encryptionCipher: HiveAesCipher(encryptionKey));
     nonceInsance = await Hive.openBox<Nonce>(HiveBoxType.nonceBox, encryptionCipher: HiveAesCipher(encryptionKey));
     gasInsance = await Hive.openBox<ChainGas>(HiveBoxType.gasBox, encryptionCipher: HiveAesCipher(encryptionKey));
     netInstance =  await Hive.openBox<Network>(HiveBoxType.netBox, encryptionCipher: HiveAesCipher(encryptionKey));
     tokenInstance = await Hive.openBox<Token>(HiveBoxType.tokenBox, encryptionCipher: HiveAesCipher(encryptionKey));
     walletInstance = await Hive.openBox<ChainWallet>(HiveBoxType.walletBox, encryptionCipher: HiveAesCipher(encryptionKey));
     mesInstance = await Hive.openBox<CacheMessage>(HiveBoxType.cacheMessageBox, encryptionCipher: HiveAesCipher(encryptionKey));
     nonceUnitInstance = await Hive.openBox<NonceUnit>(HiveBoxType.nonceUnitBox, encryptionCipher: HiveAesCipher(encryptionKey));
     lockInstance  = await Hive.openBox<LockBox>(HiveBoxType.lockBox, encryptionCipher: HiveAesCipher(encryptionKey));
  }
}
