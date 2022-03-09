import 'package:fil/bloc/select/select_bloc.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/common/global.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/pages/init/lang.dart';
import 'package:fil/pages/wallet/select.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mockito/mockito.dart';

import '../../box.dart';
import '../../constant.dart';
import '../../widgets/dialog_test.dart';
import 'package:provider/provider.dart';

class MockSelectBloc extends Mock implements SelectBloc{}

void main() {
  Get.put(StoreController());
  var store = MockSharedPreferences();
  Global.store = store;
  SelectBloc bloc = MockSelectBloc();
  OpenedBox.walletInstance = mockChainWalletBox();
  testWidgets('test render wallet select page', (tester) async {
    var net = Network.ethMainNet;
    var wallet = ChainWallet(
        rpc: net.rpc, address: EthAddr, type: 2, label: WalletLabel);
    when(OpenedBox.walletInstance.values).thenReturn([wallet]);
    when(OpenedBox.walletInstance.delete(any)).thenReturn(null);
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: walletSelectPage,
      getPages: [
        GetPage(name: initLangPage, page: () => SelectLangPage()),
        GetPage(name: walletSelectPage, page: () =>
            Provider(
                create: (_) => bloc..add(IdDeleteEvent())..add(ImportDeleteEvent()),
                child: MultiBlocProvider(
                    providers: [BlocProvider<SelectBloc>.value(value: bloc)],
                    child: MaterialApp(
                      home:  WalletSelectPage(),
                    )
                )
            )
        )
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
    when(OpenedBox.walletInstance.values).thenReturn([]);
    when(store.remove(any)).thenAnswer((realInvocation) => null);
    // when(store.setString(any, any)).thenAnswer((realInvocation) => null);
    // print(Get.currentRoute);
    // expect(find.text('deleteAddr'.tr), findsOneWidget);
    // await tester.tap(find.text('delete'.tr));
    // await tester.pumpAndSettle();
    // expect(Get.currentRoute, initLangPage);
  });
  testWidgets('test switch wallet', (tester) async {
    var net = Network.ethMainNet;
    var wallet = ChainWallet(
        rpc: net.rpc, address: EthAddr, type: 2, label: WalletLabel);
    var wallet2 = ChainWallet(
        rpc: net.rpc, address: EthAddr, type: 0, label: WalletLabel);
    when(OpenedBox.walletInstance .values).thenReturn([wallet, wallet2]);
    when(OpenedBox.walletInstance .delete(any)).thenReturn(null);
    $store.setWallet(wallet2);
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: walletSelectPage,
      getPages: [
        GetPage(name: initLangPage, page: () => SelectLangPage()),
        GetPage(name: walletSelectPage, page: () =>
            Provider(
                create: (_) => bloc..add(IdDeleteEvent())..add(ImportDeleteEvent()),
                child: MultiBlocProvider(
                    providers: [BlocProvider<SelectBloc>.value(value: bloc)],
                    child: MaterialApp(
                      home:  WalletSelectPage(),
                    )
                )
            )
        )
      ],
    ));
    expect(find.byType(SwiperWidget), findsNWidgets(2));
    SwiperWidget swiper = tester.widget(find.byType(SwiperWidget).first);
    print(swiper);
    swiper.onDelete();
    await tester.pumpAndSettle();
    when(OpenedBox.walletInstance.values).thenReturn([wallet]);
    when(store.remove(any)).thenAnswer((realInvocation) => null);
    // when(store.setString(any, any)).thenAnswer((realInvocation) => null);
    // expect(find.text('deleteIdWallet'.tr), findsOneWidget);
    // await tester.tap(find.text('delete'.tr));
    // await tester.pumpAndSettle();
    // expect($store.wal.key, wallet.key);
  });
}
