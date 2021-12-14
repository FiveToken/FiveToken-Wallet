import 'package:fil/pages/other/lang.dart';
import 'package:fil/pages/other/lock.dart';
import 'package:fil/pages/other/scan.dart';
import 'package:fil/pages/other/set.dart';
import 'package:fil/routes/path.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
List<GetPage> getOtherRoutes() {
  var list = <GetPage>[];
  var scan = GetPage(name: scanPage, page: () => ScanPage());
  var setting = GetPage(name: setPage, page: () => SetPage());
  var lang = GetPage(name: langPage, page: () => LangPage());
  var lock = GetPage(name: lockPage, page: ()=> LockPage());
  list..add(scan)..add(setting)..add(lang)..add(lock);
  return list;
}
