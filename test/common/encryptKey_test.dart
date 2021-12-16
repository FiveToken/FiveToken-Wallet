
import 'package:fil/chain/index.dart';
import 'package:fil/common/argon2.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fil/common/encryptKey.dart';
void main() {
  String pass = '123456789012';
  String newPass = '123456789011';
  String resPass= '58ba3b6b227ec846312bdeff789e8469c9f128abac898daa07bf3f0e0355f638';
  ChainWallet wallet = ChainWallet(
    label: 'DD',
    address: '0x3fb4f280cf531ba7d88fe4d0748a451e4d4276ad',
    type: 2,
    balance: '400000000000000',
    mne: '',
    skKek: 'CGmTwXja66YS39Y3Lp5MmUWNRMx5mp8YBstteIJDpHjK9vTyoDfbahaRY6+/RF4NfhKqyzmWckA1ngd3CG+FDWzkKNeoqW9BiY4cA89D+x8=',
    digest: 'r57NXYt4/wElj612To5Rkg==',
    groupHash: '',
    addressType: 'eth',
    rpc: 'https://mainnet.infura.io/v3/'
  );
  var private = '8f867318b9326d4b8868b960187005f89ecf3d9bbf7fe963d627fcc1bdeb625d';
  var prefix = 'f';
  test('test common encrypt', () async {
    EncryptKey key = await getKey(wallet.addressType, private, newPass, prefix);
    print(key);
  });
}