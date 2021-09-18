import 'package:fil/index.dart';
import 'package:fil/pages/address/wallet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../box.dart';
import '../../constant.dart';

void main() {
  Get.put(StoreController());
  var box = mockChainWalletBox();

  testWidgets('test render address book wallet select page no data',
      (tester) async {
    when(box.values).thenAnswer((realInvocation) => []);
    await tester.pumpWidget(MaterialApp(
      home: AddressBookWalletSelect(),
    ));
    expect(find.byType(TapCardWidget), findsNothing);
  });
  testWidgets('test render address book wallet select page with wallet',
      (tester) async {
    var net = Network.filecoinMainNet;
    $store.setNet(net);
    when(box.values).thenAnswer((realInvocation) => [
          ChainWallet(
              label: WalletLabel, address: FilAddr, rpc: net.rpc, type: 0),
          ChainWallet(
              label: WalletLabel, address: FilAddr, rpc: net.rpc, type: 2)
        ]);
    await tester.pumpWidget(MaterialApp(
      home: AddressBookWalletSelect(),
    ));
    expect(find.byType(TapCardWidget), findsNWidgets(2));
  });
}
