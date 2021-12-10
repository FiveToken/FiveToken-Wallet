import 'package:fil/index.dart';
import 'package:fil/routes/wallet.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import './create.dart';
import './other.dart';
import 'transfer.dart';
import './init.dart';
import './address.dart';
import './pass.dart';
import './net.dart';

class GetTranstionPage {}

List<GetPage> list = [];
List<GetPage> initRoutes() {
  var list = <GetPage>[];
  list
    ..addAll(getOtherRoutes())
    ..addAll(getTransferRoutes())
    ..addAll(getCreateRoutes())
    ..addAll(getInitRoutes())
    ..addAll(getWalletRoutes())
    ..addAll(getAddressBookRoutes())
    ..addAll(getNetRoutes())
    ..addAll(getPassRoutes());
  return list;
}
