import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/pages/home/widgets/net.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mockito/mockito.dart';

import '../../../box.dart';
import '../../../constant.dart';

void main() {
  Get.put(StoreController());
  var box = mockChainWalletBox();
  var netBox = mockNetbox();
  when(netBox.values).thenReturn([]);
  when(box.values).thenReturn([]);
  $store.setWallet(ChainWallet(
      rpc: Network.ethMainNet.rpc,
      label: WalletLabel,
      address: EthAddr,
      type: 0));
  testWidgets('test render net select', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
        home: Scaffold(
      appBar: PreferredSize(
        child: AppBar(
          title: NetSelect(),
        ),
        preferredSize: Size.fromHeight(NavHeight),
      ),
    )));
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);
    await tester.tap(find.text('wallet'.tr));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(9));
  });
}
