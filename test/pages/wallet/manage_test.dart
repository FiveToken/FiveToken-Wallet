import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:oktoast/oktoast.dart';

import '../../box.dart';
import '../../constant.dart';

void main() {
  Get.put(StoreController());
  var net = Network.ethMainNet;
  var newLabel = 'new$WalletLabel';
  var wallet =
      ChainWallet(rpc: net.rpc, address: EthAddr, type: 2, label: WalletLabel);
  var box = mockChainWalletBox();
  $store.setWallet(wallet);
  when(box.values).thenReturn([wallet]);
  when(box.put(any, any)).thenAnswer((realInvocation) async => null);
  testWidgets('test render wallet manage page', (tester) async {
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: initLangPage,
      getPages: [
        GetPage(name: initLangPage, page: () => SelectLangPage()),
        GetPage(name: walletMangePage, page: () => WalletManagePage())
      ],
    )));
    Get.toNamed(walletMangePage, arguments: {'net': net, 'wallet': wallet});
    await tester.pumpAndSettle();
    expect(Get.currentRoute, walletMangePage);
    await tester.tap(find.text('walletName'.tr));
    await tester.pumpAndSettle();
    expect(find.text('changeWalletName'.tr), findsOneWidget);
    await tester.enterText(find.byType(TextField), newLabel);
    await tester.tap(find.text('sure'.tr));
    await tester.pumpAndSettle(Duration(seconds: 3));
    expect($store.wal.label, newLabel);
  });
}
