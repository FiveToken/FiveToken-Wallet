import 'package:fil/chain/net.dart';
import 'package:fil/common/global.dart';
import 'package:fil/models/address.dart';
import 'package:fil/pages/address/index.dart';
import 'package:fil/pages/address/net.dart';
import 'package:fil/pages/wallet/select.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:mockito/mockito.dart';

import '../../box.dart';
import '../../constant.dart';
import '../../widgets/dialog_test.dart';

void main() {
  var store = MockSharedPreferences();
  Global.store = store;
  var box = mockAddressBookBox();
  var netBox = mockNetbox();
  Get.put(StoreController());
  var net = Network.filecoinMainNet;
  $store.setNet(net);
  when(box.values).thenReturn(
      [ContactAddress(label: WalletLabel, address: FilAddr, rpc: net.rpc)]);
  when(netBox.values).thenAnswer((realInvocation) => []);
  when(store.getBool(any)).thenAnswer((realInvocation) => false);
  testWidgets('test render address index page', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: addressIndexPage,
      getPages: [
        GetPage(name: addressIndexPage, page: () => AddressBookIndexPage()),
        GetPage(name: addressNetPage, page: () => AddressBookNetPage())
      ],
    ));
    print(Get.currentRoute);
    expect(Get.currentRoute, addressIndexPage);
    expect(find.byType(SwiperWidget), findsOneWidget);
    await tester.tap(find.byType(NetEntranceWidget));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, addressNetPage);
    await tester.tap(find.byType(TapCardWidget).at(1));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, addressIndexPage);
    expect(find.byType(SwiperWidget), findsNothing);
  });
}
