import 'package:fil/pages/home/index.dart';
import 'package:fil/pages/wallet/id.dart';
import 'package:fil/pages/wallet/main.dart';
import 'package:fil/pages/wallet/manage.dart';
import 'package:fil/pages/wallet/mne.dart';
import 'package:fil/pages/wallet/private.dart';
import 'package:fil/pages/wallet/qr_code.dart';
import 'package:fil/pages/wallet/select.dart';
import 'package:fil/routes/path.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

List<GetPage> getWalletRoutes() {
  var list = <GetPage>[];
  var select = GetPage(name: walletSelectPage, page: () => WalletSelectPage());
  var manage = GetPage(name: walletMangePage, page: () => WalletManagePage());
  var mne = GetPage(name: walletMnePage, page: () => WalletMnePage());
  var private =
      GetPage(name: walletPrivatekey, page: () => WalletPrivatekeyPage());
  var main = GetPage(name: walletMainPage, page: () => WalletMainPage());
  var code = GetPage(name: walletCodePage, page: () => WalletCodePage());
  var id = GetPage(name: walletIdPage, page: () => IdWalletPage());
  var appMain = GetPage(name: mainPage, page: () => MainPage());
  list
    ..add(appMain)
    ..add(select)
    ..add(manage)
    ..add(mne)
    ..add(private)
    ..add(main)
    ..add(code)
    ..add(id);
  return list;
}
