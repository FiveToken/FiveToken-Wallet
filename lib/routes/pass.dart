import 'package:fil/pages/pass/init.dart';
import 'package:fil/pages/pass/reset.dart';
import 'package:fil/routes/path.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

List<GetPage> getPassRoutes() {
  var list = <GetPage>[];
  var lang = GetPage(name: passwordSetPage, page: () => PassInitPage());
  var wallet = GetPage(name: passwordResetPage, page: () => PassResetPage());
  list..add(wallet)..add(lang);
  return list;
}
