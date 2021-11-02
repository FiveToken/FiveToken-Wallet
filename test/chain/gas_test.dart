import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final gas = ChainGas.fromJson({'feeCap': '300', 'gasLimit': 1000});

  group("mock chain gas caculte", () {
    Get.put(StoreController());
    $store = Get.find();
    $store.setNet(Network.filecoinMainNet);
    test("test normal gas", () {
      expect(gas.feeNum, BigInt.from(300000));
    });
    test("test fast gas", () {
      expect(gas.fast.feeNum, BigInt.from(330000));
    });
    test("test slow gas", () {
      expect(gas.slow.feeNum, BigInt.from(270000));
    });
    test("test max fee", () {
      var fee = '0.00029 nanoFIL';
      expect(gas.maxFee, fee);
    });
  });
}
