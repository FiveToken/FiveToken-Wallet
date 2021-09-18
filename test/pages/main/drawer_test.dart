import 'package:fil/index.dart';
import 'package:fil/pages/main/drawer.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../constant.dart';

void main() {
  Get.put(StoreController());
  $store.setWallet(ChainWallet(address: EthAddr, label: WalletLabel));
  testWidgets('test render drawer', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DrawerBody(),
    ));
    expect(find.text(WalletLabel), findsOneWidget);
    expect(find.text(dotString(str: EthAddr)), findsOneWidget);
  });
}
