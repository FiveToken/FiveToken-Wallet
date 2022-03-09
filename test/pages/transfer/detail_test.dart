import 'package:fil/chain/net.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/common/global.dart';
import 'package:fil/models/cacheMessage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:fil/routes/path.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:fil/pages/transfer/detail.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:intl/intl.dart';
import '../../bloc/transfer_test.dart';
import 'package:fil/store/store.dart';

void main() {
  Get.put(StoreController());
  var store = MockSharedPreferences();
  Global.store = store;
  Network net = Network.ethMainNet;
  ChainWallet wal = ChainWallet(
      label: 'DD',
      address: '0x3fb4f280cf531ba7d88fe4d0748a451e4d4276ad',
      type: 2,
      balance: '400000000000000',
      mne: '',
      addressType: 'eth',
      skKek: 'CGmTwXja66YS39Y3Lp5MmUWNRMx5mp8YBstteIJDpHjK9vTyoDfbahaRY6+/RF4NfhKqyzmWckA1ngd3CG+FDWzkKNeoqW9BiY4cA89D+x8=',
      digest: 'r57NXYt4/wElj612To5Rkg==',
      rpc: 'https://mainnet.infura.io/v3/'
  );
  $store.setNet(net);
  $store.setWallet(wal);
  Token token = Token(precision: 6,
      address: "0xEa00C8d2d4e658Afc23737181aa1c12F9b99551e",
      chain: "eth",
      symbol: 'ETH',
      balance: "10000000");
  CacheMessage msg = CacheMessage(token: token, pending: 1);
  print(msg.token);
  testWidgets('test transfer gas', (tester) async {
    await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: filDetailPage,
          getPages: [
            GetPage(name: filDetailPage, page: () => FilDetailPage(), arguments: msg)
          ],
        )
      // GetMaterialApp.router(getPages: [
      //       GetPage(name: filDetailPage, page: () => FilDetailPage(), arguments:msg)
      // ],)
    );
    await tester.pumpAndSettle();
    Get.toNamed(filDetailPage, arguments: {msg: msg});
    print(Get.currentRoute);
  });
}