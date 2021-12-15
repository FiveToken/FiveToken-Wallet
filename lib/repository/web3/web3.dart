import 'package:flutter/cupertino.dart';
import 'package:fil/repository/web3/json_rpc.dart';
import 'package:fil/repository/web3/rpc_http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as https;

class Web3 {
  Web3Client client;
  RpcJson rpcJson;

  factory Web3(String url) {
    return Web3._().._init(url);
  }

  Web3._();

  _init(String url) {
    rpcJson = RpcJson(url,rpcHttp);
    client = Web3Client.custom(rpcJson);
    //
    // client = Web3Client(url, https.Client());

  }
}
