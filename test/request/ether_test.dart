import 'dart:typed_data';
import 'package:fil/chain/contract.dart' show Contract;
import 'package:fil/chain/net.dart' show Network;
import 'package:fil/chain/token.dart';
import 'package:fil/models/gas_response.dart';
import 'package:fil/models/token_info.dart';
import 'package:fil/repository/web3/json_rpc.dart';
import 'package:fil/request/ether.dart';
import 'package:fil/store/store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';
import 'ether_test.mocks.dart';


@GenerateMocks([
  Ether,
  Web3Client,
  RpcJson,
  StoreController
])
void main() {
  final mockStoreController = MockStoreController();

  test('getBlockByNumber', () async {
    final web3Client = MockWeb3Client();
    final rpcJson = MockRpcJson();
    final ether = Ether(Network.binanceTestnet.rpc,
        web3client: web3Client, rpcJson: rpcJson);
    int blockNumber = 13802876;
    var xBlock = "0x${blockNumber.toRadixString(16)}";
    var _data = {
      "baseFeePerGas": "0x9d949800c",
      "gasUsed": "0x1c9c16b",
      "gasLimit": "0x1c9c380",
      "number": "0xd29d68",
      "timestamp": "0x61b876e5",
    };
    var response = RPCResponse(0, _data);
    when(rpcJson.call('eth_getBlockByNumber', [xBlock, false]))
        .thenAnswer((realInvocation) => Future.value(response));
    final res = await ether.getBlockByNumber(blockNumber);
    var result = response.result;
    var limit = hexToDartInt(result['gasLimit'] as String);
    var _limit = res.gasLimit;
    expect(limit, _limit);
  });

  test('getBlockByNumber', () async {
    final web3Client = MockWeb3Client();
    final rpcJson = MockRpcJson();
    final ether = Ether(Network.binanceTestnet.rpc,
        web3client: web3Client, rpcJson: rpcJson);
    int blockNumber = 13802876;
    var xBlock = "0x${blockNumber.toRadixString(16)}";
    var _data = {
      "baseFeePerGas": null,
      "gasUsed": "0x1c9c16b",
      "gasLimit": "0x1c9c380",
      "number": "0xd29d68",
      "timestamp": "0x61b876e5",
    };
    var response = RPCResponse(0, _data);
    when(rpcJson.call('eth_getBlockByNumber', [xBlock, false]))
        .thenAnswer((realInvocation) => Future.value(response));
    final res = await ether.getBlockByNumber(blockNumber);
    var result = response.result;
    var limit = hexToDartInt(result['gasLimit'] as String);
    var _limit = res.gasLimit;
    expect(limit, _limit);
  });

  test('getMaxPriorityFeePerGas', () async {
    final web3Client = MockWeb3Client();
    final rpcJson = MockRpcJson();
    final ether = Ether(Network.binanceTestnet.rpc,
        web3client: web3Client, rpcJson: rpcJson);
    var _data = {};
    var response = RPCResponse(0, '1');
    when(rpcJson.call('eth_maxPriorityFeePerGas'))
        .thenAnswer((realInvocation) => Future.value(response));
    final res = await ether.getMaxPriorityFeePerGas();
    expect(res, '1');
  });

  test('getBaseFeePerGas', () async {
    final web3Client = MockWeb3Client();
    final rpcJson = MockRpcJson();
    final ether = Ether(Network.binanceTestnet.rpc,
        web3client: web3Client, rpcJson: rpcJson);
    int blockNumber = 13802876;
    var xBlock = "0x${blockNumber.toRadixString(16)}";
    var _data = {
      "baseFeePerGas": "0x9d949800c",
      "gasUsed": "0x1c9c16b",
      "gasLimit": "0x1c9c380",
      "number": "0xd29d68",
      "timestamp": "0x61b876e5",
    };
    var response = RPCResponse(0, _data);
    when(rpcJson.call('eth_getBlockByNumber', [xBlock, false]))
        .thenAnswer((realInvocation) => Future.value(response));
    final _block = ether.getBlockByNumber(blockNumber);
    final res = await ether.getBaseFeePerGas();
    expect(res, '0');
  });


  test('getNetworkId', () async {
    final web3Client = MockWeb3Client();
    final ether = Ether(Network.binanceTestnet.rpc, web3client: web3Client);
    when(web3Client.getNetworkId())
        .thenAnswer((realInvocation) => Future.value(0));
    final id = await ether.getNetworkId();
    expect(id, '0');
  });

  test('getTokenInfo', () async {
    String address = '0x9343bc852c04690b239ec733c6f71d8816d436c3';
    var abi = ContractAbi.fromJson(Contract.abi, 'bnb');
    var con = DeployedContract(abi, EthereumAddress.fromHex(address));
    final web3Client = MockWeb3Client();
    final ether = Ether(Network.binanceTestnet.rpc, web3client: web3Client);
    when(
      web3Client.call(contract: con, function: con.function('symbol'), params: []),
    ).thenAnswer((realInvocation) => Future.value(['TODO']));

    when(web3Client.call(
        contract: con,
        function: con.function('decimals'),
        params: [])).thenAnswer((realInvocation) => Future.value(['18']));

    final id = await ether.getTokenInfo(address);
    expect(id.precision, '0');
  });

  test('get Gas', () async {
    final web3Client = MockWeb3Client();
    final ether = Ether(Network.binanceTestnet.rpc, web3client: web3Client);
    final from = '0x3FB4F280cF531Ba7d88Fe4D0748A451E4D4276AD';
    final to = '0xeA180cABCe6810640C44F613F23C323bCa8c39A6';
    final isToken = false;
    var toAddr = EthereumAddress.fromHex(to);

    when(web3Client.getGasPrice()).thenAnswer((realInvocation) =>
        Future.value(EtherAmount.fromUnitAndValue(EtherUnit.wei, 0)));

    when(web3Client.estimateGas(
            to: toAddr,
            value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 0)))
        .thenAnswer((realInvocation) => Future.value(BigInt.from(1)));
    var mockRes = GasResponse(gasState: "success", gasLimit: 1, gasPrice: '');
    final res =
        await ether.getGas(from: from, to: to, isToken: isToken, token: null);
    expect(res.gasLimit, mockRes.gasLimit);
  });

  test('get token Gas', () async {
    final web3Client = MockWeb3Client();
    final ether = Ether(Network.binanceTestnet.rpc, web3client: web3Client);
    final from = '0x3FB4F280cF531Ba7d88Fe4D0748A451E4D4276AD';
    final to = '0xeA180cABCe6810640C44F613F23C323bCa8c39A6';
    final isToken = true;
    final _data = {
      'symbol': 'TODO',
      'precision': 18,
      'address': '0x9343bc852c04690b239ec733c6f71d8816d436c3',
      'chain': '',
      'rpc': '',
      'balance': ''
    };
    Token token = Token.fromJson(_data);
    var fromAddress = EthereumAddress.fromHex(from);
    var toAddr = EthereumAddress.fromHex(to);

    var abi = ContractAbi.fromJson(Contract.abi, '');
    var con = DeployedContract(abi, EthereumAddress.fromHex(token.address));
    var data = con
        .function('transfer')
        .encodeCall([EthereumAddress.fromHex(to), BigInt.from(1)]);

    when(web3Client.getGasPrice()).thenAnswer((realInvocation) =>
        Future.value(EtherAmount.fromUnitAndValue(EtherUnit.wei, 0)));

    when(web3Client.estimateGas(
            to: EthereumAddress.fromHex(token.address),
            sender: fromAddress,
            data: data,
            value: EtherAmount.fromUnitAndValue(EtherUnit.wei, 0)))
        .thenAnswer((realInvocation) => Future.value(BigInt.from(1)));
    var mockRes = GasResponse(gasState: "success", gasLimit: 2, gasPrice: '');
    final res =
        await ether.getGas(from: from, to: to, isToken: isToken, token: token);
    expect(res.gasLimit, mockRes.gasLimit);
  });

  test('getTransactionReceipt', () async {
    final web3Client = MockWeb3Client();
    final ether = Ether(Network.binanceTestnet.rpc, web3client: web3Client);
    final hash =
        '0x8337787c017ad05f7ddfd18feb241894811eb3491c13e263d39a24299473c062';
    final result = TransactionReceipt(
        transactionHash: Uint8List.fromList([]),
        transactionIndex: 0,
        blockHash: Uint8List.fromList([]),
        cumulativeGasUsed: BigInt.zero);
    when(web3Client.getTransactionReceipt(hash)).thenAnswer((realInvocation) {
      return Future.value(result);
    });
    final res = await ether.getTransactionReceipt(hash);
    expect(res, result);
  });

  test('get balance', () async {
    final web3Client = MockWeb3Client();
    final ether = Ether(Network.binanceTestnet.rpc, web3client: web3Client);
    when(web3Client.getBalance(EthereumAddress.fromHex(
            '0x3bB395b668Ff9Cb84e55aadFC8e646Dd9184Da9d')))
        .thenAnswer((realInvocation) => Future.value(EtherAmount.zero()));
    final balance =
        await ether.getBalance('0x3bB395b668Ff9Cb84e55aadFC8e646Dd9184Da9d');
    expect(balance, '0');
  });

  test('get getBalanceOfToken', () async {
    final web3Client = MockWeb3Client();
    final ether = Ether(Network.binanceTestnet.rpc, web3client: web3Client);
    var abi = ContractAbi.fromJson(Contract.abi, 'bnb');
    final address = '0x3FB4F280cF531Ba7d88Fe4D0748A451E4D4276AD';
    final tokenAddress = '0x9343bc852c04690b239ec733c6f71d8816d436c3';
    var con = DeployedContract(abi, EthereumAddress.fromHex(tokenAddress));

    String balance = '0';
    when(web3Client.call(
            contract: con,
            function: con.function('balanceOf'),
            params: [EthereumAddress.fromHex(address)]))
        .thenAnswer((realInvocation) => Future.value([0]));
    final res = await ether.getBalanceOfToken(address, tokenAddress);
    expect(res, '0');
  });

  test('get getNonce', () async {
    final web3Client = MockWeb3Client();
    final address = '0x3FB4F280cF531Ba7d88Fe4D0748A451E4D4276AD';
    final ether = Ether(Network.binanceTestnet.rpc, web3client: web3Client);
    when(web3Client.getTransactionCount(EthereumAddress.fromHex(address)))
        .thenAnswer((realInvocation) => Future.value(1));
    final res = await ether.getNonce(address);
    expect(res, 1);
  });

  test('getFileCoinMessageList', () async {
    final web3Client = MockWeb3Client();
    final address = '0x3FB4F280cF531Ba7d88Fe4D0748A451E4D4276AD';
    final ether = Ether(Network.binanceTestnet.rpc, web3client: web3Client);
    final res = await ether.getFileCoinMessageList(
        actor: '', direction: '', mid: '', limit: 1);
    expect(res, []);
  });

  test('getMessagePendingState', () async {
    final web3Client = MockWeb3Client();
    final address = '0x3FB4F280cF531Ba7d88Fe4D0748A451E4D4276AD';
    final ether = Ether(Network.binanceTestnet.rpc, web3client: web3Client);
    final res = await ether.getMessagePendingState([]);
    expect(res, []);
  });

}
