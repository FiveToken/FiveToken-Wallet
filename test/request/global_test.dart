import 'package:fil/chain/net.dart';
import 'package:fil/common/global.dart';
import 'package:fil/index.dart';
import 'package:fil/request/global.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

class MockClient extends Mock implements http.Client {}

void main() {

  setUp(() async {
    Global.store = await SharedPreferences.getInstance();
  });

  group("global test", () {
    test('filecoin test', () async {
      var filNet = Network.filecoinMainNet;
      Chain.setRpcNetwork(filNet.rpc, filNet.chain);

      // expect(res.length, 1);
    });
  });
}