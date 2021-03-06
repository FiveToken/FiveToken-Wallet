import 'package:fil/chain/wallet.dart';
import 'package:fil/index.dart';

class AddressBookWalletSelect extends StatelessWidget {
  List<ChainWallet> get idWallets {
    var list = OpenedBox.walletInstance.values
        .where((wal) =>
            wal.type == 0 &&
            wal.rpc == $store.net.rpc &&
            wal.key != $store.wal.key)
        .toList();
    return list;
  }

  List<ChainWallet> get importWallets {
    var list = OpenedBox.walletInstance.values
        .where((wal) =>
            wal.type != 0 &&
            wal.rpc == $store.net.rpc &&
            wal.key != $store.wal.key)
        .toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
        hasFooter: false,
        title: 'selectWallet'.tr,
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(12, 20, 12, 40),
          child: Layout.colStart([
            Visibility(
                visible: idWallets.isNotEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText('idWallet'.tr),
                    SizedBox(
                      height: 12,
                    ),
                    Column(
                      children: List.generate(idWallets.length, (index) {
                        var wallet = idWallets[index];
                        return Container(
                          child: TapCardWidget(
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonText.white(wallet.label),
                                SizedBox(
                                  height: 5,
                                ),
                                CommonText.white(dotString(str: wallet.addr),
                                    size: 12),
                              ],
                            ),
                            onTap: () {
                              Get.back(result: wallet);
                            },
                          ),
                          margin: EdgeInsets.only(bottom: 12),
                        );
                      }),
                    ),
                  ],
                )),
            Visibility(
                visible: importWallets.isNotEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText('import'.tr),
                    SizedBox(
                      height: 12,
                    ),
                    Column(
                      children: List.generate(importWallets.length, (index) {
                        var wallet = importWallets[index];
                        return Container(
                          child: TapCardWidget(
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CommonText.white(wallet.label),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  CommonText.white(dotString(str: wallet.addr),
                                      size: 12),
                                ],
                              ), onTap: () {
                            Get.back(result: wallet);
                          }),
                          margin: EdgeInsets.only(bottom: 12),
                        );
                      }),
                    )
                  ],
                ))
          ]),
        ));
  }
}
