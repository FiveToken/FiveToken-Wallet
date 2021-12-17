import 'package:fil/pages/transfer/transfer.dart';
import 'package:fil/utils/enum.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> maps = {
    'messageBox': 'messageBox',
    'addressBox' : 'addressBox',
    'addressBookBox' : 'addressBookBox',
    'nonceBox' : 'nonceBox',
    'gasBox' : 'gasBox',
    'netBox' : 'netBox',
    'tokenBox' : 'tokenBox',
    'walletBox' : 'walletBox',
    'cacheMessageBox' : 'cacheMessageBox',
    'nonceUnitBox' : 'nonceUnitBox',
    'lockBox' : 'lockBox'
  };
  Map<String, dynamic> mapTypes = {
  'messageBox' : 'messageBox',
  'addressBox' : 'Wallet',
  'addressBookBox' : 'ContactAddress',
  'nonceBox' : 'Nonce',
  'gasBox' : 'ChainGas',
  'netBox' : 'Network',
  'tokenBox' : 'Token',
  'walletBox' : 'ChainWallet',
  'cacheMessageBox' : 'CacheMessage',
  'nonceUnitBox' : 'NonceUnitBox',
  'lockBox' : 'Lock'
  };

  test("generate utils getMap ", () async {
    Map<String, dynamic> map = HiveBoxType.getMap();
    expect(map, maps);
  });
  test("generate utils getType ", () async {
    Map<String, dynamic> mapType = HiveBoxType.getType();
    expect(mapType, mapTypes);
  });
}