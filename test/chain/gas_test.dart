import 'package:fil/chain/gas.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/store/store.dart';
import 'package:fil/utils/enum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

void main() {


  group("mock chain gas caculte", () {
    test("test gas", () {
      Get.put(StoreController());
      $store = Get.find();
      $store.setNet(Network.ethMainNet);
      final gas = ChainGas.fromJson({
        "rpcType": RpcType.ethereumMain,
        'maxFeePerGas': '10',
        'gasLimit': 10,
        "gasPremium":'0',
        "gasPrice":'0',
        "level":0,
        "maxPriorityFee":'0',
        "gasFeeCap":'0'
      });
      expect(gas.handlingFee, '100');
    });

    test("test gas", () {
      Get.put(StoreController());
      $store = Get.find();
      $store.setNet(Network.filecoinMainNet);
      final gas = ChainGas.fromJson({
        "rpcType":"filecoin",
        'maxFeePerGas': '10',
        'gasLimit': 10,
        "gasPremium":'0',
        "gasPrice":'0',
        "level":0,
        "maxPriorityFee":'0',
        "gasFeeCap":'0'
      });
      expect(gas.handlingFee, '0');
    });

    test("test gas", () {
      Get.put(StoreController());
      $store = Get.find();
      $store.setNet(Network.binanceMainNet);
      final gas = ChainGas.fromJson({
        "rpcType":"ethOthers",
        'maxFeePerGas': '10',
        'gasLimit': 10,
        "gasPremium":'0',
        "gasPrice":'0',
        "level":0,
        "maxPriorityFee":'0',
        "gasFeeCap":'0'
      });
      expect(gas.handlingFee, '0');
    });
  });
}
