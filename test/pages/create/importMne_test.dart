import 'package:fil/chain/net.dart';
import 'package:fil/index.dart';
import 'package:fil/pages/create/importMne.dart';
import 'package:fil/pages/init/wallet.dart';
import 'package:fil/pages/pass/init.dart';
import 'package:fil/routes/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mockito/mockito.dart';
import 'package:oktoast/oktoast.dart';

import '../../box.dart';
import '../../constant.dart';

void main() {
  testWidgets('test render import mne page', (tester) async {
    Get.arguments;
    var box = mockNetbox();
    when(box.values).thenReturn([]);
    await tester.pumpWidget(OKToast(
        dismissOtherOnShow: true,
        child: GetMaterialApp(
          initialRoute: initWalletPage,
          getPages: [
            GetPage(page: () => WalletInitPage(), name: initWalletPage),
            GetPage(page: () => ImportMnePage(), name: importMnePage),
            GetPage(page: () => PassInitPage(), name: passwordSetPage),
          ],
        )));
    Get.toNamed(importMnePage,
        arguments: {'net': Network.filecoinMainNet, 'type': 1});
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FlatButton));
    await tester.pumpAndSettle(Duration(milliseconds: 300));
    expect(find.text('enterMne'.tr), findsNWidgets(2));
    await tester.pumpAndSettle(Duration(seconds: 3));
    expect(find.text('enterMne'.tr), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, Mne);
    await tester.enterText(find.byType(TextField).last, 'five');
    await tester.tap(find.byType(FlatButton));
    await tester.pumpAndSettle();
  });
}
