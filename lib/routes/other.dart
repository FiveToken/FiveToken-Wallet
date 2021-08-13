import 'package:fil/index.dart';
import 'package:fil/pages/other/lang.dart';

List<GetPage> getOtherRoutes() {
  var list = <GetPage>[];
  var web = GetPage(name: webviewPage, page: () => WebviewPage());
  var scan = GetPage(name: scanPage, page: () => ScanPage());
  var setting = GetPage(name: setPage, page: () => SetPage());
  var lang = GetPage(name: langPage, page: () => LangPage());
  list..add(web)..add(scan)..add(setting)..add(lang);
  return list;
}
