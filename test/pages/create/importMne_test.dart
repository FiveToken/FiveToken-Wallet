import 'package:fil/index.dart';
import 'package:flutter_test/flutter_test.dart';
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
