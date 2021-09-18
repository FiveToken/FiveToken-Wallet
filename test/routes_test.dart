import 'package:fil/routes/address.dart';
import 'package:fil/routes/create.dart';
import 'package:fil/routes/init.dart';
import 'package:fil/routes/net.dart';
import 'package:fil/routes/other.dart';
import 'package:fil/routes/pass.dart';
import 'package:fil/routes/routes.dart';
import 'package:fil/routes/transfer.dart';
import 'package:fil/routes/wallet.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("test generate routes", () {
    var addrList = getAddressBookRoutes().length;
    var transList = getTransferRoutes().length;
    var otherList = getOtherRoutes().length;
    var initList = getInitRoutes().length;
    var walletList = getWalletRoutes().length;
    var netList = getNetRoutes().length;
    var passList = getPassRoutes().length;
    var createList = getCreateRoutes().length;
    var allList = initRoutes().length;
    expect(
        allList,
        addrList +
            transList +
            otherList +
            initList +
            walletList +
            netList +
            passList +
            createList);
  });
}
