import 'package:fil/index.dart';
import 'package:fil/pages/main/widgets/net.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../box.dart';
import '../../../constant.dart';

void main() {
  Get.put(StoreController());
  var box = mockChainWalletBox();
  var netBox = mockNetbox();
  when(netBox.values).thenReturn([]);
  when(box.values).thenReturn([]);
  $store.setWallet(ChainWallet(
      rpc: Network.ethMainNet.rpc,
      label: WalletLabel,
      address: EthAddr,
      type: 0));
  testWidgets('test render net select', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
        home: Scaffold(
      appBar: PreferredSize(
        child: AppBar(
          title: NetSelect(),
        ),
        preferredSize: Size.fromHeight(NavHeight),
      ),
    )));
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);
    await tester.tap(find.text('wallet'.tr));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle_outline), findsNWidgets(9));
  });
}
