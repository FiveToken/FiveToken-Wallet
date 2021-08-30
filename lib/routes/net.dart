import 'package:fil/index.dart';
import 'package:fil/pages/net/token.dart';

List<GetPage> getNetRoutes() {
  var list = <GetPage>[];
  var index = GetPage(name: netIndexPage, page: () => NetIndexPage());
  var add = GetPage(name: netAddPage, page: () => NetAddPage());
  var token = GetPage(name: netTokenAddPage, page: () => TokenAddPage());
  list..add(index)..add(add)..add(token);
  return list;
}
