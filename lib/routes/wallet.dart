import 'package:fil/index.dart';

List<GetPage> getWalletRoutes() {
  var list = <GetPage>[];
  var select = GetPage(name: walletSelectPage, page: () => WalletSelectPage());
  var manage = GetPage(name: walletMangePage, page: () => WalletManagePage());
  var mne = GetPage(name: walletMnePage, page: () => WalletMnePage());
  var private =
      GetPage(name: walletPrivatekey, page: () => WalletPrivatekeyPage());
  var main = GetPage(name: walletMainPage, page: () => WalletMainPage());
  var code = GetPage(name: walletCodePage, page: () => WalletCodePage());
  list..add(select)..add(manage)..add(mne)..add(private)..add(main)..add(code);
  return list;
}
