import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/native_imp.dart';
import 'package:dio_log/interceptor/dio_log_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:fil/config/config.dart';
import 'package:fil/repository/http/interceptors.dart';

final http = Http();

class Http extends DioForNative {
  static Http instance;

  factory Http() {
    return instance ??= Http._().._init();
  }

  Http._();

  _init() async {
    ///Custom jsonDecodeCallback
    (transformer as DefaultTransformer).jsonDecodeCallback = parseJson;

    options.connectTimeout = Config.connectTimeout;
    options.receiveTimeout = Config.receiveTimeout;

    interceptors.add(HttpInterceptors());
    interceptors.add(DioLogInterceptor());
  }
}

_parseAndDecode(String response) {
  return jsonDecode(response);
}

parseJson(String text) {
  return compute(_parseAndDecode, text);
}
