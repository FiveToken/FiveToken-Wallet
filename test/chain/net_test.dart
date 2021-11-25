import 'package:fil/index.dart';
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
    test('get net by custom rpc', () {
      var rpc = 'https://www.rpc.com';
      var box = mockNetbox();
      when(box.get(any)).thenReturn(Network(rpc: rpc));
      var net = Network.getNetByRpc(rpc);
      expect(net.rpc, rpc);
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
    test('test netList', () {
      mockNetbox();
      when(OpenedBox.netInstance.values)
          .thenAnswer((realInvocation) => [Network.binanceMainNet]);
      var allList = Network.netList;
      var mainList = allList[0];
      var testList = allList[1];
      var customList = allList[2];
      expect(mainList.length, 3);
      expect(testList.length, 6);
      expect(customList.length, 1);
    });
  });
  test('address type', () {
    expect(AddressType.supportTypes.length, 2);
  });
}
