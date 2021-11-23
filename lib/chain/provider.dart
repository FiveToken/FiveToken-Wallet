import 'package:fil/chain/net.dart';
import 'package:fil/index.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

import 'gas.dart';

class FilecoinResponse {
  int code;
  dynamic data;
  String message;
  String detail;
  FilecoinResponse({this.code, this.data, this.message, this.detail});
  FilecoinResponse.fromJson(Map<String, dynamic> map) {
    code = map['code'];
    data = map['data'];
    message = map['message'];
    detail = map['detail'];
  }
}

abstract class ChainProvider {
  Network net;
  Future<String> getBalance(String addr);
  Future<String> sendTransaction({
    String to,
    String amount,
    String private,
    ChainGas gas,
    int nonce,
  });
  Future<ChainGas> getGas({String to, bool isToken = false, Token token});
  Future<int> getNonce();
  ChainGas replaceGas(ChainGas gas, {String chainPremium});
  void dispose();
}

class FilecoinProvider extends ChainProvider {
  Network net;
  Dio client;
  static String balancePath = '/actor/balance';
  static String pushPath = '/message';
  static String messageListPath = '/actor/messages';
  static String feePath = '/recommend/fee';
  static String clientId = ClientID;

  FilecoinProvider(Network net, {Dio httpClient}) {
    this.net = net;
    this.client = httpClient ?? Dio();
    client.options.baseUrl = net.rpc + '/api$clientId';
    client.options.receiveTimeout = 20000;
  }
  @override
  Future<String> getBalance(String addr) async {
    var balance = '0';
    try {
      var res = await client.get(balancePath, queryParameters: {'actor': addr});
      var response = FilecoinResponse.fromJson(res.data);
      if (response.code == 200) {
        if (response.data is Map<String, dynamic>) {
          Map<String, dynamic> data = response.data;
          balance = data['balance'];
        }
      }
    } catch (e) {
      print(e);
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
    var from = source ?? $store.wal.addr;
    var msg = TMessage(
        version: 0,
        method: 0,
        nonce: nonce,
        from: from,
        to: to,
        params: "",
        value: amount,
        gasFeeCap: gas.gasPrice,
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
      var result = await client.post(pushPath,
          data: {'cid': cid, 'raw': jsonEncode(sm.toLotusSignedMessage())});
      var response = FilecoinResponse.fromJson(result.data);
      if (response.code == 200) {
        if (response.data is String && response.data != '') {
          res = response.data;
        }
      }
      return res;
    } catch (e) {
      return '';
    }
  }

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
    var nonce = -1;
    var addr = $store.wal.addr;
    try {
      var res = await client.get(balancePath, queryParameters: {'actor': addr});

      var response = FilecoinResponse.fromJson(res.data);
      if (response.code != 200) {
        print(response.detail);
      } else {
        if (response.data is Map<String, dynamic>) {
          Map<String, dynamic> data = response.data;
          nonce = data['nonce'];
        }
      }
    } catch (e) {
      print(e);
    }
    return nonce;
  }

  @override
  ChainGas replaceGas(ChainGas gas, {String chainPremium}) {
    var caculatePremium = (int.parse(gas.gasPremium) * 1.3).truncate();
    var realPremium = max(int.parse(chainPremium), caculatePremium);
    var oldPrice = int.parse(gas.gasPrice);
    var realPrice = oldPrice <= realPremium ? realPremium + 100 : oldPrice;
    return ChainGas(
        gasLimit: gas.gasLimit,
        gasPremium: realPremium.toString(),
        gasPrice: realPrice.toString());
  }

  @override
  Future<ChainGas> getGas(
      {String to, bool isToken = false, Token token}) async {
    if (to == null || to == '') {
      to = $store.net.prefix + '099';
    }
    var empty = ChainGas();
    var result = await client
        .get(feePath, queryParameters: {'method': 'Send', 'actor': to});
    var response = FilecoinResponse.fromJson(result.data);
    if (response.code != 200) {
      return empty;
    }
    var res = response.data;
    if (res != null) {
      var limit = res['gas_limit'] ?? 0;
      var premium = res['gas_premium'] ?? '100000';
      var feeCap = res['gas_cap'] ?? '0';
      try {
        var limitNum = limit;
        var premiumNum = int.tryParse(premium) ?? 0;
        var feeCapNum = int.tryParse(feeCap) ?? 0;
        return ChainGas(
            gasPrice: feeCapNum.toString(),
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
  void dispose() {}
}

class EthProvider extends ChainProvider {
  Network net;
  Web3Client client;
  EthProvider(Network net, {Web3Client web3client}) {
    this.net = net;
    client = web3client ?? Web3Client(net.url, http.Client());
  }
  @override
  Future<String> getBalance(String addr) async {
    try {
      var res = await client.getBalance(EthereumAddress.fromHex(addr));
      return res.getInWei.toString();
    } catch (e) {
      print(e);
      return '0';
    }
  }

  @override
  Future<int> getNonce({String from}) async {
    try {
      return await client.getTransactionCount(
          EthereumAddress.fromHex(from ?? $store.wal.addr));
    } catch (e) {
      return -1;
    }
  }

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
      var credentials = await client.credentialsFromPrivateKey(private);
      var res = await client.sendTransaction(
          credentials,
          Transaction(
            to: EthereumAddress.fromHex(to),
            gasPrice: EtherAmount.inWei(BigInt.parse(gas.gasPrice)),
            maxGas: gas.gasLimit,
            nonce: nonce,
            value: EtherAmount.inWei(BigInt.parse(amount)),
          ),
          chainId: int.tryParse($store.net.chainId) ?? 1);
      return res;
    } catch (e) {
      print(e);
      return '';
    }
  }

  Future<String> sendToken(
      {String to,
      String amount,
      String private,
      ChainGas gas,
      String addr,
      int nonce}) async {
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
      return res;
    } catch (e) {
      print(e);
      return '';
    }
  }

  @override
  Future<ChainGas> getGas(
      {String to, bool isToken = false, Token token}) async {
    var empty = ChainGas();
    if (to == null || to == '') {
      to = $store.wal.addr;
    }
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
              sender: toAddr,
              data: data,
              value: EtherAmount.fromUnitAndValue(EtherUnit.wei, 0))
        ]);
      } else {
        res = await Future.wait([
          client.getGasPrice(),
          client.estimateGas(
              to: toAddr,
              value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 1))
        ]);
      }
      if (res.length == 2) {
        EtherAmount gasPrice = res[0];
        BigInt gasLimit = res[1];
        print(gasPrice);
        int realLimit = gasLimit.toInt();
        if (isToken) {
          realLimit = (gasLimit.toInt() * 2).truncate();
        }
        return ChainGas(
            gasLimit: realLimit, gasPrice: gasPrice.getInWei.toString());
      } else {
        return empty;
      }
    } catch (e) {
      print(e);
      return empty;
    }
  }

  @override
  void dispose() {
    client.dispose();
  }
}
