import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../constant.dart';

void main() {
  Get.put(StoreController());
  testWidgets('test render export mne page', (tester) async {
    await tester.pumpWidget(GetMaterialApp(
      initialRoute: initLangPage,
      getPages: [
        GetPage(name: initLangPage, page: () => SelectLangPage()),
        GetPage(name: walletMnePage, page: () => WalletMnePage())
      ],
    ));
    Get.toNamed(walletMnePage, arguments: {'mne': Mne});
    await tester.pumpAndSettle();
    expect(Get.currentRoute, walletMnePage);
    expect(find.byType(KeyString), findsOneWidget);
    expect(find.byType(KeyCode), findsNothing);
    await tester.tap(find.text('code'.tr));
    await tester.pump();
    expect(find.byType(KeyString), findsNothing);
    expect(find.byType(KeyCode), findsOneWidget);
  });
}
