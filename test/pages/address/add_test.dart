import 'package:fil/bloc/address/address_bloc.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/address.dart';
import 'package:fil/pages/address/add.dart';
import 'package:fil/pages/address/select.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
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
import 'package:oktoast/oktoast.dart';

import '../../box.dart';
import '../../constant.dart';
import 'package:provider/provider.dart';
class MockAddressBloc extends Mock implements AddressBloc{}

void main() {
  Get.put(StoreController());
  AddressBloc bloc = MockAddressBloc();
  var net = Network.filecoinMainNet;
  var address = ContactAddress(address: FilAddr, rpc: net.rpc, label: WalletLabel);
  $store.setNet(net);
  OpenedBox.addressBookInsance = mockAddressBookBox();
  when(OpenedBox.addressBookInsance.values).thenAnswer((realInvocation) => [address]);
  when(OpenedBox.addressBookInsance.containsKey(any)).thenReturn(false);
  when(OpenedBox.addressBookInsance.delete(any)).thenAnswer((realInvocation) async => null);
  when(OpenedBox.addressBookInsance.put(any, any)).thenAnswer((realInvocation) async => null);
  testWidgets('test render address book add page', (tester) async {
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: addressSelectPage,
      getPages: [
        GetPage(name: addressSelectPage, page: () =>
            Provider(
                create: (_) => bloc..add(AddressListEvent(network: $store.net)),
                child: MultiBlocProvider(
                    providers: [BlocProvider<AddressBloc>.value(value: bloc)],
                    child: MaterialApp(
                        home: AddressBookSelectPage()
                    )
                )
            )
        ),
        GetPage(name: addressAddPage, page: () =>
            Provider(
                create: (_) => bloc..add(AddressListEvent(network: $store.net)),
                child: MultiBlocProvider(
                    providers: [BlocProvider<AddressBloc>.value(value: bloc)],
                    child: MaterialApp(
                        home: AddressBookAddPage()
                    )
                )
           )
        )
      ],
    )));
    expect(Get.currentRoute, addressSelectPage);
    Get.toNamed(addressAddPage, arguments: {'mode': 1, 'addr': address});
    await tester.pumpAndSettle();
    expect(Get.currentRoute, addressAddPage);
    AddressBookAddPageState state =
        tester.state<AddressBookAddPageState>(find.byType(AddressBookAddPage));
    expect(state.mode, 1);
    expect(find.text('save'.tr), findsOneWidget);
    // var newNet = Network.ethMainNet;
    // // state.net = newNet;
    // await tester.enterText(find.byType(TextField).first, EthAddr);
    // await tester.pump();
    // await tester.tap(find.text('save'.tr));
    // await tester.pumpAndSettle(Duration(seconds: 1));
    // expect(find.text('netNotMatch'.tr), findsOneWidget);
    // await tester.tap(find.text('add'.tr));
    // await tester.pumpAndSettle(Duration(seconds: 3));
    // expect(Get.currentRoute, addressSelectPage);
  });
}
