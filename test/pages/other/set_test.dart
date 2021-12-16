import 'package:fil/bloc/address/address_bloc.dart';
import 'package:fil/bloc/lock/lock_bloc.dart';
import 'package:fil/bloc/net/net_bloc.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/common/global.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/pages/address/index.dart';
import 'package:fil/pages/net/add.dart';
import 'package:fil/pages/net/list.dart';
import 'package:fil/pages/other/lang.dart';
import 'package:fil/pages/other/lock.dart';
import 'package:fil/pages/other/set.dart';
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
import 'package:provider/provider.dart';
import '../../box.dart';
import '../../widgets/dialog_test.dart';

class MockLockBloc extends Mock implements LockBloc{}
class MockNetBloc extends Mock implements NetBloc{}
class MockAddressBloc extends Mock implements AddressBloc{}
void main() {
  Get.put(StoreController());
  var store = MockSharedPreferences();
  Global.store = store;
  var net = Network.ethMainNet;
  $store.setNet(net);
  LockBloc bloc = MockLockBloc();
  NetBloc netBloc = MockNetBloc();
  AddressBloc addressBloc = MockAddressBloc();
  OpenedBox.addressBookInsance = mockAddressBookBox();
  when( OpenedBox.addressBookInsance.values).thenReturn([]);
  testWidgets('test render other  set', (tester) async {
    await tester.runAsync(() async {
      var store = MockSharedPreferences();
      Global.store = store;
      await tester.pumpWidget(GetMaterialApp(
        initialRoute: setPage,
        getPages: [
          GetPage(page: () => LangPage(), name: langPage),
          GetPage(page: () => SetPage(), name: setPage),
          GetPage(name: addressIndexPage, page: () =>
              Provider(
                  create: (_) => addressBloc..add(AddressListEvent(network: $store.net)),
                  child: MultiBlocProvider(
                      providers: [BlocProvider<AddressBloc>.value(value: addressBloc)],
                      child: MaterialApp(
                        home: AddressBookIndexPage()
                      ),
                      )
                  )

          ),
          GetPage(name: lockPage, page: () =>
              Provider(
              create: (_) => bloc,
              child: MultiBlocProvider(
                  providers: [BlocProvider<LockBloc>.value(value: bloc)],
                  child: MaterialApp(
                    home: LockPage()
                  )
              )
          )),
          GetPage(name: netIndexPage, page: ()=>
              Provider(
                  create: (_) => netBloc.add(SetNetEvent(Network.netList)),
                  child: MultiBlocProvider(
                      providers: [BlocProvider<NetBloc>.value(value: netBloc)],
                      child: GetMaterialApp(
                        initialRoute: netIndexPage,
                        getPages: [
                          GetPage(name: netIndexPage, page: () => NetIndexPage()),
                          GetPage(name: netAddPage, page: () => NetAddPage())
                        ],
                      )
                  )
              )
          )
        ],
      ));
      expect(find.byType(TapItemCard), findsNWidgets(3));
      await tester.tap(find.text('lang'.tr));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, langPage);
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, setPage);

      Get.toNamed(setPage);
      await tester.tap(find.text('service'.tr));
      await tester.pumpAndSettle();

      Get.toNamed(setPage);
      await tester.tap(find.text('clause'.tr));
      await tester.pumpAndSettle();

      Get.toNamed(setPage);
      await tester.tap(find.text('addrBook'.tr));
      await tester.pumpAndSettle();


      SetPageState set = SetPageState();
      String lang = Global.langCode == 'zh'?'cn':'en';
      expect(set.lang, lang);

      Get.toNamed(setPage);
      await tester.pumpAndSettle();
      await tester.tap(find.text('net'.tr));
      expect(Get.currentRoute, netIndexPage);

      // Get.toNamed(setPage);
      // print(Get.currentRoute);
      // // await tester.pumpAndSettle();
      // // await tester.tap(find.text('lockScreenSetting'.tr));
      // // await tester.pumpAndSettle();
      // expect(Get.currentRoute, lockPage);

    });
  });
}