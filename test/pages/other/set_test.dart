import 'package:fil/common/global.dart';
import 'package:fil/index.dart';
import 'package:fil/pages/other/lang.dart';
import 'package:fil/pages/other/lock.dart';
import 'package:fil/pages/other/set.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/card.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mockito/mockito.dart';

import '../../widgets/dialog_test.dart';

void main() {
  testWidgets('test render other  set', (tester) async {
    await tester.runAsync(() async {
      var store = MockSharedPreferences();
      Global.store = store;
      await tester.pumpWidget(GetMaterialApp(
        initialRoute: setPage,
        getPages: [
          GetPage(page: () => LangPage(), name: langPage),
          GetPage(page: () => SetPage(), name: setPage),
          GetPage(page: () => LockPage(), name: lockPage),
        ],
      ));
      expect(find.byType(TapItemCard), findsNWidgets(3));
      await tester.tap(find.text('lang'.tr));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, langPage);
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, setPage);

      Get.toNamed(setPage);
      await tester.tap(find.text('service'.tr));
      await tester.pumpAndSettle();

      Get.toNamed(setPage);
      await tester.tap(find.text('clause'.tr));
      await tester.pumpAndSettle();

      Get.toNamed(setPage);
      await tester.tap(find.text('addrBook'.tr));
      await tester.pumpAndSettle();


      SetPageState set = SetPageState();
      String lang = Global.langCode == 'zh'?'cn':'en';
      expect(set.lang, lang);

      Get.toNamed(setPage);
      await tester.tap(find.text('net'.tr));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, netIndexPage);

      await tester.tap(find.text('lockScreenSetting'.tr));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, lockPage);

    });
  });
}