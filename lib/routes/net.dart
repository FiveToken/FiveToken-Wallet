import 'package:fil/index.dart';
import 'package:fil/pages/net/add.dart';
import 'package:fil/pages/net/list.dart';
import 'package:fil/pages/net/token.dart';
import 'package:fil/routes/path.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

List<GetPage> getNetRoutes() {
  var list = <GetPage>[];
  var index = GetPage(name: netIndexPage, page: () => NetIndexPage());
  var add = GetPage(name: netAddPage, page: () => NetAddPage());
  var token = GetPage(name: netTokenAddPage, page: () => TokenAddPage());
  list..add(index)..add(add)..add(token);
  return list;
}
