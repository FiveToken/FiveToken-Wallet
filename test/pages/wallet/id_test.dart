import 'package:fil/bloc/main/main_bloc.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/common/global.dart';
import 'package:fil/index.dart';
import 'package:fil/pages/init/lang.dart';
import 'package:fil/pages/wallet/id.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/route_manager.dart';
import 'package:mockito/mockito.dart';

import '../../box.dart';
import '../../constant.dart';
import '../../widgets/dialog_test.dart';
import 'package:provider/provider.dart';

class MockMainBloc extends Mock implements MainBloc{}

void main() {
  Get.put(StoreController());
  var store = MockSharedPreferences();
  Global.store = store;
  MainBloc bloc = MockMainBloc();
  var box = mockChainWalletBox();
  var netBox = mockNetbox();
  var net = Network.ethMainNet;
  $store.setNet(net);
  // when(store.getBool(any)).thenReturn(true);
  when(box.values).thenAnswer((realInvocation) => Network.mockNetList[0]
      .map((n) => ChainWallet(
          rpc: n.rpc, address: EthAddr, type: 0, label: WalletLabel))
      .toList());
  when(netBox.values).thenAnswer((realInvocation) => [
        Network(
            rpc: 'https://www.rpc.com',
            chain: 'eth',
            addressType: AddressType.eth.type)
      ]);
  print(box.values);
  print(OpenedBox.walletInstance);
  print(netBox.values);
  testWidgets('test render id wallet page', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: initLangPage,
      getPages: [
        GetPage(name: initLangPage, page: () => SelectLangPage()),
        GetPage(name: walletIdPage, page: () =>
            Provider(
                create: (_) => bloc..add(TestNetIsShowEvent(hideTestnet: true)),
                child: MultiBlocProvider(
                    providers: [BlocProvider<MainBloc>.value(value: bloc)],
                    child: MaterialApp(
                      home:  IdWalletPage(),
                    )
                )
           )
        )
      ],
    ));

    Get.toNamed(walletIdPage, arguments: {'groupHash': ''});
    await tester.pumpAndSettle();
    expect(Get.currentRoute, walletIdPage);
    expect(find.byIcon(Icons.more_horiz_sharp), findsNWidgets(3));
  });
}
