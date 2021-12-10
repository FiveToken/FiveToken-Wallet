import 'package:fil/index.dart';
import 'package:fil/pages/create/mneCheck.dart';
import 'package:fil/pages/create/mneCreate.dart';
import 'package:fil/pages/init/wallet.dart';
import 'package:fil/pages/pass/init.dart';
import 'package:fil/routes/path.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:oktoast/oktoast.dart';

import '../../constant.dart';

void main() {
  var mneList = Mne.split(' ');
  testWidgets('test render mne create page', (tester) async {
    await tester.pumpWidget(OKToast(
        dismissOtherOnShow: true,
        child: GetMaterialApp(
          initialRoute: initWalletPage,
          getPages: [
            GetPage(page: () => WalletInitPage(), name: initWalletPage),
            GetPage(page: () => MneCheckPage(), name: mneCheckPage),
            GetPage(page: () => PassInitPage(), name: passwordSetPage),
          ],
        )));
    Get.toNamed(mneCheckPage, arguments: {'mne': Mne});
    await tester.pumpAndSettle();
    expect(find.byType(MneItem), findsNWidgets(12));
    var state = tester.state<MneCheckPageState>(find.byType(MneCheckPage));
    expect(state.selectedList.length, 0);
    expect(state.unSelectedList.length, 12);
    await tester.tap(find.byType(MneItem).first);
    await tester.pump();
    expect(state.selectedList.length, 1);
    expect(state.unSelectedList.length, 11);
    await tester.tap(find.byType(MneItem).first);
    await tester.pump();
    expect(state.selectedList.length, 0);
    expect(state.unSelectedList.length, 12);
    state.selectedList = mneList;
    await tester.tap(find.text('next'.tr));
    await tester.pumpAndSettle();
  });
}
