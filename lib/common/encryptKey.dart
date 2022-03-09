import 'dart:convert';
import 'package:fil/chain/key.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/models/private.dart';
import 'package:flutter/foundation.dart';
import 'global.dart';
import 'package:fil/common/argon2.dart';


Future<EncryptKey> getKey(String addressType, String pass, String mne, String prefix) async{
  EncryptKey key = await getKeyByArgon2(addressType, pass, mne, prefix);
  return key;
}


Future<EncryptKey> getKey2(String addressType, String privateKey,  String pass, Network net) async{
  EncryptKey key = await getKey2ByArgon2(addressType, privateKey,  pass, net);
  return key;
}

Future<EncryptKey> getKey2ByArgon2(String addressType, String privateKey,  String pass, Network net) async{
  EncryptKey key;
  switch(addressType){
    case 'eth':
      key = await EthWallet.genEncryptKeyByPrivateKey(privateKey, pass);
      break;
    default:
      PrivateKey filPk = PrivateKey.fromMap(jsonDecode(hex2str(privateKey)) as Map<String, dynamic>);
      var type = filPk.type == 'secp256k1' ? SignSecp : SignBls;
      var pk = filPk.privateKey;
      key = await FilecoinWallet.genEncryptKeyByPrivateKey(pk, pass, type: type, prefix: net.prefix);
      break;
  }
  return key;
}


Future<EncryptKey> getKeyByArgon2(String addressType, String pass, String mne, String prefix) async {
  EncryptKey key;
  switch(addressType){
    case 'eth':
      var ethPk =  await compute(EthWallet.genPrivateKeyByMne, mne);
      key = await EthWallet.genEncryptKeyByPrivateKey(ethPk, pass);
      break;
    default:
      var filPk = await compute(FilecoinWallet.genPrivateKeyByMne, mne);
      key =  await FilecoinWallet.genEncryptKeyByPrivateKey(filPk,pass, prefix: prefix);
      break;
  }
  return key;
}


Future<Map<String, EncryptKey>> getKeyMap(String mne, String pass) async{
  Map<String, EncryptKey> keyMap = {};
  var ethPk = await compute(EthWallet.genPrivateKeyByMne, mne);
  var filPk = await compute(FilecoinWallet.genPrivateKeyByMne, mne);
  keyMap['eth'] = await EthWallet.genEncryptKeyByPrivateKey(ethPk, pass);
  keyMap['filecoin'] =
  await FilecoinWallet.genEncryptKeyByPrivateKey(filPk, pass);
  keyMap['calibration'] =
  await FilecoinWallet.genEncryptKeyByPrivateKey(filPk, pass, prefix: 't');
  return keyMap;
}

Future<Map<String, EncryptKey>> getKeyMapToReset(String private, String pass) async{
  Map<String, EncryptKey> keyMap = {};
  keyMap['eth'] = await EthWallet.genEncryptKeyByPrivateKey(private, pass);
  keyMap['filecoin'] =  await FilecoinWallet.genEncryptKeyByPrivateKey(private, pass);
  keyMap['calibration'] =  await FilecoinWallet.genEncryptKeyByPrivateKey(private, pass, prefix: 't');
  return keyMap;
}

Future<String> getPrivateByKek(
    String pass, String kek, String address
    ) async {
  try {
    var private = await decryptSodium(kek, address, pass);
    var str = base64Decode(private);
    var sk = utf8.decode(str);
    return sk;
  }catch(e){
    return '';
  }
}


