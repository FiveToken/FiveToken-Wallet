class WalletType{
  static final id = 0; // identity
  static final mne = 1; // Mnemonic words
  static final privateKey = 2; //  Private key
}

class NetworkType{
  static final main = 0; // main
  static final test = 1;  // test
  static final custom = 2; // custom
}

class EncryptType{
  static final sha = 'sha256'; // encrypt sha256 Pbkdf2
  static final argon2 = 'argon2'; // encrypt argon2 libsodium
}

class HiveKey {
  static final key = 'key';
  static final secret = 'secret';
}

class GasTabBars {
  static final gearSelection = 'gearSelection';
  static final customize = 'customize';
}

class GasGear {
  static const high = 'high';
  static const middle = 'middle';
  static const low = 'low';
}

class RpcType {
  static const ethereumMain = 'ethereumMain';
  static const ethereumOthers = 'ethereumOthers';
  static const fileCoin = 'fileCoin';
}


class HiveBoxType{
  static final messageBox = 'messageBox';
  static final addressBox = 'addressBox';
  static final addressBookBox = 'addressBookBox';
  static final nonceBox = 'nonceBox';
  static final gasBox = 'gasBox';
  static final netBox = 'netBox';
  static final tokenBox = 'tokenBox';
  static final walletBox = 'walletBox';
  static final cacheMessageBox = 'cacheMessageBox';
  static final nonceUnitBox = 'nonceUnitBox';
  static final lockBox = 'lockBox';
  static  Map<String, dynamic> getMap() {
    final map = <String, dynamic>{};
    map['messageBox'] = messageBox.toString();
    map['addressBox'] = addressBox.toString();
    map['addressBookBox'] = addressBookBox.toString();
    map['nonceBox'] = nonceBox.toString();
    map['gasBox'] = gasBox.toString();
    map['netBox'] = netBox.toString();
    map['tokenBox'] = tokenBox.toString();
    map['walletBox'] = walletBox.toString();
    map['cacheMessageBox'] = cacheMessageBox.toString();
    map['nonceUnitBox'] = nonceUnitBox.toString();
    map['lockBox'] = lockBox.toString();
    return map;
  }
  static  Map<String, dynamic> getType() {
    final map = <String, dynamic>{};
    map['messageBox'] = 'messageBox';
    map['addressBox'] = 'Wallet';
    map['addressBookBox'] = 'ContactAddress';
    map['nonceBox'] = 'Nonce';
    map['gasBox'] = 'ChainGas';
    map['netBox'] = 'Network';
    map['tokenBox'] = 'Token';
    map['walletBox'] = 'ChainWallet';
    map['cacheMessageBox'] = 'CacheMessage';
    map['nonceUnitBox'] = 'NonceUnitBox';
    map['lockBox'] = 'Lock';
    return map;
  }
}