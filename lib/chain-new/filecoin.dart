import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fil/models-new/message_pending.dart';
import 'package:fil/models-new/message_pending_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:fil/repository/http/http.dart';
import 'package:fil/chain-new/provider.dart';
import 'package:fil/config/constant.dart';
import 'package:fil/models-new/chain_gas.dart';
import 'package:fil/models-new/token.dart';
import 'package:fil/models-new/chain_info.dart';
import 'package:fil/models-new/filecoin_response.dart';

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


  // var response = FilecoinResponse.fromJson(res.data);
  // if (response.code != 200) {
  //   print(response.detail);
  // } else {
  //   if (response.data != null &&
  //       response.data is Map &&
  //       response.data['messages'] is List) {
  //     list = (response.data['messages'] as List)
  //         .map((mes) => mes as Map<String, dynamic>)
  //         .toList();
  //   }
  // }
  // return list;

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
    // TODO: implement getGas
  }

  @override
  Future<ChainGas> getGas(
      {String to, bool isToken = false, Token token}) async {
    // TODO: implement getGas
  }

  @override
  Future getTransactionReceipt(String hash) async{
    return null;
  }

  @override
  void dispose() {}
}
