class WalletType{
  static final id = 0; // identity
  static final mne = 1; // Mnemonic words
  static final privateKey = 2; //  Private key
}

class EncryptType{
  static final sha = 'sha256'; // encrypt sha256 Pbkdf2
  static final argon2 = 'argon2'; // encrypt argon2 libsodium
}

class HiveBoxType{
  static final messageBox = 'messageBox';
  static final addressBox = 'address';
  static final addressBookBox = 'addressBookBox';
  static final nonceBox = 'nonceBox';
  static final gasBox = 'gasBox';
  static final netBox = 'netBox';
  static final tokenBox = 'tokenBox';
  static final walletBox = 'walletBox';
  static final cacheMessageBox = 'cacheMessageBox';
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
    return map;
  }
}