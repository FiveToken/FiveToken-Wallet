
import 'dart:convert';

import 'package:fil/chain/key.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/models/private.dart';

import '../index.dart';
import 'global.dart';


Future<EncryptKey> getKey(String addressType, String pass, String mne, String prefix) async {
  EncryptKey key;
  switch(addressType){
    case 'eth':
      var ethPk =  await compute(EthWallet.genPrivateKeyByMne, mne);
      key = await EthWallet.genEncryptKeyByPrivateKey(ethPk, pass);
      break;
    case 'filecoin':
      var filPk = await compute(FilecoinWallet.genPrivateKeyByMne, mne);
      key = await FilecoinWallet.genEncryptKeyByPrivateKey(filPk, pass);
      break;
    case 'calibration':
      var filPk = await compute(FilecoinWallet.genPrivateKeyByMne, mne);
      key = await FilecoinWallet.genEncryptKeyByPrivateKey(filPk, pass, prefix: prefix);
      break;
    default:
      var filPk = await compute(FilecoinWallet.genPrivateKeyByMne, mne);
      key = await FilecoinWallet.genEncryptKeyByPrivateKey(filPk, pass);
      break;

  }
  return key;
}

// Future<EncryptKey> getKey2(String addressType, String privateKey,  String pass) async{
//   EncryptKey key;
//   switch(addressType){
//     case 'eth':
//       key = await EthWallet.genEncryptKeyByPrivateKey(privateKey, pass);
//       break;
//     default:
//       PrivateKey filPk = PrivateKey.fromMap(jsonDecode(hex2str(privateKey)));
//       var type = filPk.type == 'secp256k1' ? SignSecp : SignBls;
//       var pk = filPk.privateKey;
//       key = await FilecoinWallet.genEncryptKeyByPrivateKey(pk, pass, type: type, prefix: net.prefix);
//       break;
//   }
//   return key;
// }

class EncryptKeys{
  static String encryptType = 'sha256';

  // static String getKey() => getkey2();

}