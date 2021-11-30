import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:fil/chain/key.dart';
import 'package:fil/index.dart';
import 'package:web3dart/web3dart.dart';
import 'package:fil/common/argon2.dart';
import 'dart:typed_data';
part 'wallet.g.dart';

@HiveType(typeId: 9)
class ChainWallet {
  @HiveField(0)
  String label;
  // @HiveField(1)
  // String ck;
  @HiveField(1)
  String address;
  @HiveField(2)
  int type;
  @HiveField(3)
  String balance;
  @HiveField(4)
  String mne;
  @HiveField(5)
  String skKek;
  @HiveField(6)
  String digest;
  @HiveField(7)
  String groupHash;
  @HiveField(8)
  String addressType;
  @HiveField(9)
  String rpc;
  String get addr => address;
  String get key => '$address\_$rpc\_$type';
  String get formatBalance => formatCoin(balance);
  ChainWallet(
      {this.label = '',
      this.address = '',
      this.type = 0,
      this.balance = '0',
      this.mne = '',
      this.skKek = '',
      this.digest = '',
      this.groupHash = '',
      this.rpc = '',
      this.addressType = ''});
  ChainWallet.fromJson(Map<dynamic, dynamic> json) {
    this.label = json['label'] as String;
    this.address = json['address'] as String;
    this.type = json['type'] as int;
    this.balance = json['balance'] as String;
    this.mne = json['mne'] as String;
    this.skKek = json['skKek'] as String;
    this.digest = json['digest'] as String;
    this.groupHash = json['groupHash'] as String;
    this.addressType = json['addressType'] as String;
    this.rpc = json['rpc'] as String;
  }
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'label': this.label,
      'address': this.address,
      'type': this.type,
      'balance': this.balance,
      "mne": this.mne,
      'skKek': this.skKek,
      'digest': this.digest,
      'groupHash': this.groupHash,
      'addressType': this.addressType,
      'rpc': this.rpc
    };
  }

  ChainWallet copyWith() {
    return ChainWallet(
        label: label,
        address: address,
        addressType: addressType,
        balance: balance,
        mne: mne,
        groupHash: groupHash,
        digest: digest,
        rpc: rpc,
        type: type,
        skKek: skKek);
  }

  ChainWallet genWallet(String type) {
    switch (type) {
      case 'filecoin':
        return FilecoinWallet.fromJson(this.toJson());
      case 'eth':
        return EthWallet.fromJson(this.toJson());
      default:
        return FilecoinWallet.fromJson(this.toJson());
    }
  }

  Future<bool> validatePrivateKey(
    String pass,
  ) async {
    try {
      var private = await decryptSodium(skKek, address, pass);
      var str = base64Decode(private);
      var str1 = utf8.decode(str);
      var digest = await argon2Crypt(str1);
      if (this.digest != digest) {
        return false;
      } else {
        return true;
      }
    }catch(e){
      print(e);
      return false;
    }
  }

  Future<String> getPrivateKey(
    String pass,
  ) async {
    try {
      var private = decryptSodium(skKek, address, pass);
      var str = base64Decode(private);
      var sk = utf8.decode(str);
      var res = addressType == 'eth' ? hex.encode(base64Decode(sk)) : sk;
      return res;
    }catch(e){
      print(e);
    }
  }
}

class FilecoinWallet extends ChainWallet {
  FilecoinWallet.fromJson(Map<String, dynamic> map) : super.fromJson(map);
  static Future<String> genAddrByMne(String m) async {
    var ck = genCKBase64(m);
    var pk = await Flotus.secpPrivateToPublic(ck: ck);
    String address = await Flotus.genAddress(pk: pk, t: SignSecp);
    return address.substring(1);
  }

  static String genPrivateKeyByMne(String m) {
    var ck = genCKBase64(m);
    return ck;
  }

  static Future<String> genAddrByPrivateKey(
      String ck,
      {
        String type = SignSecp,
        String prefix = 'f'
      }
      ) async {
    String pk = '';
    if (type == SignSecp) {
      pk = await Flotus.secpPrivateToPublic(ck: ck);
    } else {
      pk = await Bls.pkgen(num: ck);
    }
    String address = await Flotus.genAddress(pk: pk, t: type);
    return prefix + address.substring(1);
  }

  static Future<EncryptKey> genEncryptKey(String mne, String pass) async {
    try {
      var filPrivateKey = FilecoinWallet.genPrivateKeyByMne(mne);
      var filAddr = await FilecoinWallet.genAddrByPrivateKey(filPrivateKey);
      var filKek = encryptSodium(filPrivateKey, filAddr, pass);
      var filDigest = await argon2Crypt(filPrivateKey);
      return EncryptKey(
          kek: filKek,
          digest: filDigest,
          address: filAddr,
          private: filPrivateKey);
    } catch (e) {
      throw (e);
    }
  }

  static Future<EncryptKey> genEncryptKeyByPrivateKey(
      String privateKey, String pass,
      {String type = SignSecp, String prefix = 'f'}) async {
    try {
      // var filPrivateKey = FilecoinWallet.genPrivateKeyByMne(mne);
      var filAddr = await FilecoinWallet.genAddrByPrivateKey(privateKey,
          type: type, prefix: prefix);
      var filKek = encryptSodium(privateKey,filAddr, pass);
      var filDigest = await argon2Crypt(privateKey);
      return EncryptKey(
          kek: filKek,
          digest: filDigest,
          address: filAddr,   // publicKey
          private: privateKey);  // value
    } catch (e) {
      throw (e);
    }
  }
}

// genPrivateKeyByMne
// genAddrByMne
// genAddrByPrivateKey
// genEncryptKey
// genEncryptKeyByPrivateKey

class EthWallet extends ChainWallet {
  EthWallet.fromJson(Map<String, dynamic> map) : super.fromJson(map);
  static String genPrivateKeyByMne(String m) {
    var ck = genCKBase64(m, path:"m/44'/60'/0'/0");
    return ck;
  }

  static Future<String> genAddrByMne(
    String m,
  ) async {
    var pk = EthWallet.genPrivateKeyByMne(m);
    return EthWallet.genAddrByPrivateKey(pk);
  }

  static Future<String> genAddrByPrivateKey(String pk) async {
    try {
      var addr = await EthPrivateKey.fromHex(pk).extractAddress();
      return addr.hex;
    }catch(e){
      print(e);
    }
    }

  static Future<EncryptKey> genEncryptKey(String mne, String pass) async {
    try {
      var ethPrivateKey = EthWallet.genPrivateKeyByMne(mne);
      var ethAddr = await EthWallet.genAddrByPrivateKey(ethPrivateKey);
      var ethKek = encryptSodium(ethPrivateKey, ethAddr, pass);
      var ethDigest = await argon2Crypt(ethPrivateKey);
      return EncryptKey(
          kek: ethKek,
          digest: ethDigest,
          address: ethAddr,
          private: ethPrivateKey);
    } catch (e) {
      throw (e);
    }
  }

  static Future<EncryptKey> genEncryptKeyByPrivateKey(
      String privateKey, String pass) async {
    try{
      var ethAddr = await EthWallet.genAddrByPrivateKey(privateKey);
      var kek = encryptSodium(privateKey, ethAddr, pass);
      var ethDigest = await argon2Crypt(privateKey);
      return EncryptKey(
          kek: kek,
          digest: ethDigest,
          address: ethAddr,
          private: privateKey
      );
    }catch(e){
      print(e);
      throw(e);
    }
  }
}
