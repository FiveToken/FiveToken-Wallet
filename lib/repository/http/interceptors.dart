import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class HttpInterceptors extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is Map) {
      final responseData = ResponseData.formJson(response.data);
      response.data = responseData.data;
      if (responseData.success) {
        handler.next(response);
      } else {
        handler.reject(DioError(
            requestOptions: response.requestOptions, response: response));
      }
    }
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    super.onError(err, handler);
  }
}

class ResponseData {
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

  ResponseData.formJson(Map<String, dynamic> json) {
    data = json["data"];
    code = json["code"];
    msg = json["msg"];
  }
}
