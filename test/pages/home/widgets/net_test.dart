import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/pages/home/widgets/net.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../box.dart';
import '../../../constant.dart';
import '../../../request/ether_test.mocks.dart';

@GenerateMocks([
  Box,
  StoreController
])
void main() {
  final _mockStoreController = MockStoreController();
  // Get.put(_mockStoreController);
  var mockBox = MockBox();
  final chainWallet = ChainWallet().obs;
  OpenedBox.walletInstance = MockBox<ChainWallet>();
  when(OpenedBox.walletInstance.values).thenReturn([]);
  final network = Network.binanceTestnet.obs;

  $store = _mockStoreController;
  // $store.setWallet(
  // ChainWallet(
  //     rpc: Network.ethMainNet.rpc,
  //     label: WalletLabel,
  //     address: EthAddr,
  //     type: 0)
  //     );

  when($store.wallet).thenReturn(chainWallet);
  when($store.wal).thenReturn(chainWallet.value);
  when($store.network).thenReturn(network);
  when($store.net).thenReturn(network.value);

  test("description", (){});

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

    // expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    // await tester.tap(find.text('wallet'.tr));
    // await tester.pumpAndSettle();
    // expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(9));
  });
}
