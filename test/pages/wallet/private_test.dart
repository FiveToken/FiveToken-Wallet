import 'package:fil/chain/wallet.dart';
import 'package:fil/index.dart';
import 'package:fil/pages/init/lang.dart';
import 'package:fil/pages/wallet/mne.dart';
import 'package:fil/pages/wallet/private.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../constant.dart';

void main() {
  Get.put(StoreController());
  testWidgets('test render export private page', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: initLangPage,
      getPages: [
        GetPage(name: initLangPage, page: () => SelectLangPage()),
        GetPage(name: walletPrivatekey, page: () => WalletPrivatekeyPage())
      ],
    ));
    Get.toNamed(walletPrivatekey, arguments: {
      'private': EthPrivate,
      'wallet': ChainWallet(addressType: 'eth')
    });
    await tester.pumpAndSettle();
    expect(Get.currentRoute, walletPrivatekey);
    expect(find.byType(KeyString), findsOneWidget);
    expect(find.byType(KeyCode), findsNothing);
    await tester.tap(find.text('code'.tr));
    await tester.pump();
    expect(find.byType(KeyString), findsNothing);
    expect(find.byType(KeyCode), findsOneWidget);
  });
}
