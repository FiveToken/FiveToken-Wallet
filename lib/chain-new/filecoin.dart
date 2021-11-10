import 'dart:convert';
import 'package:dio/dio.dart';
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

  Filecoin(String rpc, {Dio httpClient}) {
    this.rpc = rpc;
    client = httpClient ?? http;
    client.options.baseUrl = rpc + '/api$clientId';
  }

  @override
  Future<String> getBalance(String address) async {
    var balance = '0';
    try {
      var response =
      await client.get(balancePath, queryParameters: {'actor': address});
      balance = Token.fromJson(response.data).balance;
    } catch (e) {
      debugPrint(jsonEncode(e.message));
    }
    return balance;
  }

  @override
  Future<ChainInfo> getBlockByNumber(int number) async{
    return ChainInfo(
        gasUsed:BigInt.from(0),
        gasLimit:BigInt.from(0),
        blockHeight:BigInt.from(0),
        timestamp:BigInt.from(0)
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
  Future<List<Map<String, dynamic>>> getFilecoinMessageList(
      {String actor = '',
        String direction = 'down',
        String mid = '',
        int limit = 10}) async {
    List<Map<String, dynamic>> list = [];
    var res = await client.get(messageListPath, queryParameters: {
      'actor': actor,
      'direction': direction,
      'mid': mid,
      'limit': limit
    });
    var response = FilecoinResponse.fromJson(res.data);
    if (response.code != 200) {
      print(response.detail);
    } else {
      if (response.data != null &&
          response.data is Map &&
          response.data['messages'] is List) {
        list = (response.data['messages'] as List)
            .map((mes) => mes as Map<String, dynamic>)
            .toList();
      }
    }
    return list;
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
