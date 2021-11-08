library json_rpc;

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:web3dart/json_rpc.dart';

class RpcJson extends RpcService {
  RpcJson(this.url, this.client);

  final String url;
  final Dio client;

  int _currentRequestId = 1;

  @override
  Future<RPCResponse> call(String function, [List<dynamic> params]) async {
    params ??= [];

    final requestPayload = {
      'jsonrpc': '2.0',
      'method': function,
      'params': params,
      'id': _currentRequestId++,
    };

    final response = await client.post(url,
        data: requestPayload,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ));

    final data = response.data;
    final id = data['id'] as int;
    if (data.containsKey('error')) {
      final error = data['error'];
      final code = error['code'] as int;
      final message = error['message'] as String;
      final errorData = error['data'];
      throw RPCError(code, message, errorData);
    }

    final result = data['result'];
    return RPCResponse(id, result);
  }
}
