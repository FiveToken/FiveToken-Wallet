import 'package:fil/index.dart';
import 'package:fil/pages/wallet/id.dart';

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
  list
    ..add(select)
    ..add(manage)
    ..add(mne)
    ..add(private)
    ..add(main)
    ..add(code)
    ..add(id);
  return list;
}
