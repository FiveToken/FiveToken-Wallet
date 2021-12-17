import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import 'package:dio_log/interceptor/dio_log_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:fil/config/config.dart';
import 'package:fil/repository/web3/rpc_interceptors.dart';

final rpcHttp = RpcHttp();

class RpcHttp extends DioForNative {
  static RpcHttp instance;

  factory RpcHttp() {
    return instance ??= RpcHttp._().._init();
  }

  RpcHttp._();

  _init() async {
    (transformer as DefaultTransformer).jsonDecodeCallback = parseJson;
    options.connectTimeout = Config.connectTimeout;
    options.receiveTimeout = Config.receiveTimeout;
    interceptors.add(RpcHttpInterceptors());
    interceptors.add(DioLogInterceptor());
  }
}

_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}
