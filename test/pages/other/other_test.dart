import 'package:fil/index.dart';
import 'package:fil/pages/other/lang.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../widgets/dialog_test.dart';

void main() {
  testWidgets('test render other  page', (tester) async {
    await tester.runAsync(() async {
      var store = MockSharedPreferences();
      Global.store = store;
      when(store.setString(any, any))
          .thenAnswer((realInvocation) async => true);
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
    });
  });
}
