import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../box.dart';
import '../../constant.dart';
import '../../widgets/dialog_test.dart';

void main() {
  Get.put(StoreController());
  var store = MockSharedPreferences();
  Global.store = store;
  testWidgets('test render wallet select page', (tester) async {
    var box = mockChainWalletBox();
    var net = Network.ethMainNet;
    var wallet = ChainWallet(
        rpc: net.rpc, address: EthAddr, type: 2, label: WalletLabel);
    when(box.values).thenReturn([wallet]);
    when(box.delete(any)).thenReturn(null);
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: walletSelectPage,
      getPages: [
        GetPage(name: initLangPage, page: () => SelectLangPage()),
        GetPage(name: walletSelectPage, page: () => WalletSelectPage())
      ],
    ));
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();
    expect(find.byType(TapItemCard), findsNWidgets(2));
    Get.back();
    await tester.pumpAndSettle();
    expect(find.byType(SwiperWidget), findsOneWidget);
    SwiperWidget swiper = tester.widget(find.byType(SwiperWidget));
    swiper.onDelete();
    await tester.pumpAndSettle();
    when(box.values).thenReturn([]);
    when(store.remove(any)).thenAnswer((realInvocation) => null);
    when(store.setString(any, any)).thenAnswer((realInvocation) => null);
    expect(find.text('deleteAddr'.tr), findsOneWidget);
    await tester.tap(find.text('delete'.tr));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, initLangPage);
  });
  testWidgets('test switch wallet', (tester) async {
    var box = mockChainWalletBox();
    var net = Network.ethMainNet;
    var wallet = ChainWallet(
        rpc: net.rpc, address: EthAddr, type: 2, label: WalletLabel);
    var wallet2 = ChainWallet(
        rpc: net.rpc, address: EthAddr, type: 0, label: WalletLabel);
    when(box.values).thenReturn([wallet, wallet2]);
    when(box.delete(any)).thenReturn(null);
    $store.setWallet(wallet2);
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: walletSelectPage,
      getPages: [
        GetPage(name: initLangPage, page: () => SelectLangPage()),
        GetPage(name: walletSelectPage, page: () => WalletSelectPage())
      ],
    ));
    expect(find.byType(SwiperWidget), findsNWidgets(2));
    SwiperWidget swiper = tester.widget(find.byType(SwiperWidget).first);
    swiper.onDelete();
    await tester.pumpAndSettle();
    when(box.values).thenReturn([wallet]);
    when(store.remove(any)).thenAnswer((realInvocation) => null);
    when(store.setString(any, any)).thenAnswer((realInvocation) => null);
    expect(find.text('deleteIdWallet'.tr), findsOneWidget);
    await tester.tap(find.text('delete'.tr));
    await tester.pumpAndSettle();
    expect($store.wal.key, wallet.key);
  });
}
