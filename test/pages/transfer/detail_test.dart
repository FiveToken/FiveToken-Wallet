import 'package:fil/common/global.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:fil/pages/transfer/detail.dart';
import 'package:fil/pages/wallet/main.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/store/store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:mockito/mockito.dart';

import '../../widgets/dialog_test.dart';
void main() {
  Get.put(StoreController());
  CacheMessage msg = CacheMessage(
      from: 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema',
      to: 'f1k4effkl5cxd4bo5ec2ykuiyxgzwqwra527kp6ka',
      owner: 'f134ljmsuc6ab45jiaf2qjahs3j2vl6jv7pm5oema',
      hash: 'bafy2bzacecpq36akmsfnyxdbaiy4dp43no6g7nog2xh42s47vg7z3vhpk3ado',
      value: '100000000000000',
      blockTime: 1639012530,
      exitCode: 0,
      pending: 0,
      nonce: 552,
      rpc: 'https://api.fivetoken.io',
      token: null,
      gas: null,
      fee: '439799715206',
      height: 1356871,
      mid: '135687100189',
      symbol: 'FIL'
  );
  testWidgets('test transfer detail', (tester) async {
      await tester.pumpWidget(GetMaterialApp(
          initialRoute: walletMainPage,
          getPages: [
            GetPage(page: () => WalletMainPage(), name: walletMainPage),
            GetPage(page: () => FilDetailPage(), name: filDetailPage),
          ]
      ));
      expect(Get.currentRoute, walletMainPage);
      Get.toNamed(filDetailPage, arguments: msg);
      expect(find.byType(MessageRow), findsNWidgets(6));
  });
}