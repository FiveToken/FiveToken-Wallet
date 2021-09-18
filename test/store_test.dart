import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';

import 'constant.dart';

void main() {
  Get.put(StoreController());
  test("test get controller", () {
    var addr = FilAddr;
    var label = WalletLabel;
    var balance = '100';
    var tokenAddr = EthAddr;
    var wallet = ChainWallet(label: label, address: addr, balance: '0');
    var token = Token(
      address: tokenAddr,
    );
    var net = Network.filecoinMainNet;
    var gas = ChainGas(gasLimit: 100, gasPrice: '100');
    $store.setWallet(wallet);
    $store.setGas(gas);
    $store.setNet(net);
    $store.setToken(token);
    expect($store.wal.toJson(), equals(wallet.toJson()));
    expect($store.gas, equals(gas));
    expect($store.token, equals(token));
    expect($store.net, equals(net));
    $store.changeWalletName('five');
    expect($store.wal.label, 'five');
    $store.changeWalletBalance(balance);
    expect($store.wal.balance, balance);
  });
}
