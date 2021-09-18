import 'package:fil/index.dart';
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
      test('generate filecoin encrypt key', () async {
        var key1 = await FilecoinWallet.genEncryptKey(Mne, pass);
        var key2 =
            await FilecoinWallet.genEncryptKeyByPrivateKey(FilPrivate, pass);
        expect(key1.digest, key2.digest);
      });
      test('validate password', () async {
        var key = await FilecoinWallet.genEncryptKey(Mne, pass);
        var wallet = ChainWallet(
            digest: key.digest,
            skKek: key.kek,
            address: key.address,
            mne: aesEncrypt(Mne, key.private));
        var valid = await wallet.validatePrivateKey(pass);
        var p = await wallet.getPrivateKey(pass);
        expect(valid, true);
        expect(p, FilPrivate);
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
      test('generate eth encrypt key', () async {
        var key1 = await EthWallet.genEncryptKey(Mne, pass);
        var key2 = await EthWallet.genEncryptKeyByPrivateKey(EthPrivate, pass);
        expect(key1.digest, key2.digest);
      });
      test('validate password', () async {
        var key = await EthWallet.genEncryptKey(Mne, pass);
        var wallet = ChainWallet(
            digest: key.digest,
            skKek: key.kek,
            address: key.address,
            addressType: 'eth',
            mne: aesEncrypt(Mne, key.private));
        var valid = await wallet.validatePrivateKey(pass);
        var p = await wallet.getPrivateKey(pass);
        expect(valid, true);
        expect(p, EthPrivate);
      });
    });
  });
}
