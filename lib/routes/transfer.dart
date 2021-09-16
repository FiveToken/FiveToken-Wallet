import 'package:fil/index.dart';
import 'package:fil/pages/transfer/transfer.dart';

List<GetPage> getTransferRoutes() {
  List<GetPage> list = [];
  var transfer =
      GetPage(name: filTransferPage, page: () => FilTransferNewPage());
  var detail = GetPage(name: filDetailPage, page: () => FilDetailPage());
  var gas = GetPage(name: filGasPage, page: () => ChainGasPage());
  list..add(transfer)..add(detail)..add(gas);
  return list;
}
