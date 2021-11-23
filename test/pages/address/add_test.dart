import 'package:fil/index.dart';
import 'package:fil/pages/address/select.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:oktoast/oktoast.dart';

import '../../box.dart';
import '../../constant.dart';

void main() {
  Get.put(StoreController());
  var net = Network.filecoinMainNet;

  var address =
      ContactAddress(address: FilAddr, rpc: net.rpc, label: WalletLabel);
  $store.setNet(net);
  var box = mockAddressBookBox();
  when(box.values).thenAnswer((realInvocation) => [address]);
  when(box.containsKey(any)).thenReturn(false);
  when(box.delete(any)).thenAnswer((realInvocation) async => null);
  when(box.put(any, any)).thenAnswer((realInvocation) async => null);
  testWidgets('test render address book add page', (tester) async {
    await tester.pumpWidget(OKToast(
        child: GetMaterialApp(
      initialRoute: addressSelectPage,
      getPages: [
        GetPage(name: addressSelectPage, page: () => AddressBookSelectPage()),
        GetPage(name: addressAddPage, page: () => AddressBookAddPage())
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
    var newNet = Network.ethMainNet;
    // state.net = newNet;
    await tester.enterText(find.byType(TextField).first, EthAddr);
    await tester.pump();
    await tester.tap(find.text('save'.tr));
    await tester.pumpAndSettle(Duration(seconds: 1));
    expect(find.text('netNotMatch'.tr), findsOneWidget);
    await tester.tap(find.text('add'.tr));
    await tester.pumpAndSettle(Duration(seconds: 3));
    expect(Get.currentRoute, addressSelectPage);
  });
}
