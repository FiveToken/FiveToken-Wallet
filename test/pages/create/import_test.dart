import 'package:fil/chain/net.dart';
import 'package:fil/index.dart';
import 'package:fil/pages/create/import.dart';
import 'package:fil/pages/init/wallet.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mockito/mockito.dart';

import '../../box.dart';

void main() {
  testWidgets('test render import index page', (tester) async {
    Get.arguments;
    var box = mockNetbox();
    when(box.values).thenReturn([]);
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: initWalletPage,
      getPages: [
        GetPage(page: () => WalletInitPage(), name: initWalletPage),
        GetPage(page: () => ImportIndexPage(), name: importIndexPage),
      ],
    ));
    Get.toNamed(importIndexPage, arguments: {'type': 1});
    await tester.pumpAndSettle();
    expect(
        find.ancestor(
            of: find.text('idWallet'.tr), matching: find.byType(TapCardWidget)),
        findsOneWidget);
    expect(find.byType(TapCardWidget),
        findsNWidgets(Network.supportNets.length + 1));
  });
}
