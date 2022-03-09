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
import 'package:fil/common/shared_preferences.dart';
import 'package:fil/common/cryptography.dart';

Future fetchPing() async {
  List<String> hostList = [];
  for (var i = 1; i < 16; i++) {
    String hash = await sha256hash('fivetoken${i}');
    String hostMid = hash.substring(0, 4) +
        hash.substring(hash.length - 9, hash.length - 1);
    String host = 'https://api${hostMid}.xyz/api/7om8n3ri4v23pjjfs4ozctlb';
    hostList.add(host);
  }
  try {
    final one = await Future.any(hostList.map((e) => _callPing(e + '/ping')));
    await PreferencesManagerX().setString('host', one.data as String);
    return one;
  } catch (e) {
    print(e);
  }

}

Future _callPing(String url) async {
  try {
    return await http.get(url);
  }
  catch (e) {
    await Future.delayed(Duration(seconds: 30));
  }
}

String GetBaseUrl() {
  String host = PreferencesManagerX().getString('host') as String;
  return host != null ? host + "/api/7om8n3ri4v23pjjfs4ozctlb" : 'https://api.fivetoken.io/api/7om8n3ri4v23pjjfs4ozctlb';
}

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
  static String baseUrl (){
    return GetBaseUrl();
  }
  Filecoin(String rpc, {Dio httpClient}) {
    this.rpc = rpc;
    client = httpClient ?? http;
    client.options.baseUrl = rpc =='https://api.fivetoken.io' ? baseUrl(): rpc + '/api$clientId';
  }

  /*
  * Gets the balance of the account with the specified address.
  * @param {string} address: The address where the balance needs to be obtained
  * */
  @override
  Future<String> getBalance(String address) async {
    String balance = '0';
    try {
      var result =  await client.get(balancePath, queryParameters: {'actor': address});
        if(result.data != null){
          balance = result.data['balance'] as String;
        }
      return balance;
    } catch (e) {
      return balance;
    }
  }

  /*
  * Returns the message of block number
  * */
  @override
  Future<ChainInfo> getBlockByNumber(int number) async{
    return ChainInfo(
      gasUsed: 0,
      gasLimit:0,
      number:0,
      timestamp: 0,
    );
  }

  /*
  * Returns a hash of the transaction which, after the transaction has been included in a mined block,
  * can be used to obtain detailed information about the transaction.
  * @param {string} from: sending transaction from address
  * @param {string} to:  sending transaction to address
  * @param {String} amount：Amount sent
  * @param {String} private：private of sending transactions
  * @param {int} nonce：nonce of sending transactions
  * */
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
        message: e.message as String
      );
    }
  }

  /*
  * get fileCoin messages list
  * @param {string} actor:address to query
  * @param {string} direction : up or down, indicating the operation action of the client, up means swiping up, pulling from the latest news to historical news; down means pulling down to refresh, pulling the latest news
  * @param {string} mid : The message MID of the pagination reference, obtained from the first or last entry in the query list, is a numeric string, not a CID
  * @param {int} limit: Number of bars
  * */
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
        list = res.data['messages'] as List<dynamic>;
    }
    return list;
  }

  /*
  * Get fee
  * @param {string} from: sending transaction from address
  * @param {string} to:  sending transaction to address
  * @param {bool} isToken: is it a token
  * @param {Token} token: Token Information
  * */
  @override
  Future<GasResponse> getGas({String from,String to, bool isToken = false, Token token}) async {
    var empty = GasResponse();
    try{
      var result = await client
          .get(feePath, queryParameters: {'method': 'Send', 'actor': to});
      var res = result.data;
      if (res != null){
        int limit = res['gas_limit'] as int ?? 0;
        String premium = res['gas_premium'] as String ?? '100000';
        String feeCap = res['gas_cap'] as String ?? '0';
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
      if(error.message.isNotEmpty as bool){
        return GasResponse(
            gasState: "error",
            message: error.message as String
        );
      }else{
        return GasResponse(
            gasState: "error",
            message: ''
        );
      }
    }
  }

  /*
  * Query pending messages information
  *  @param {List} param:[{
  * from:Transaction sending address,
  * nonce: Transaction nonce
  * }]
  * */
  @override
  Future<List> getMessagePendingState(List param) async{
    try {
      var result =  await client.post(messagePending, data: param );
      return result.data as List<dynamic>?? [];
    } catch (e) {
      return [];
    }
  }

  /*
  * Get address nonce by the specified address.
  * @param {string} address: the specified address
  * */
  @override
  Future<int> getNonce(String address) async {
    var nonce = -1;
    try {
      var res = await client.get(balancePath, queryParameters: {'actor': address});
      return res.data["nonce"] as int ?? -1;
    } catch (e) {
      return -1;
    }
  }

  /*
  * address check
  * @param {string} address:address to check
  * */
  // @override
  // Future<bool> addressCheck(String address) async{
  //   try {
  //     var res = await client.get(addrCheck, queryParameters: {'address': address});
  //     if(res.data == 'ok'){
  //       return true;
  //     }else{
  //       return false;
  //     }
  //   } catch (e) {
  //     return false;
  //   }
  // }

  /*
  * Returns an receipt of a transaction based on its hash.
  * @param {string} hash: transaction hash
  * */
  @override
  Future getTransactionReceipt(String hash) async{
    return null;
  }

  /*
  * Gets the balance of token
  * @param {string} mainAddress:main token address
  * @param {string} tokenAddress:contract address
  * */
  @override
  Future<String> getBalanceOfToken(String mainAddress,String tokenAddress) async{
    return '0';
  }

  /*
  * Returns a fee per gas that is an estimate of how much you can pay as a priority fee, or "tip", to get a transaction included in the current block.
  * */
  @override
  Future<String> getMaxPriorityFeePerGas() async{
    return "0";
  }

  /*
  * get baseFeePerGas
  * */
  @override
  Future<String> getBaseFeePerGas() async{
    return "0";
  }

  /*
  * send token and Returns a hash
  * @param {string} to:  sending transaction to address
  * @param {String} amount：Amount sent
  * @param {String} private：private of sending transactions
  * @param {ChainGas} gas:transactions gas
  * @param {string} addr:contract address
  * @param {int} nonce：nonce of sending transactions
  * */
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

  /*
  * Returns the id of the network the client is currently connected to.
  * */
  @override
  Future<String> getNetworkId() async{
    return '';
  }

  /*
  * get Token Information
  * @param { string } Token contract address
  * */
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

/*
* Get the USD price corresponding to the token
* @param {string} chain: network to be queried
* */
Future<double> getTokenPrice(chain) async{
  String baseUrl (){
    return GetBaseUrl();
  }
   Dio client;
   Dio httpClient ;
   client = httpClient ?? http;
   client.options.baseUrl = baseUrl();
  try{
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
    double usd = 0.0;
    var response = await client.post(tokenPrice, data: param);
    if(response.statusCode == 200){
      var res = response.data;
      if(res.length as int > 0){
        var obj = res[0];
        if(obj["vs"] == 'usd'){
          usd = double.parse((obj["price"]).toString());
        }
      }
    }
    return usd;
  }catch(error){
    return 0.0;
  }
}