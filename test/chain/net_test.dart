import 'package:fil/chain/net.dart';
import 'package:fil/init/hive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../box.dart';

void main() {
  group('test network', () {
    test('support net length', () {
      expect(Network.supportNets.length, 9);
    });
    test('get net by rpc', () {
      var rpc = Network.filecoinMainNet.rpc;
      var net = Network.getNetByRpc(rpc);
      expect(net.chain, "filecoin");
    });
    test('from json', () {
      var browser = Network.filecoinMainNet.browser;
      var randomStr = 'custom';
      var rpc = 'www.xxx.com';
      var net = Network.fromJson({
        'chain': randomStr,
        'name': randomStr,
        'net': randomStr,
        'coin': randomStr,
        'browser': browser,
        'netType': 2,
        'rpc': rpc
      });
      expect(net.hasPrice, false);
      expect(net.label, randomStr);
      expect(net.url, rpc);
      expect(net.getAddrDetailLink('').contains(browser), true);
      expect(net.getDetailLink('').contains(browser), true);
    });
  });
  test('address type', () {
    expect(AddressType.supportTypes.length, 2);
  });
}
