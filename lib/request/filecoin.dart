import 'dart:convert';
import 'package:bls/bls.dart';
import 'package:dio/dio.dart';
import 'package:fil/chain/gas.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/common/global.dart';
import 'package:fil/models/filMessage.dart';
import 'package:fil/models/gas_response.dart';
import 'package:fil/models/token_info.dart';
import 'package:fil/models/transaction_response.dart';
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
        if(result.data != null){
          balance = result.data['balance'];
        }
      return balance;
    } catch (e) {
      return balance;
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
  Future<TransactionResponse> sendTransaction(
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
      String res = '';
      var result = await client.post(
          pushPath,
          data: {'cid': cid, 'raw': jsonEncode(sm.toLotusSignedMessage())}
      );
      return TransactionResponse(
        cid:result.toString(), message:''
      );
    } catch (e) {
      return TransactionResponse(
        cid:'',
        message: e.message
      );
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
  Future<GasResponse> getGas({String from,String to, bool isToken = false, Token token}) async {
    var empty = GasResponse();
    try{
      var result = await client
          .get(feePath, queryParameters: {'method': 'Send', 'actor': to});
      var res = result.data;
      if (res != null){
        var limit = res['gas_limit'] ?? 0;
        var premium = res['gas_premium'] ?? '100000';
        var feeCap = res['gas_cap'] ?? '0';
        var premiumNum = int.tryParse(premium) ?? 0;
        var feeCapNum = int.tryParse(feeCap) ?? 0;
        return GasResponse(
            gasState: "success",
            message: '',
            gasFeeCap: feeCapNum.toString(),
            gasPremium: premiumNum.toString(),
            gasLimit: limit
        );
      }else{
        return GasResponse(
            gasState: "error",
            message: ''
        );
      }
    }catch(error){
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
      return res.data["nonce"] ?? -1;
    } catch (e) {
      return -1;
    }
  }

  @override
  Future<bool> addressCheck(String address) async{
    try {
      var res = await client.get(addrCheck, queryParameters: {'address': address});
      if(res.data == 'ok'){
        return true;
      }else{
        return false;
      }
    } catch (e) {
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
  Future<TransactionResponse> sendToken(
      {String to,
        String amount,
        String private,
        ChainGas gas,
        String addr,
        int nonce}
  ) async{
    return TransactionResponse(
      cid: '',
      message: ''
    );
  }

  @override
  Future<String> getNetworkId() async{
    return '';
  }

  @override
  Future<TokenInfo> getTokenInfo(String address) async{
    return TokenInfo(
        symbol: '',
        precision:"0"
    );
  }

  @override
  void dispose() {}
}


Future<num> getTokenPrice(chain) async{
  try{
    String baseApi = Network.filecoinMainNet.rpc + '/api' + Config.clientID;
    String tokenPrice = '/token/prices';
    var map = {
      'eth': 'ethereum',
      'binance': 'binancecoin',
      'filecoin':'filecoin'
    };
    List param = [
      {
        "id":map[chain],
        "vs":"usd"
      }
    ];
    num usd = 0;
    final response = await http.post(baseApi+tokenPrice,data: param);
    if(response.statusCode == 200){
      var res = response.data;
      if(res.length > 0){
        var obj = res[0];
        if(obj["vs"] == 'usd'){
          usd = double.parse((obj["price"]).toString());
        }
      }
    }
    return usd;
  }catch(error){
    return 0;
  }
}