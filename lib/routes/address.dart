import 'package:fil/index.dart';
import 'package:fil/pages/address/select.dart';

List<GetPage> getAddressBookRoutes() {
  var list = <GetPage>[];
  var index =
      GetPage(name: addressIndexPage, page: () => AddressBookIndexPage());
  var add = GetPage(name: addressAddPage, page: () => AddressBookAddPage());
  var select =GetPage(name: addressSelectPage, page: ()=>AddressBookSelectPage());
  list..add(index)..add(add)..add(select);
  return list;
}
