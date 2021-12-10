import 'package:fil/chain/gas.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/index.dart';
import 'package:fil/store/store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

void main() {
  final gas = ChainGas.fromJson({'feeCap': '300', 'gasLimit': 1000});

  group("mock chain gas caculte", () {
    Get.put(StoreController());
    $store = Get.find();
    $store.setNet(Network.filecoinMainNet);
    test("test normal gas", () {
      expect(BigInt.parse(gas.handlingFee), BigInt.from(300000));
    });
    test("test max fee", () {
      var fee = '0.00029 nanoFIL';
      expect(gas.handlingFee, fee);
    });
  });
}
