import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class RpcHttpInterceptors extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: implement onRequest
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    // TODO: implement onError
    super.onError(err, handler);
  }
}

class RpcResponseData {
  dynamic data;

  int code;

  String msg;

  bool get success => code == 200;

  @override
  String toString() {
    return "RespData{ data: $data, code: $code, message: $msg}";
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["data"] = data;
    map["code"] = code;
    map["msg"] = msg;
    return map;
  }

  RpcResponseData.formJson(Map<String, dynamic> json) {
    data = json["data"];
    code = json["code"];
    msg = json["msg"];
  }
}
