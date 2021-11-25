
import 'dart:convert';
import 'dart:typed_data';
import 'package:fil/chain/key.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/common/argon2.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/models/private.dart';
import '../index.dart';
import 'global.dart';


Future<EncryptArgon> getKey(String addressType, String pass, String mne, String prefix) async{
  EncryptArgon encryptArgon = EncryptArgon();
  switch($store.encryptionType.value){
    case 'argon2':
      encryptArgon.argon2Key = await getKeyByArgon2(addressType, pass, mne, prefix);
      break;
    default:
      encryptArgon.encryptKey = await getKeyBysha256(addressType, pass, mne, prefix);
  }
  return encryptArgon;
}

Future<EncryptKey> getKeyBysha256(String addressType, String pass, String mne, String prefix) async {
  EncryptKey key;
  switch(addressType){
    case 'eth':
      var ethPk =  await compute(EthWallet.genPrivateKeyByMne, mne);
      key = await EthWallet.genEncryptKeyByPrivateKey(ethPk, pass);
      break;
    default:
      var filPk = await compute(FilecoinWallet.genPrivateKeyByMne, mne);
      key = await FilecoinWallet.genEncryptKeyByPrivateKey(filPk, pass, prefix: prefix??'f');
      break;
  }
  return key;
}

Future<Uint8List> getKeyByArgon2(String addressType, String pass, String mne, String prefix) async {
  Uint8List key;
  switch(addressType){
    case 'eth':
      var ethPk =  await compute(EthWallet.genPrivateKeyByMne, mne);
      var ethAddr = await EthWallet.genAddrByPrivateKey(ethPk);
      key = encryptSodium(ethPk, ethAddr, pass);
      break;
    default:
      var filPk = await compute(FilecoinWallet.genPrivateKeyByMne, mne);
      var filAddr =  await FilecoinWallet.genAddrByPrivateKey(filPk, prefix: prefix);
      key = encryptSodium(filPk, filAddr, pass);
      break;
  }
  return key;
}


Future<EncryptKey> getKey2(String addressType, String privateKey,  String pass, Network net) async{
  EncryptKey key;
  switch(addressType){
    case 'eth':
      key = await EthWallet.genEncryptKeyByPrivateKey(privateKey, pass);
      break;
    default:
      PrivateKey filPk = PrivateKey.fromMap(jsonDecode(hex2str(privateKey)));
      var type = filPk.type == 'secp256k1' ? SignSecp : SignBls;
      var pk = filPk.privateKey;
      key = await FilecoinWallet.genEncryptKeyByPrivateKey(pk, pass, type: type, prefix: net.prefix);
      break;
  }
  return key;
}
