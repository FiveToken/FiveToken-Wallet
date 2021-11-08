import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class HttpInterceptors extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: implement onRequest
    debugPrint("执行了这里");
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(response.statusCode.toString());
    debugPrint(response.requestOptions.path);
    debugPrint(response.requestOptions.headers.toString());
    debugPrint(response.requestOptions.queryParameters.toString());
    debugPrint(jsonEncode(response.data));
    debugPrint(response.data.runtimeType.toString());
    debugPrint((response.data is Map).toString());
    if (response.data is Map) {
      final responseData = ResponseData.formJson(response.data);
      response.data = responseData.data;
      if (responseData.success) {
        handler.resolve(response);
      } else {
        handler.reject(DioError(
            requestOptions: response.requestOptions, response: response));
      }
    }
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    // TODO: implement onError


    debugPrint('+================执行了这'  + jsonEncode(err.message) );

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
