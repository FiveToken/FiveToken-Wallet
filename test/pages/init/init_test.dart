import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../widgets/dialog_test.dart';

void main() {
  testWidgets('test render init  page', (tester) async {
    await tester.runAsync(() async {
      var store = MockSharedPreferences();
      Global.store = store;
      when(store.setString(any, any))
          .thenAnswer((realInvocation) async => true);
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
    });
  });
}
