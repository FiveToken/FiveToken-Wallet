import 'package:fil/index.dart';
import 'package:fil/pages/address/net.dart';
import 'package:fil/pages/address/select.dart';
import 'package:fil/pages/address/wallet.dart';

List<GetPage> getAddressBookRoutes() {
  var list = <GetPage>[];
  var index =
      GetPage(name: addressIndexPage, page: () => AddressBookIndexPage());
  var add = GetPage(name: addressAddPage, page: () => AddressBookAddPage());
  var select =
      GetPage(name: addressSelectPage, page: () => AddressBookSelectPage());
  var net = GetPage(name: addressNetPage, page: () => AddressBookNetPage());
  var wallet =
      GetPage(name: addressWalletPage, page: () => AddressBookWalletSelect());
  list..add(index)..add(add)..add(select)..add(net)..add(wallet);
  return list;
}
