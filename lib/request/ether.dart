import 'dart:convert';
import 'dart:math';
import 'package:fil/chain/contract.dart';
import 'package:fil/chain/gas.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/models/token_info.dart';
import 'package:fil/repository/http/http.dart';
import 'package:fil/request/provider.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:fil/repository/web3/web3.dart' as web3;
import 'package:fil/models/chain_info.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:fil/repository/web3/json_rpc.dart';
import 'package:fil/config/config.dart';

class Ether extends ChainProvider {
  Web3Client client;
  RpcJson rpcJson;
  Ether(String rpc, {Web3Client web3client}) {
    this.rpc = rpc;
    final web3Rpc = web3.Web3(rpc);
    client = web3Rpc.client;
    rpcJson = web3Rpc.rpcJson;
  }

  @override
  Future<ChainInfo> getBlockByNumber(int number) async {
    try {
      final res = await rpcJson.call(
          'eth_getBlockByNumber', ['0x${number.toRadixString(16)}', false]);
      var result = res.result;
      return ChainInfo(
        gasUsed: hexToDartInt(result['gasUsed']),
        gasLimit:hexToDartInt(result['gasLimit']),
        number:hexToDartInt(result['number']),
        timestamp: hexToDartInt(result['timestamp']),
      );
      print('res');
      return result;
    } catch (error) {
      return ChainInfo(
        gasUsed: 0,
        gasLimit:0,
        number:0,
        timestamp: 0,
      );
    }
  }

  @override
  Future<String> getMaxPriorityFeePerGas() async{
    try {
      var res = await rpcJson.call('eth_maxPriorityFeePerGas');
      var maxPriority = hexToInt(res.result);
      var unit = BigInt.from(pow(10, 9));
      var result = maxPriority/unit;
      return result.toString();
    } catch (error) {
      return '0';
    }
  }

  @override
  Future<String> getMaxFeePerGas() async{
    try{
      int block = await client.getBlockNumber();
      var blockInfo = await getBlockByNumber(block);
      var maxFeePerGas = BigInt.from(blockInfo.baseFeePerGas) * BigInt.from(Config.baseFeePerGasToMaxFeePerGas);
      return maxFeePerGas.toString();
    }catch(error){
      return '0';
    }
  }

  @override
  Future<String> getBalance(String address) async {
    String balance = '0';
    try {
      var res = await client.getBalance(EthereumAddress.fromHex(address));
      balance = res.getInWei.toString();
    } catch (e) {
      if (e is FormatException) {
        debugPrint(jsonEncode(e.message));
      }
    }
    return balance;
  }

  @override
  Future<String> getBalanceOfToken(String mainAddress,String tokenAddress) async{
    var abi = ContractAbi.fromJson(Contract.abi, 'bnb');
    var con = DeployedContract(abi, EthereumAddress.fromHex(tokenAddress));
    String balance = '0';
    try {
      var list = await client.call(
          contract: con,
          function: con.function('balanceOf'),
          params: [EthereumAddress.fromHex(mainAddress)]);
      if (list.isNotEmpty) {
        var numStr = list[0];
        if (numStr is BigInt) {
          balance = numStr.toString();
        }
      }
      return balance;
    } catch (e) {
      return balance;
      print(e);
    }
  }

  @override
  Future<ChainGas> getGas({ String to, bool isToken = false, Token token }) async {
    var empty = ChainGas();
    var toAddr = EthereumAddress.fromHex(to);
    try {
      List<dynamic> res = [];
      if (token != null) {
        var abi = ContractAbi.fromJson(Contract.abi, '');
        var con = DeployedContract(abi, EthereumAddress.fromHex(token.address));
        var data = con
            .function('transfer')
            .encodeCall([EthereumAddress.fromHex(to), BigInt.from(1)]);
        res = await Future.wait([
          client.getGasPrice(),
          client.estimateGas(
              to: EthereumAddress.fromHex(token.address),
              sender: toAddr,
              data: data,
              value: EtherAmount.fromUnitAndValue(EtherUnit.wei, 0))
        ]);
      } else {
        res = await Future.wait([
          client.getGasPrice(),
          client.estimateGas(
              to: toAddr,
              value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 1))
        ]);
      }
      if (res.length == 2) {
        EtherAmount gasPrice = res[0];
        BigInt gasLimit = res[1];
        print(gasPrice);
        int realLimit = gasLimit.toInt();
        if (isToken) {
          realLimit = (gasLimit.toInt() * 2).truncate();
        }
        return ChainGas(
                gasLimit: realLimit,
                gasPrice: (gasPrice.getInWei).toString()
        );
      } else {
        return empty;
      }
    } catch (e) {
      print(e);
      return empty;
    }
  }

  @override
  Future<int> getNonce(String address) async {
    try {
      return await client.getTransactionCount(
          EthereumAddress.fromHex(address));
    } catch (e) {
      return -1;
    }
  }

  @override
  Future<String> sendTransaction(
      String from,
      String to,
      String amount,
      String private,
      ChainGas gas,
      int nonce
  ) async {
    try {
      var credentials = await client.credentialsFromPrivateKey(private);
      var res = await client.sendTransaction(
          credentials,
          Transaction(
            from:EthereumAddress.fromHex(from),
            to: EthereumAddress.fromHex(to),
            gasPrice: EtherAmount.inWei(BigInt.parse(gas.gasPrice)),
            maxGas: gas.gasLimit,
            nonce: nonce,
            value: EtherAmount.inWei(BigInt.parse(amount)),
          ),
          chainId: int.tryParse($store.net.chainId) ?? 1);
      print('res');
      return res;
    } catch (e) {
      print(e);
      return '';
    }
  }

  @override
  Future<String> sendToken(
      {String to,
        String amount,
        String private,
        ChainGas gas,
        String addr,
        int nonce}
    ) async {
    try {
      var credentials = await client.credentialsFromPrivateKey(private);
      var abi = ContractAbi.fromJson(Contract.abi, '');
      var con = DeployedContract(abi, EthereumAddress.fromHex(addr));
      var transaction = Transaction.callContract(
          contract: con,
          function: con.function('transfer'),
          parameters: [EthereumAddress.fromHex(to), BigInt.parse(amount)],
          maxGas: gas.gasLimit,
          nonce: nonce,
          gasPrice: EtherAmount.inWei(BigInt.parse(gas.gasPrice)));
      var res = await client.sendTransaction(credentials, transaction,
          chainId: int.tryParse($store.net.chainId) ?? 1);
      return res;
    } catch (e) {
      print(e);
      return '';
    }
  }

  @override
  Future<TokenInfo> getTokenInfo(String address) async{
    var empty = TokenInfo(
        symbol: '',
        precision:"0"
    );
    try{
      var abi = ContractAbi.fromJson(Contract.abi, 'bnb');
      var con = DeployedContract(abi, EthereumAddress.fromHex(address));

      var lists = await Future.wait([
        client.call(contract: con, function: con.function('symbol'), params: []),
        client.call(contract: con, function: con.function('decimals'), params: [])
      ]);
      if (lists.isNotEmpty) {
        var symbol = lists[0];
        var decimals = lists[1];
        if (symbol.isNotEmpty && decimals.isNotEmpty) {
          return TokenInfo(
              symbol: symbol[0].toString(),
              precision: decimals[0].toString()
          );
        } else {
          return empty;
        }
      }
    }catch(error){
      print('error');
      return empty;
    }
  }

  @override
  Future<String> getNetworkId() async{
    try{
      var id = await client.getNetworkId();
      return id.toString();
    }catch(error){
      print('error');
    }
  }

  @override
  Future getTransactionReceipt(String hash) async{
    try{
        var res = await client.getTransactionReceipt(hash);
        return res;
    }catch(error){

    }
  }

  @override
  Future<List> getTokenPrice(param) async{
    try{
      String baseApi = 'https://api.fivetoken.io' + '/api' + Config.clientID;
      String tokenPrice = '/token/prices';
      var res = [];
      final response = await http.post(baseApi+tokenPrice,data: param);
      if(response.statusCode == 200){
        res = response.data;
      }
      return res;
    }catch(error){
      return [];
    }
  }

  @override
  Future<bool> addressCheck(String address) async{
    return false;
  }

  @override
  Future<List> getFileCoinMessageList({String actor ,String direction, String mid,int limit}) async{
    return [];
  }

  @override
  Future<List> getMessagePendingState(List param) async{
    return [];
  }

  @override
  void dispose() {
    client.dispose();
  }
}
