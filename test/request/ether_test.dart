import 'package:fil/chain/net.dart';
import 'package:fil/request/global.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> main() {
  group("Ether test", (){
    test('filecoin test',() async{
      var filNet = Network.filecoinMainNet;
      List param = [
        {
          "id":'filecoin',
          "vs":"usd"
        }
      ];
      // Chain.setRpcNetwork(filNet.rpc, filNet.chain);
      // var res = await Chain.chainProvider.getTokenPrice(param);
      // expect(res.length, 1);
    });

  });
}