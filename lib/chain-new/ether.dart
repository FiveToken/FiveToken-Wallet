import 'dart:convert';
import 'dart:math';
import 'package:fil/chain/contract.dart';
import 'package:fil/chain/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:fil/repository/web3/web3.dart' as web3;
import 'package:fil/chain-new/provider.dart';
import 'package:fil/models-new/chain_gas.dart';
import 'package:fil/models-new/chain_info.dart';
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
    // client = web3client ?? Web3Client(net.url, http.Client());
    rpcJson = web3Rpc.rpcJson;
  }

  @override
  Future<ChainInfo> getBlockByNumber(int number) async {
    try {
      final res = await rpcJson.call(
          'eth_getBlockByNumber', ['0x${number.toRadixString(16)}', false]);
      return ChainInfo.fromJson(res.result);
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
      var unit = BigInt.from(pow(10, 9));
      var maxFeePerGas = BigInt.from(blockInfo.baseFeePerGas) * BigInt.from(Config.baseFeePerGasToMaxFeePerGas)/unit;
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
        var unit = BigInt.from(pow(10, 9));
        return ChainGas(
                gasLimit: realLimit,
                gasPrice: (gasPrice.getInWei/unit).toString()
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
  Future<int> getNonce({String from}) async {}

  @override
  ChainGas replaceGas(ChainGas gas, {String chainPremium}) {
    return ChainGas(
        gasLimit: gas.gasLimit,
        gasPrice: (int.parse(gas.gasPrice) * 1.2).truncate().toString());
  }

  @override
  Future<String> sendTransaction(
      {String to,
        String amount,
        String private,
        ChainGas gas,
        int nonce}) async {
    try {
      final credentials = EthPrivateKey.fromHex(private);
    } catch (e) {}
  }

  Future<String> sendToken(
      {String to,
        String amount,
        String private,
        ChainGas gas,
        String addr,
        int nonce}) async {
    try {
      final credentials = EthPrivateKey.fromHex(private);
    } catch (e) {

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
  Future<List> getFileCoinMessageList({String actor ,String direction, String mid,int limit}) async{ }

  @override
  Future<List> getMessagePendingState(List param) async{}

  @override
  void dispose() {
    client.dispose();
  }
}
