import 'package:fil/chain/gas.dart';
import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:web3dart/web3dart.dart';

import '../constant.dart';

class DioAdapterMock extends Mock implements HttpClientAdapter {}

class Web3ClientMock extends Mock implements Web3Client {}

Future<ResponseBody> Function(Invocation realInvocation) getResponse(
    dynamic data) {
  return (Invocation realInvocation) async => ResponseBody.fromString(
          jsonEncode({'code': 200, 'message': '', 'data': data}), 200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          });
}

void main() {
  Get.put(StoreController());
  group("test filecoin provider", () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final MethodChannel c = MethodChannel('flotus');
    c.setMockMethodCallHandler((methodCall) async {
      switch (methodCall.method) {
        case 'messageCid':
          return 'test';
      }
    });
    FilecoinProvider provider;
    final addr = 'f1qcknm5qc2ml4zc7d5hhtlod5iqirh2c3nfudpvq';
    final client = Dio();
    final cid =
        'bafy2bzacecevvxf73dnm67tirhydw6ttb4n2qqxyvjuhp773scvprajk35gze';
    final dioAdapter = DioAdapterMock();
    provider = FilecoinProvider(Network.filecoinMainNet, httpClient: client);
    client.httpClientAdapter = dioAdapter;
    test("get balance", () async {
      when(dioAdapter.fetch(any, any, any))
          .thenAnswer(getResponse({'balance': '100'}));
      var res = await provider.getBalance(addr);
      expect(res, '100');
    });
    test("send transaction", () async {
      when(dioAdapter.fetch(any, any, any)).thenAnswer(getResponse(cid));
      var res = await provider.sendTransaction(
          gas: ChainGas(), private: FilPrivate, source: addr);
      expect(res, cid);
    });
    test("get message list", () async {
      var count = 10;
      when(dioAdapter.fetch(any, any, any)).thenAnswer(
          getResponse({'messages': List.generate(count, (index) => {})}));
      var res = await provider.getFilecoinMessageList();
      expect(res.length, count);
    });
    test("get nonce", () async {
      when(dioAdapter.fetch(any, any, any))
          .thenAnswer(getResponse({'nonce': 1}));
      var res = await provider.getNonce();
      expect(res, 1);
    });
    test("get gas", () async {
      when(dioAdapter.fetch(any, any, any)).thenAnswer(getResponse(
          {'gas_limit': 100, 'gas_premium': '120', 'gas_cap': '200'}));
      var res = await provider.getGas(to: addr);
      expect(res.gasLimit, 100);
      expect(res.gasPremium, '120');
      expect(res.gasPrice, '200');
    });
    test("replace gas", () {
      var gas = ChainGas(gasLimit: 100, gasPremium: '100', gasPrice: '200');
      var replaceGas = provider.replaceGas(gas, chainPremium: '150');
      expect(replaceGas.gasPremium, '150');
      expect(
          BigInt.tryParse(replaceGas.gasPrice) >
              BigInt.tryParse(replaceGas.gasPremium),
          true);
    });
  });
  group("test eth provider", () {
    EthProvider provider;
    var gas = ChainGas(gasLimit: 100, gasPrice: '100');
    final addr = EthAddr;
    final ethAddr = EthereumAddress.fromHex(EthAddr);
    var mockClient = Web3ClientMock();
    provider = EthProvider(Network.ethMainNet, web3client: mockClient);
    test("test get balance", () async {
      when(mockClient.getBalance(ethAddr)).thenAnswer(
          (realInvocation) async => EtherAmount.inWei(BigInt.from(100)));
      var res = await provider.getBalance(addr);
      expect(res, '100');
    });
    test("test get nonce", () async {
      when(mockClient.getTransactionCount(ethAddr))
          .thenAnswer((realInvocation) async => 1);
      var res = await provider.getNonce(from: addr);
      expect(res, 1);
    });
    test("test replace gas", () {
      var replaceGas = provider.replaceGas(gas);
      expect(replaceGas.gasLimit, gas.gasLimit);
      expect(int.parse(replaceGas.gasPrice) > int.parse(gas.gasPrice), true);
    });
    test('test get gas', () async {
      when(mockClient.estimateGas(
              to: ethAddr,
              value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 1)))
          .thenAnswer((realInvocation) async => BigInt.from(100));
      when(mockClient.getGasPrice()).thenAnswer(
          (realInvocation) async => EtherAmount.inWei(BigInt.from(100)));

      var gas = await provider.getGas(to: addr);
      expect(gas.gasLimit, 100);
      expect(gas.gasPrice, '100');
    });
    test('test get token gas', () async {
      when(mockClient.estimateGas(
              to: anyNamed('to'),
              sender: anyNamed('sender'),
              data: anyNamed('data'),
              value: anyNamed('value')))
          .thenAnswer((realInvocation) async => BigInt.from(100));
      when(mockClient.getGasPrice()).thenAnswer(
          (realInvocation) async => EtherAmount.inWei(BigInt.from(100)));

      var gas = await provider.getGas(
          to: addr, token: Token(address: addr), isToken: true);
      expect(gas.gasLimit, 200);
      expect(gas.gasPrice, '100');
    });
    test('test send transaction', () async {
      var cid =
          '0xffe3860b254eb2e6468ef6fe2a07d384f3eac21342892d2d5406f38eeaaca318';
      Credentials credentials = EthPrivateKey.fromHex(EthPrivate);
      when(mockClient.credentialsFromPrivateKey(EthPrivate))
          .thenAnswer((realInvocation) async => credentials);
      when(mockClient.sendTransaction(
        any,
        any,
      )).thenAnswer((realInvocation) async => cid);
      var res = await provider.sendTransaction(
          to: addr, amount: '1', private: EthPrivate, gas: gas, nonce: 1);
      expect(res, cid);
    });
    test('test send token', () async {
      var cid =
          '0xffe3860b254eb2e6468ef6fe2a07d384f3eac21342892d2d5406f38eeaaca318';
      Credentials credentials = EthPrivateKey.fromHex(EthPrivate);
      when(mockClient.credentialsFromPrivateKey(EthPrivate))
          .thenAnswer((realInvocation) async => credentials);
      when(mockClient.sendTransaction(
        any,
        any,
      )).thenAnswer((realInvocation) async => cid);
      var res = await provider.sendToken(
          to: addr,
          amount: '1',
          private: EthPrivate,
          gas: gas,
          nonce: 1,
          addr: addr);
      expect(res, cid);
    });
  });
}
