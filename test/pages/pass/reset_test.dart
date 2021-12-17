import 'package:fil/bloc/select/select_bloc.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/pages/pass/reset.dart';
import 'package:fil/routes/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:fil/pages/wallet/manage.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import '../../box.dart';
class MockSelectBloc extends Mock implements SelectBloc{}
@GenerateMocks([
  GetX
])
void main() {
  SelectBloc bloc = MockSelectBloc();
  String pass= '123456789012';
  String newPass= '123456789011';
  ChainWallet wallet = ChainWallet(
    label: 'Dfg',
    address: '0x3fb4f280cf531ba7d88fe4d0748a451e4d4276ad',
    type: 2,
    balance: '400000000000000',
    mne: '',
    skKek: '26YiVLnEWv4KVBsRL6TPDFY4KrnRA0AbtwTeBBcLPl9jO19sa8npNTD4lupSBbf2GfTL82MpME3WejzBqZW/I2D73c0u2fUwliMLAtw59Gw=',
    digest: 'r57NXYt4/wElj612To5Rkg==',
    groupHash: '',
    addressType: 'eth',
    rpc: 'https://mainnet.infura.io/v3/'
  );
  OpenedBox.walletInstance = mockChainWalletBox();
  when(OpenedBox.walletInstance.values).thenReturn([]);
  testWidgets('test render init  page', (tester) async {
    await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: walletMangePage,
          getPages: [
            GetPage(name: walletMangePage, arguments: {'wallet': wallet}, page: () =>
              Provider(
                  create: (_) => bloc..add(IdDeleteEvent())..add(ImportDeleteEvent()),
                  child: MultiBlocProvider(
                      providers: [BlocProvider<SelectBloc>.value(value: bloc)],
                      child: MaterialApp(
                        home:  WalletManagePage(),
                      )
                  )
              )
            ),
            GetPage(name: passwordResetPage, page: () => PassResetPage())
          ],
        )
    );
    // expect(Get.currentRoute, walletMangePage);
    // Get.toNamed(passwordResetPage, arguments: {'wallet': wallet});
    // await tester.enterText(find.byType(TextField).at(0), pass);
    // await tester.enterText(find.byType(TextField).at(1), newPass);
    // await tester.enterText(find.byType(TextField).at(2), newPass);
    // await tester.tap(find.text('sure'.tr));
    // await tester.pumpAndSettle();
  });
}