import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fil/chain/token.dart';
import 'package:flutter/cupertino.dart';
import 'package:fil/repository/http/http.dart';
import 'package:fil/chain-new/provider.dart';
import 'package:fil/config/constant.dart';
import 'package:fil/models-new/chain_gas.dart';
import 'package:fil/models-new/chain_info.dart';

class Filecoin extends ChainProvider {
  Dio client;
  static String balancePath = '/actor/balance';
  static String pushPath = '/message';
  static String messageListPath = '/actor/messages';
  static String feePath = '/recommend/fee';
  static String clientId = clientID;
  static String messagePending = '/message/pending';

  Filecoin(String rpc, {Dio httpClient}) {
    this.rpc = rpc;
    client = httpClient ?? http;
    client.options.baseUrl = rpc + '/api$clientId';
  }

  @override
  Future<String> getBalance(String address) async {
    String balance = '0';
    try {
      var result =  await client.get(balancePath, queryParameters: {'actor': address});
      debugPrint("========" + jsonEncode(result.data));
        Map<String, dynamic> data = result.data;
        balance = data['balance'];

    } catch (e) {
      debugPrint(jsonEncode(e.message));
    }
    return balance;
  }

  @override
  Future<ChainInfo> getBlockByNumber(int number) async{
    return ChainInfo(
      gasUsed: 0,
      gasLimit:0,
      number:0,
      timestamp: 0,
    );
  }

  @override
  Future<String> sendTransaction(
      {String to,
        String amount,
        String private,
        ChainGas gas,
        int nonce}) async {
    try {
      return '';
    } catch (e) {
      return '';
    }
  }

  @override
  Future<List> getFileCoinMessageList(
      {String actor = '',
        String direction = 'down',
        String mid = '',
        int limit = 10}) async {
    List list = [];
    var res = await client.get(messageListPath, queryParameters: {
      'actor': actor,
      'direction': direction,
      'mid': mid,
      'limit': limit
    });
    if( res.data is Map &&  res.data['messages'] is List){
        list = res.data['messages'];
    }
    return list;
  }


  @override
  Future<ChainGas> getGas(
      {String to, bool isToken = false, Token token}) async {
    var empty = ChainGas();
    var result = await client
        .get(feePath, queryParameters: {'method': 'Send', 'actor': to});
    var res = result.data;
    if (res != null) {
      var limit = res['gas_limit'] ?? 0;
      var premium = res['gas_premium'] ?? '100000';
      var feeCap = res['gas_cap'] ?? '0';
      try {
        var limitNum = limit;
        var premiumNum = int.tryParse(premium) ?? 0;
        var feeCapNum = int.tryParse(feeCap) ?? 0;
        return ChainGas(
            gasFeeCap: feeCapNum.toString(),
            gasPremium: premiumNum.toString(),
            gasLimit: limitNum);
      } catch (e) {
        return empty;
      }
    } else {
      return empty;
    }
  }

  @override
  Future<List> getMessagePendingState(List param) async{
    try {
      var result =  await client.post(messagePending, data: param );
      return result.data ?? [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<int> getNonce() async {
    // TODO: implement getNonce
  }

  @override
  ChainGas replaceGas(ChainGas gas, {String chainPremium}) {
    var caculatePremium = (int.parse(gas.gasPremium) * 1.3).truncate();
    var realPremium = int.parse(chainPremium) > caculatePremium ? int.parse(chainPremium): caculatePremium;
    var oldPrice = int.parse(gas.gasPrice);
    var realPrice = oldPrice <= realPremium ? realPremium + 100 : oldPrice;
    return ChainGas(
        gasLimit: gas.gasLimit,
        gasPremium: realPremium.toString(),
        gasPrice: realPrice.toString());
  }


  @override
  Future getTransactionReceipt(String hash) async{
    return null;
  }

  @override
  Future<String> getBalanceOfToken(String mainAddress,String tokenAddress) async{
    return '0';
  }

  @override
  Future<String> getMaxPriorityFeePerGas() async{
    return "0";
  }

  @override
  Future<String> getMaxFeePerGas() async{
    return "0";
  }
  @override
  void dispose() {}
}
