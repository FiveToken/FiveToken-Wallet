import 'package:fil/chain/net.dart';
import 'package:fil/index.dart';
import 'package:fil/pages/create/importPrivateKey.dart';
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
import 'package:oktoast/oktoast.dart';

import '../../constant.dart';

void main() {
  group('test render import private page', () {
    testWidgets('test not input private', (tester) async {
      await tester.pumpWidget(OKToast(
          dismissOtherOnShow: true,
          child: GetMaterialApp(
            initialRoute: initWalletPage,
            getPages: [
              GetPage(page: () => WalletInitPage(), name: initWalletPage),
              GetPage(
                  page: () => ImportPrivateKeyPage(),
                  name: importPrivateKeyPage),
              GetPage(page: () => PassInitPage(), name: passwordSetPage),
            ],
          )));
      Get.toNamed(importPrivateKeyPage, arguments: {
        'net': Network.filecoinMainNet,
      });
      await tester.pumpAndSettle();
      var importBtn = find.text('import'.tr);
      await tester.tap(importBtn);
      await tester.pumpAndSettle(Duration(milliseconds: 300));
      expect(find.text('enterPk'.tr), findsOneWidget);
      await tester.pumpAndSettle(Duration(seconds: 3));
      expect(find.text('enterPk'.tr), findsNothing);
    });
    testWidgets('test import eth private', (tester) async {
      await tester.pumpWidget(OKToast(
          dismissOtherOnShow: true,
          child: GetMaterialApp(
            initialRoute: initWalletPage,
            getPages: [
              GetPage(page: () => WalletInitPage(), name: initWalletPage),
              GetPage(
                  page: () => ImportPrivateKeyPage(),
                  name: importPrivateKeyPage),
              GetPage(page: () => PassInitPage(), name: passwordSetPage),
            ],
          )));
      Get.toNamed(importPrivateKeyPage, arguments: {
        'net': Network.ethMainNet,
      });
      await tester.pumpAndSettle();
      var importBtn = find.text('import'.tr);
      await tester.enterText(find.byType(TextField).first, EthPrivate);
      await tester.enterText(find.byType(TextField).last, WalletLabel);
      await tester.tap(importBtn);
      await tester.pumpAndSettle(Duration(seconds: 3));
      expect(find.byType(TextField), findsNWidgets(2));
    });
    testWidgets('test import filecoin private', (tester) async {
      await tester.pumpWidget(OKToast(
          dismissOtherOnShow: true,
          child: GetMaterialApp(
            initialRoute: initWalletPage,
            getPages: [
              GetPage(page: () => WalletInitPage(), name: initWalletPage),
              GetPage(
                  page: () => ImportPrivateKeyPage(),
                  name: importPrivateKeyPage),
              GetPage(page: () => PassInitPage(), name: passwordSetPage),
            ],
          )));
      Get.toNamed(importPrivateKeyPage, arguments: {
        'net': Network.filecoinMainNet,
      });
      await tester.pumpAndSettle();
      var importBtn = find.text('import'.tr);
      await tester.enterText(find.byType(TextField).first,
          '7B2254797065223A22736563703235366B31222C22507269766174654B6579223A22413066553636356F5A67514D46656B5144434C31686872456B76464E445955766A39336D4C5565703079493D227D');
      await tester.enterText(find.byType(TextField).last, WalletLabel);
      await tester.tap(importBtn);
      await tester.pumpAndSettle(Duration(seconds: 3));
      expect(find.byType(TextField), findsNWidgets(2));
    });
  });
}
