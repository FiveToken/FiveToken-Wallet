import 'package:fil/index.dart';
import 'package:fil/pages/home/walletConnect.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../constant.dart';

void main() {
  testWidgets('test render connenct sheet', (tester) async {
    var n = 0;
    var n2 = 0;
    // await tester.pumpWidget(GetMaterialApp(
    //   home: ConnectWallet(
    //     meta: WCMeta.fromJson({
    //       'name': WalletLabel,
    //       'description': 'wallet connect',
    //       'icons': ['']
    //     }),
    //     onCancel: () {
    //       n++;
    //     },
    //     onConnect: () {
    //       n2++;
    //     },
    //   ),
    // ));
    expect(find.text(WalletLabel), findsOneWidget);
    expect(find.text('wallet connect'), findsOneWidget);
    await tester.tap(find.text('cancel'.tr));
    expect(n, 1);
    await tester.tap(find.text('connect'.tr));
    expect(n2, 1);
  });
  testWidgets('test render confirm sheet', (tester) async {
    // Get.put(StoreController());
    // await tester.pumpWidget(GetMaterialApp(
    //   home: SingleChildScrollView(
    //     child: ConfirmMessageSheet(
    //       address: EthAddr,
    //       to: EthAddr,
    //       maxFee: '',
    //       value: '',
    //     ),
    //   ),
    // ));
    // expect(find.text(EthAddr), findsNWidgets(2));
    // expect(find.text('approve'.tr), findsOneWidget);
    // expect(find.byType(FButton), findsNWidgets(2));
  });
}
