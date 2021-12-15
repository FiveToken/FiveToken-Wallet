import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/pages/address/wallet.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:mockito/mockito.dart';

import '../../box.dart';
import '../../constant.dart';

void main() {
  Get.put(StoreController());
  OpenedBox.walletInstance = mockChainWalletBox();
  when(OpenedBox.walletInstance.values).thenReturn([]);
  testWidgets('test render address book wallet select page no data',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AddressBookWalletSelect(),
    ));
    expect(find.byType(TapCardWidget), findsNothing);
  });
  testWidgets('test render address book wallet select page with wallet',
      (tester) async {
    var net = Network.filecoinMainNet;
    $store.setNet(net);
    when(OpenedBox.walletInstance.values).thenReturn([
          ChainWallet(
              label: WalletLabel, address: FilAddr, rpc: net.rpc, type: 0),
          ChainWallet(
              label: WalletLabel, address: FilAddr, rpc: net.rpc, type: 2)
        ]);
    await tester.pumpWidget(MaterialApp(
      home: AddressBookWalletSelect(),
    ));
    expect(find.byType(TapCardWidget), findsNWidgets(2));
  });
}
