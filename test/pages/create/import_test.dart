import 'package:fil/index.dart';
import 'package:fil/pages/create/import.dart';
import 'package:flutter_test/flutter_test.dart';
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
