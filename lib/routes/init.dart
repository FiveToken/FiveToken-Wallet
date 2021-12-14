import 'package:fil/pages/init/lang.dart';
import 'package:fil/pages/init/wallet.dart';
import 'package:fil/routes/path.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

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
