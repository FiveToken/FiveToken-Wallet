import 'package:fil/index.dart';
import 'package:fil/pages/main/index.dart';
import 'package:fil/routes/wallet.dart';
import './create.dart';
import './other.dart';
import 'transfer.dart';
import './init.dart';
import './address.dart';
import './pass.dart';

class GetTranstionPage {}

List<GetPage> list = [];
List<GetPage> initRoutes() {
  var list = <GetPage>[];
  var main = GetPage(name: mainPage, page: () => MainPage());
  list
    ..add(main)
    ..addAll(getOtherRoutes())
    ..addAll(getTransferRoutes())
    ..addAll(getCreateRoutes())
    ..addAll(getInitRoutes())
    ..addAll(getWalletRoutes())
    ..addAll(getAddressBookRoutes())
    ..addAll(getPassRoutes());
  return list;
}
