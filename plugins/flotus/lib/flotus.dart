import 'dart:async';

import 'package:flutter/services.dart';

class Flotus {
  static const MethodChannel _channel = const MethodChannel('flotus');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> genAddress({pk: String, t: String}) async {
    final String addr =
        await _channel.invokeMethod('genAddress', {'pk': pk, 't': t});
    return addr;
  }

  static Future<String> addressFromString({ad: String}) async {
    final String addr =
        await _channel.invokeMethod('genFromString', {'ad': ad});
    return addr;
  }

  static Future<String> messageCid({msg: String}) async {
    final String cid = await _channel.invokeMethod('messageCid', {'msg': msg});
    return cid;
  }

  static Future<String> secpPrivateToPublic({ck: String}) async {
    final String addr =
        await _channel.invokeMethod('secpPrivateToPublic', {'ck': ck});
    return addr;
  }

  static Future<String> secpSign({ck: String, msg: String}) async {
    final String addr =
        await _channel.invokeMethod('secpSign', {'ck': ck, 'msg': msg});
    return addr;
  }

  static Future<String> genConstructorParamV3(String input) async {
    final String addr =
        await _channel.invokeMethod('genConstructorParamV3', {'input': input});
    return addr;
  }

  static Future<String> genProposeForSendParamV3(
      String to, String value) async {
    final String addr = await _channel
        .invokeMethod('genProposeForSendParamV3', {'to': to, 'value': value});
    return addr;
  }

  static Future<String> genProposalForWithdrawBalanceV3(
      String miner, String value) async {
    final String addr = await _channel.invokeMethod(
        'genProposalForWithdrawBalanceV3', {'miner': miner, 'value': value});
    return addr;
  }

  static Future<String> genProposalForChangeOwnerV3(
      String self, String miner, String value) async {
    final String addr = await _channel.invokeMethod(
        'genProposalForChangeOwnerV3',
        {'self': self, 'miner': miner, 'value': value});
    return addr;
  }

  static Future<String> genProposalForChangeWorkerAddress(
      String miner, String params) async {
    final String addr = await _channel.invokeMethod(
        'genProposalForChangeWorkerAddress', {'miner': miner, 'value': params});
    return addr;
  }

  static Future<String> genApprovalV3(String tx) async {
    final String addr = await _channel.invokeMethod('genApprovalV3', {
      'tx': tx,
    });
    return addr;
  }
}
