import 'dart:convert';
import 'package:bls/bls.dart';
import 'package:dio/dio.dart';
import 'package:fil/chain/gas.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/common/global.dart';
import 'package:fil/models/filMessage.dart';
import 'package:fil/request/provider.dart';
import 'package:flotus/flotus.dart';
import 'package:flutter/cupertino.dart';
import 'package:fil/repository/http/http.dart';
import 'package:fil/config/config.dart';
import 'package:fil/models/chain_info.dart';

class Filecoin extends ChainProvider {
  Dio client;
  static String balancePath = '/actor/balance';
  static String pushPath = '/message';
  static String messageListPath = '/actor/messages';
  static String feePath = '/recommend/fee';
  static String clientId = Config.clientID;
  static String messagePending = '/message/pending';
  static String tokenPrice = '/token/prices';
  static String addrCheck = '/address/check';

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
        if(result.data != null){
          balance = result.data['balance'];
        }
      return balance;
    } catch (e) {
      return balance;
      debugPrint(jsonEncode(e.message));
    }
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
      String from,
      String to,
      String amount,
      String private,
      ChainGas gas,
      int nonce,
  ) async {
    var msg = TMessage(
        version: 0,
        method: 0,
        nonce: nonce,
        from: from,
        to: to,
        params: "",
        value: amount,
        gasFeeCap: gas.gasFeeCap,
        gasLimit: gas.gasLimit,
        gasPremium: gas.gasPremium);
    try {
      String sign = '';
      num signType;
      var cid = await Flotus.messageCid(msg: jsonEncode(msg));
      if (from[1] == '1') {
        signType = SignTypeSecp;
        sign = await Flotus.secpSign(ck: private, msg: cid);
      } else {
        signType = SignTypeBls;
        sign = await Bls.cksign(num: "$private $cid");
      }
      var sm = SignedMessage(msg, Signature(signType, sign));
      print(cid);
      print(jsonEncode(sm.toLotusSignedMessage()));
      String res = '';
      var result = await client.post(
          pushPath,
          data: {'cid': cid, 'raw': jsonEncode(sm.toLotusSignedMessage())}
      );
      return result.toString();
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
  Future<List> getTokenPrice(List param) async{
    try{
      var res = [];
      var result = await client.post(tokenPrice,data:param);
      return res;
    }catch(error){
      return [];
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
  Future<int> getNonce(String address) async {
    var nonce = -1;
    try {
      var res = await client.get(balancePath, queryParameters: {'actor': address});
      print('getnonce');
      return res.data["nonce"] ?? -1;
    } catch (e) {
      print(e);
      return -1;
    }
  }

  @override
  Future<bool> addressCheck(String address) async{
    try {
      var res = await client.get(addrCheck, queryParameters: {'address': address});
      return res.data["nonce"] ?? -1;
    } catch (e) {
      print(e);
      return false;
    }
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
  Future<String> sendToken(
      String from,
      String to,
      String amount,
      String private,
      ChainGas gas,
      int nonce
  ) async{
    return "0";
  }

  @override
  Future<String> getNetworkId() async{
    return '';
  }

  @override
  void dispose() {}
}
