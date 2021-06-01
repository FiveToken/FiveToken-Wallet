import 'dart:async';

import 'package:flutter/services.dart';

class Bls {
  static const MethodChannel _channel =
      const MethodChannel('bls');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> ckgen({num: String}) async {
    final String ck = await _channel.invokeMethod('ckgen', {'num': num});
    return ck;
  }

  static Future<String> pkgen({num: String}) async {
    final String pk = await _channel.invokeMethod('pkgen', {'num': num});
    return pk;
  }

  static Future<String> cksign({num: String}) async {
    final String sign = await _channel.invokeMethod('cksign', {'num': num});
    return sign;
  }
}
