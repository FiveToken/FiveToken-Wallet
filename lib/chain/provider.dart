import 'dart:developer';

import 'package:fil/chain/net.dart';
import 'package:fil/index.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

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
  Future<ChainMessageDetail> getMessageDetail(String hash);
  void dispose();
}

class FilecoinProvider extends ChainProvider {
  Network net;
  Dio client;
  FilecoinProvider(Network net) {
    this.net = net;
    client = Dio();
    client.options.baseUrl = net.rpc;
    client.options.receiveTimeout = 20000;
  }
  @override
  Future<String> getBalance(String addr) async {
    var data = JsonRPCRequest(1, 'filscan.BalanceNonceByAddress', [
      {'address': addr}
    ]);
    var balance = '0';
    try {
      var res = await client.post('', data: data);
      var response = JsonRPCResponse.fromJson(res.data);
      if (response.error != null) {
        var error = JsonRPCError.fromJson(response.error);
        print(error.message);
      }
      if (response.result != null) {
        var result = response.result as Map<String, dynamic>;
        balance = result['balance'];
      }
    } on DioError catch (e) {
      if (e.type == DioErrorType.RECEIVE_TIMEOUT) {
        print('timeout');
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
      int nonce}) async {
    var from = $store.wal.addr;
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
      String res = await pushSignedMsg(sm.toLotusSignedMessage());
      return res;
    } catch (e) {
      return '';
    }
  }

  @override
  Future<int> getNonce() async {
    var data = JsonRPCRequest(1, "filscan.BalanceNonceByAddress", [
      {"address": $store.wal.addr},
    ]);
    var rs = await client.post(
      "",
      data: data,
    );
    if (rs == null) {
      return -1;
    }
    var res = JsonRPCResponse.fromJson(rs.data);
    var r = -1;
    if (res.result != null) {
      var result = res.result as Map<String, dynamic>;
      r = result["nonce"];
    }
    return r == null ? -1 : r;
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
    var data = JsonRPCRequest(1, "filscan.BaseFeeAndGas", [to, 0]);
    var empty = ChainGas();
    var result = await client
        .post(
      "",
      data: data,
    )
        .catchError((e) {
      print(e);
    });
    var response = JsonRPCResponse.fromJson(result.data);

    if (response.error != null) {
      return empty;
    }
    var res = response.result;
    if (res != null) {
      var baseFee = res['base_fee'] ?? '0';
      //var gasUsed = res['gas_used'] ?? '0';
      var limit = res['gas_limit'] ?? '0';
      var premium = res['gas_premium'] ?? '100000';
      // var exist = res['actor_exist'] ?? true;
      try {
        var baseFeeNum = int.parse(baseFee);
        var limitNum = int.parse(limit);
        var premiumNum = int.parse(premium);
        var feeCap = 3 * baseFeeNum + premiumNum;
        //var gasLimit = (1.25 * gasUsedNum).truncate();
        // if (!exist) {
        //   limitNum = 2200000;
        // }
        return ChainGas(
            gasPrice: feeCap.toString(),
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
  Future<ChainMessageDetail> getMessageDetail(String hash) async {
    var data = JsonRPCRequest(1, "filscan.MessageDetails", [hash]);
    var result = await client.post(
      "/rpc/v1",
      data: data,
    );
    var empty = ChainMessageDetail();
    var response = JsonRPCResponse.fromJson(result.data);
    if (response.error != null) {
      return empty;
    }
    var res = response.result;
    if (res != null) {
      var message = ChainMessageDetail(
          from: res['from'],
          to: res['to'],
          hash: res['signed_cid'],
          fee: res['all_gas_fee'],
          value: res['value'],
          height: res['height']);
      return message;
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
  EthProvider(Network net) {
    this.net = net;
    client = Web3Client(net.rpc, http.Client());
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
  Future<int> getNonce() async {
    try {
      return await client
          .getTransactionCount(EthereumAddress.fromHex($store.wal.addr));
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
          chainId: int.parse($store.net.chainId));
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
          chainId: int.parse($store.net.chainId));
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
        var data = con.function('transfer').encodeCall([
          EthereumAddress.fromHex(to),
          BigInt.from(100*pow(10, token.precision))
        ]);
        res = await Future.wait([
          client.getGasPrice(),
          client.estimateGas(
              to: EthereumAddress.fromHex(token.address),
              sender: toAddr,
              data: data,
              value: EtherAmount.fromUnitAndValue(EtherUnit.ether, 1))
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
  Future<ChainMessageDetail> getMessageDetail(String hash) async {
    try {
      var res = await client.getTransactionReceipt(hash);
      return ChainMessageDetail(
          from: res.from.toString(),
          to: res.to.toString(),
          height: res.blockNumber.blockNum,
          hash: hash);
    } catch (e) {
      return ChainMessageDetail();
    }
  }

  @override
  void dispose() {
    client.dispose();
  }
}
