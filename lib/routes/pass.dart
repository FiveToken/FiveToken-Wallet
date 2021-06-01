import 'package:fil/index.dart';

List<GetPage> getPassRoutes() {
  var list = <GetPage>[];
  var lang = GetPage(name: passwordSetPage, page: () => PassInitPage());
  var wallet = GetPage(name: passwordResetPage, page: () => PassResetPage());
  list..add(wallet)..add(lang);
  return list;
}
