import 'package:fil/index.dart';

List<GetPage> getInitRoutes() {
  var list = <GetPage>[];
  var lang = GetPage(
      name: initLangPage,
      page: () => SelectLangPage(),
      transition: Transition.fadeIn);
  var wallet = GetPage(name: initWalletPage, page: () => WalletInitPage());
  list..add(wallet)..add(lang);
  return list;
}
