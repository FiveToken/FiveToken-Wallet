import 'package:fil/chain/net.dart';
import 'package:fil/common/global.dart';
import 'package:fil/config/config.dart';
import 'package:fil/request/global.dart';
import 'package:fil/request/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fil/common/global.dart';

Future<void> main() {
  group("global test", (){
    test('filecoin test',() async{
      var filNet = Network.filecoinMainNet;
      List param = [
        {
          "id":'filecoin',
          "vs":"usd"
        }
      ];
      Chain.setRpcNetwork(filNet.rpc, filNet.chain);
      var res = await Chain.chainProvider.getTokenPrice(param);
      expect(res.length, 1);
    });

    test('eth test',() async {
      var ethNet = Network.ethMainNet;
      List param = [
        {
          "id":'filecoin',
          "vs":"usd"
        }
      ];
      Chain.setRpcNetwork(ethNet.rpc, ethNet.chain);
      var res = await Chain.chainProvider.getTokenPrice(param);
      expect(res.length, 1);
    });

    test('binance test',() async {
      var binanceNet = Network.binanceMainNet;
      List param = [
        {
          "id":'filecoin',
          "vs":"usd"
        }
      ];
      Chain.setRpcNetwork(binanceNet.rpc, binanceNet.chain);
      var res = await Chain.chainProvider.getTokenPrice(param);
      expect(res.length, 1);
    });

  });
}