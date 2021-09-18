import 'package:fil/index.dart';
import 'package:fil/pages/wallet/id.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/route_manager.dart';
import 'package:mockito/mockito.dart';

import '../../box.dart';
import '../../constant.dart';
import '../../widgets/dialog_test.dart';

void main() {
  Get.put(StoreController());
  var store = MockSharedPreferences();
  Global.store = store;
  var box = mockChainWalletBox();
  var netBox = mockNetbox();
  var net = Network.ethMainNet;
  $store.setNet(net);
  when(store.getBool(any)).thenReturn(true);
  when(box.values).thenAnswer((realInvocation) => Network.netList[0]
      .map((n) => ChainWallet(
          rpc: n.rpc, address: EthAddr, type: 0, label: WalletLabel))
      .toList());
  when(netBox.values).thenAnswer((realInvocation) => [
        Network(
            rpc: 'https://www.rpc.com',
            chain: 'eth',
            addressType: AddressType.eth.type)
      ]);
  testWidgets('test render id wallet page', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: initLangPage,
      getPages: [
        GetPage(name: initLangPage, page: () => SelectLangPage()),
        GetPage(name: walletIdPage, page: () => IdWalletPage())
      ],
    ));
    Get.toNamed(walletIdPage, arguments: {'groupHash': ''});
    await tester.pumpAndSettle();
    expect(Get.currentRoute, walletIdPage);
    expect(find.byIcon(Icons.more_horiz_sharp), findsNWidgets(3));
  });
}
