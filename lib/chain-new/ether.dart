import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:fil/repository/web3/web3.dart' as web3;
import 'package:fil/chain-new/provider.dart';
import 'package:fil/models-new/chain_gas.dart';
import 'package:fil/models-new/token.dart';
import 'package:fil/models-new/chain_info.dart';
import 'package:fil/models-new/rpc_network.dart';
import 'package:web3dart/web3dart.dart';

class Ether extends ChainProvider {
  Web3Client client;

  Ether(RpcNetwork network, {Web3Client web3client}) {
    this.network = network;
    client = web3client ?? web3.Web3(network.rpc).client;
  }

  @override
  Future<ChainInfo> getBlockByNumber(int number) async {
    try {
      String block = '0x${number.toRadixString(16)}';
      var res = await client.getBlockInformation(String block,false);
      return res;
    }catch (e){

    }
  }
  @override
  Future<int> getBlockByHash() async{

  }

  @override
  Future<String> getBalance(String address) async {
    try {
      debugPrint(address);
      var res = await client.getBalance(EthereumAddress.fromHex(address));
      return res.getInWei.toString();
    } catch (e) {
      if (e is FormatException) {
        debugPrint(jsonEncode(e.message));
      }
      return '0';
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
  Future<ChainGas> getGas(
      {String to, bool isToken = false, Token token}) async {
    var empty = ChainGas();
  }

  @override
  void dispose() {
    client.dispose();
  }
}
