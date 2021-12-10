import 'package:fil/index.dart';
import 'package:fil/pages/transfer/confirm.dart';
import 'package:fil/pages/transfer/detail.dart';
import 'package:fil/pages/transfer/gas.dart';
import 'package:fil/pages/transfer/transfer.dart';
import 'package:fil/routes/path.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

List<GetPage> getTransferRoutes() {
  List<GetPage> list = [];
  var transfer =
      GetPage(name: filTransferPage, page: () => FilTransferNewPage());
  var detail = GetPage(name: filDetailPage, page: () => FilDetailPage());
  var gas = GetPage(name: filGasPage, page: () => ChainGasPage());
  var confirm = GetPage(name:transferConfrimPage,page:()=> TransferConfirmPage());
  list..add(transfer)..add(detail)..add(gas)..add(confirm);
  return list;
}
