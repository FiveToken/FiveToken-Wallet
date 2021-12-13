import 'package:fil/common/global.dart';
import 'package:fil/index.dart';
import 'package:fil/pages/other/lang.dart';
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
  testWidgets('test render other  page', (tester) async {
    await tester.runAsync(() async {
      var store = MockSharedPreferences();
      Global.store = store;
      store.setString(StoreKeyLanguage, 'en');
      await tester.pumpWidget(GetMaterialApp(
        initialRoute: setPage,
        getPages: [
          GetPage(page: () => LangPage(), name: langPage),
          GetPage(page: () => SetPage(), name: setPage),
        ],
      ));
      expect(find.byType(TapItemCard), findsNWidgets(3));
      await tester.tap(find.text('lang'.tr));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, langPage);
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, setPage);

      await tester.tap(find.text('lang'.tr));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, langPage);
      await tester.tap(find.text('中文'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, setPage);

      await tester.tap(find.text('lang'.tr));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, langPage);
      await tester.tap(find.text('한국어'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, setPage);

      await tester.tap(find.text('lang'.tr));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, langPage);
      await tester.tap(find.text('日本語'));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, setPage);
    });
  });
}
