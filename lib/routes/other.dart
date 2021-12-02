import 'package:fil/index.dart';
import 'package:fil/pages/other/lang.dart';
import 'package:fil/pages/other/lock.dart';
import 'package:fil/pages/other/lockscreen.dart';
List<GetPage> getOtherRoutes() {
  var list = <GetPage>[];
  var scan = GetPage(name: scanPage, page: () => ScanPage());
  var setting = GetPage(name: setPage, page: () => SetPage());
  var lang = GetPage(name: langPage, page: () => LangPage());
  var lock = GetPage(name: lockPage, page: ()=> LockPage());
  // var lockscreen = GetPage(name: lockScreen, page: ()=> LockScreenPage());
  list..add(scan)..add(setting)..add(lang)..add(lock);
  return list;
}
