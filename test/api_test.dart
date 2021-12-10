import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fil/api/third.dart';
import 'package:fil/index.dart';
import 'package:fil/models/wallet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class DioAdapterMock extends Mock implements HttpClientAdapter {}

void main() async {
  final client = Dio();
  final chain = 'filecoin';
  final dioAdapter = DioAdapterMock();
  final price = CoinPrice(usd: 1.0, cny: 6.4);
  client.httpClientAdapter = dioAdapter;

  test("mock get coin price", () async {
    when(dioAdapter.fetch(any, any, any)).thenAnswer((realInvocation) async =>
        ResponseBody.fromString(
            jsonEncode({'code': 0, 'data': price.toJson()}), 200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            }));
    var res = await getFilPrice(chain, client: client);
    expect(res.usd, price.usd);
  });
  test("mock get coin price fail", () async {
    when(dioAdapter.fetch(any, any, any)).thenAnswer((realInvocation) async =>
        ResponseBody.fromString(jsonEncode({'code': 1, 'data': null}), 200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            }));
    var res = await getFilPrice(chain, client: client);
    expect(res.usd, 0.0);
  });
  test("test unknown coin", () async {
    var res = await getFilPrice('custom', client: client);
    expect(res.usd, 0.0);
  });
}
