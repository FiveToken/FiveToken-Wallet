import 'dart:convert';
import 'dart:math';
import 'package:fil/chain/contract.dart';
import 'package:fil/chain/gas.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/models/gas_response.dart';
import 'package:fil/models/token_info.dart';
import 'package:fil/models/transaction_response.dart';
import 'package:fil/repository/http/http.dart';
import 'package:fil/request/provider.dart';
import 'package:fil/store/store.dart';
import 'package:fil/utils/enum.dart';
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
  Ether(String rpc, {Web3Client web3client,RpcJson rpcJson}) {
    this.rpc = rpc;
    final web3Rpc = web3.Web3(rpc);
    client = web3client ?? web3Rpc.client;
    this.rpcJson =  rpcJson ?? web3Rpc.rpcJson;
  }

  @override
  Future<ChainInfo> getBlockByNumber(int number) async {
    try {
      final res = await rpcJson.call(
          'eth_getBlockByNumber', ['0x${number.toRadixString(16)}', false]);
      var result = res.result;
      if(result['baseFeePerGas'] != null){
        return ChainInfo(
            gasUsed: hexToDartInt(result['gasUsed']),
            gasLimit:hexToDartInt(result['gasLimit']),
            number:hexToDartInt(result['number']),
            timestamp: hexToDartInt(result['timestamp']),
            baseFeePerGas:hexToDartInt(result['baseFeePerGas'])
        );
      }else{
        return ChainInfo(
            gasUsed: hexToDartInt(result['gasUsed']),
            gasLimit:hexToDartInt(result['gasLimit']),
            number:hexToDartInt(result['number']),
            timestamp: hexToDartInt(result['timestamp'])
        );
      }
    } catch (error) {
      return ChainInfo(
        gasUsed: 0,
        gasLimit:0,
        number:0,
        timestamp: 0,
          baseFeePerGas:0
      );
    }
  }

  @override
  Future<String> getMaxPriorityFeePerGas() async{
    try {
      var res = await rpcJson.call('eth_maxPriorityFeePerGas');
      var maxPriority = hexToInt(res.result);
      return maxPriority.toString();
    } catch (error) {
      return '0';
    }
  }

  @override
  Future<String> getBaseFeePerGas() async{
    try{
      int block = await client.getBlockNumber();
      var blockInfo = await getBlockByNumber(block);
      var baseFee = blockInfo.baseFeePerGas;
      return baseFee.toString();
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
      throw(e);
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
    }
  }

  @override
  Future<GasResponse> getGas({String from, String to, bool isToken = false, Token token }) async {
    var empty = GasResponse();
    var fromAddress = EthereumAddress.fromHex(from);
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
              sender: fromAddress,
              data: data,
              value: EtherAmount.fromUnitAndValue(EtherUnit.wei, 0))
        ]);
      } else {
        res = await Future.wait([
          client.getGasPrice(),
          client.estimateGas(
              to: toAddr,
              value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 0))
        ]);
      }
      if (res.length == 2) {
        EtherAmount gasPrice = res[0];
        BigInt gasLimit = res[1];
        int realLimit = gasLimit.toInt();
        if (isToken) {
          realLimit = (gasLimit.toInt() * 2).truncate();
        }
        return GasResponse(
          gasState: "success",
          gasLimit: realLimit,
          gasPrice: (gasPrice.getInWei).toString()
        );
      } else {
        return GasResponse(
            gasState: "error",
            gasLimit: 0,
            gasPrice: ''
        );
      }
    } catch (error) {
      if(error.message.isNotEmpty){
        return GasResponse(
            gasState: "error",
            message: error.message
        );
      }else{
        return GasResponse(
            gasState: "error",
            message: ''
        );
      }
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
  Future<TransactionResponse> sendTransaction(
      String from,
      String to,
      String amount,
      String private,
      ChainGas gas,
      int nonce
  ) async {
    try {
      var credentials = await client.credentialsFromPrivateKey(private);
      var _transaction;
      if(gas.rpcType == RpcType.ethereumMain){
        _transaction = Transaction(
          from:EthereumAddress.fromHex(from),
          to: EthereumAddress.fromHex(to),
          maxFeePerGas: EtherAmount.inWei(BigInt.parse(gas.maxFeePerGas)),
          maxPriorityFeePerGas: EtherAmount.inWei(BigInt.parse(gas.maxPriorityFee)),
          maxGas: gas.gasLimit,
          nonce: nonce,
          value: EtherAmount.inWei(BigInt.parse(amount)),
        );
      }else{
        _transaction = Transaction(
          from:EthereumAddress.fromHex(from),
          to: EthereumAddress.fromHex(to),
          gasPrice: EtherAmount.inWei(BigInt.parse(gas.gasPrice)),
          maxGas: gas.gasLimit,
          nonce: nonce,
          value: EtherAmount.inWei(BigInt.parse(amount)),
        );
      }
      var res = await client.sendTransaction(
          credentials,
          _transaction,
          chainId: int.tryParse($store.net.chainId) ?? 1);
      return TransactionResponse(
        cid: res,
        message: ''
      );
    } catch (e) {
      return TransactionResponse(
          cid:'',
          message: e.message ?? ''
      );
    }
  }

  @override
  Future<TransactionResponse> sendToken(
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
      return TransactionResponse(
        cid: res, message: ''
      );
    } catch (e) {
      return TransactionResponse(
        cid: '', message:e.message
      );
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
      return empty;
    }
  }

  @override
  Future<String> getNetworkId() async{
    try{
      var id = await client.getNetworkId();
      return id.toString();
    }catch(error){
      throw(error);
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
