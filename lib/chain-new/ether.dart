import 'dart:convert';
import 'package:fil/chain/contract.dart';
import 'package:fil/chain/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:fil/repository/web3/web3.dart' as web3;
import 'package:fil/chain-new/provider.dart';
import 'package:fil/models-new/chain_gas.dart';
import 'package:fil/models-new/chain_info.dart';
import 'package:web3dart/web3dart.dart';
import 'package:fil/repository/web3/json_rpc.dart';

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
  Future<ChainGas> getGas(
      {String to, bool isToken = false, Token token}) async {
    var empty = ChainGas();
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
