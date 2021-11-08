import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:fil/chain/provider.dart';
import 'package:fil/config/constant.dart';
import 'package:fil/models-new/chain_gas.dart';
import 'package:fil/models-new/rpc_network.dart';
import 'package:fil/models-new/token.dart';
import 'package:fil/repository/http/http.dart';

class Filecoin extends ChainProvider {
  Dio client;
  static String balancePath = '/actor/balance';
  static String pushPath = '/message';
  static String messageListPath = '/actor/messages';
  static String feePath = '/recommend/fee';
  static String clientId = clientID;

  Filecoin(RpcNetwork network, {Dio httpClient}) {
    this.network = network;
    client = httpClient ?? http;
    client.options.baseUrl = network.rpc + '/api$clientId';
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
  Future<String> sendTransaction(
      {String to,
        String amount,
        String private,
        ChainGas gas,
        String source,
        int nonce}) async {
    return '';
  }

  Future<List<Map<String, dynamic>>> getFilecoinMessageList(
      {String actor = '',
        String direction = 'down',
        String mid = '',
        int limit = 10}) async {
    List<Map<String, dynamic>> list = [];
    // TODO: implement getFilecoinMessageList
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
  void dispose() {}
}
