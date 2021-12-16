import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/common/utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../constant.dart';

void main() {
  group("test chain wallet", () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final MethodChannel channel = MethodChannel('flotus');
    final prefix = Network.filecoinMainNet.prefix;
    final pass = 'fivetoken';
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'secpPrivateToPublic':
          return '';
        case 'genAddress':
          return FilAddr;
      }
    });
    group('super class', () {
      var wallet = ChainWallet(
          label: "wallet",
          address: EthAddr,
          addressType: 'eth',
          type: 0,
          balance: '0',
          mne: '',
          groupHash: '',
          digest: '',
          skKek: '',
          rpc: '');

      test('test copy method', () {
        var walletStr = wallet.toString();
        var copyStr = wallet.copyWith().toString();
        expect(walletStr, copyStr);
      });
      test("test method", () {
        var json = wallet.toJson();
        var wal = ChainWallet.fromJson(json);
        expect(wallet.key, wal.key);
      });
      test("get sub class", () {
        expect(wallet.genWallet('eth') is EthWallet, true);
      });
    });
    group('test filecoin', () {
      test('generate filecoin address by mne', () async {
        var addr = await FilecoinWallet.genAddrByMne(Mne);
        expect(prefix + addr, FilAddr);
      });
      test('generate filecoin private key', () async {
        var pk = FilecoinWallet.genPrivateKeyByMne(Mne);
        expect(pk, FilPrivate);
      });
      test('generate filecoin address by private', () async {
        var addr = await FilecoinWallet.genAddrByPrivateKey(FilPrivate);
        expect(addr, FilAddr);
      });
    });
    group('test eth', () {
      test('generate eth address by mne', () async {
        var addr = await EthWallet.genAddrByMne(Mne);
        expect(addr, EthAddr);
      });
      test('generate eth private key', () async {
        var pk = EthWallet.genPrivateKeyByMne(Mne);
        expect(pk, EthPrivate);
      });
      test('generate eth address by private', () async {
        var addr = await EthWallet.genAddrByPrivateKey(EthPrivate);
        expect(addr, EthAddr);
      });
    });
  });
}
