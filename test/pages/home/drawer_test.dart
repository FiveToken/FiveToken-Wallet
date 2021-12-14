import 'package:fil/chain/wallet.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/pages/home/drawer.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import '../../constant.dart';

void main() {
  Get.put(StoreController());
  $store.setWallet(ChainWallet(address: EthAddr, label: WalletLabel));
  testWidgets('test render drawer', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DrawerBody(),
    ));
    expect(find.text(WalletLabel), findsOneWidget);
    expect(find.text(dotString(str: EthAddr)), findsOneWidget);
  });
}
