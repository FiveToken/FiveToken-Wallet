import 'package:fil/chain/net.dart';
import 'package:fil/common/global.dart';
import 'package:fil/pages/init/lang.dart';
import 'package:fil/pages/init/wallet.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/card.dart';
import 'package:fil/widgets/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mockito/mockito.dart';
import 'package:fil/widgets/index.dart';
import '../../widgets/dialog_test.dart';

void main() {
  Get.put(StoreController());
  var net = Network.filecoinMainNet;
  $store.setNet(net);
  testWidgets('test render init  page', (tester) async {
    await tester.runAsync(() async {
      var store = MockSharedPreferences();
      Global.store = store;
      // when(store.setString(any, any))
      //     .thenAnswer((realInvocation) async => true);
      await tester.pumpWidget(GetMaterialApp(
        initialRoute: initLangPage,
        getPages: [
          GetPage(page: () => SelectLangPage(), name: initLangPage),
          GetPage(page: () => WalletInitPage(), name: initWalletPage),
        ],
      ));
      expect(find.byType(TapItemCard), findsNWidgets(4));
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, initWalletPage);

      Get.toNamed(initLangPage);
      await tester.pumpAndSettle();
      await tester.tap(find.text('한국어'));
      expect(Get.currentRoute, initWalletPage);

      Get.toNamed(initLangPage);
      expect(Get.currentRoute, initLangPage);
      await tester.pumpAndSettle();
      await tester.tap(find.text('日本語'));
      expect(Get.currentRoute, initWalletPage);

      Get.toNamed(initLangPage);
      await tester.pumpAndSettle();
      expect(Get.currentRoute, initLangPage);
      await tester.tap(find.text('中文'));
      expect(Get.currentRoute, initWalletPage);

    });
  });
}
