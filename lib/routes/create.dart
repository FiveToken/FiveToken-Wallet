import 'package:fil/index.dart';
import 'package:fil/pages/create/import.dart';
import 'package:fil/pages/create/warn.dart';

List<GetPage> getCreateRoutes() {
  var list = <GetPage>[];
  var mne = GetPage(name: mnePage, page: () => MneCreatePage());
  var mneCheck = GetPage(name: mneCheckPage, page: () => MneCheckPage());
  var importPrivate =
      GetPage(name: importPrivateKeyPage, page: () => ImportPrivateKeyPage());
  var importMne = GetPage(name: importMnePage, page: () => ImportMnePage());
  var warn = GetPage(name: createWarnPage, page: () => CreateWarnPage());
  var import = GetPage(name: importIndexPage, page: () => ImportIndexPage());
  list
    ..add(mne)
    ..add(mneCheck)
    ..add(importPrivate)
    ..add(importMne)
    ..add(import)
    ..add(warn);
  return list;
}
