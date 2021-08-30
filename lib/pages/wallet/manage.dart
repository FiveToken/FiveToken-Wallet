import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/index.dart';

class WalletManagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletManagePageState();
  }
}

class WalletManagePageState extends State<WalletManagePage> {
  ChainWallet wallet = Get.arguments['wallet'];
  Network net = Get.arguments['net'];
  TextEditingController controller = TextEditingController();
  bool get isId {
    return wallet.type == 0;
  }

  String get addr {
    return wallet.addr;
  }

  CardItem get nameItem {
    return CardItem(
      label: isId ? 'idName'.tr : 'walletName'.tr,
      onTap: () {
        controller.text = wallet.label;
        var hash = wallet.groupHash;

        showCustomDialog(
            context,
            Container(
              child: Column(
                children: [
                  CommonTitle(
                    'changeWalletName'.tr,
                    showDelete: true,
                  ),
                  Padding(
                    child: Field(
                      autofocus: true,
                      controller: controller,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  ),
                  Divider(
                    height: 1,
                  ),
                  Container(
                    height: 40,
                    child: Row(
                      children: [
                        Expanded(
                            child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            child: CommonText(
                              'cancel'.tr,
                            ),
                            alignment: Alignment.center,
                          ),
                          onTap: () {
                            Get.back();
                          },
                        )),
                        Container(
                          width: .2,
                          color: CustomColor.grey,
                        ),
                        Expanded(
                            child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            child: CommonText(
                              'sure'.tr,
                              color: CustomColor.primary,
                            ),
                            alignment: Alignment.center,
                          ),
                          onTap: () {
                            var newLabel = controller.text.trim();
                            if (newLabel == '') {
                              showCustomError('enterName'.tr);
                              return;
                            }
                            if (newLabel.length > 20) {
                              showCustomError('nameTooLong'.tr);
                              return;
                            }
                            wallet.label = newLabel;
                            if (wallet.type == 0) {
                              if (wallet.groupHash == $store.wal.groupHash) {
                                $store.changeWalletName(newLabel);
                              }
                            } else {
                              if (wallet.key == $store.wal.key) {
                                $store.changeWalletName(newLabel);
                              }
                            }

                            List<ChainWallet> list = [];
                            if (wallet.type != 2) {
                              list = OpenedBox.walletInstance.values
                                  .where((wal) => wal.groupHash == hash)
                                  .toList();
                            } else {
                              list = [wallet];
                            }
                            list.forEach((wal) {
                              wal.label = newLabel;
                              OpenedBox.walletInstance.put(wal.key, wal);
                            });
                            setState(() {});
                            Get.back();
                            showCustomToast('changeNameSucc'.tr);
                          },
                        )),
                      ],
                    ),
                  )
                ],
              ),
            ),
            color: CustomColor.bgGrey);
      },
      append: Row(
        children: [
          Container(
            width: 150,
            alignment: Alignment.centerRight,
            child: SingleChildScrollView(
              child: CommonText(
                wallet.label,
                align: TextAlign.right,
              ),
              scrollDirection: Axis.horizontal,
            ),
          ),
          ImageAr
        ],
      ),
    );
  }

  TabCard get exportCard {
    List<CardItem> list = [
      CardItem(
          label: 'pkExport'.tr,
          onTap: () {
            showPassDialog(context, (String pass) async {
              var private = await wallet.getPrivateKey(pass);
              Get.toNamed(walletPrivatekey,
                  arguments: {'private': private, 'wallet': wallet});
            }, wallet: wallet);
          }),
      CardItem(
          label: 'mneExport'.tr,
          onTap: () {
            showPassDialog(context, (String pass) async {
              try {
                var ck = await wallet.getPrivateKey(pass);
                var mne = aesDecrypt(wallet.mne, ck);
                Get.toNamed(walletMnePage, arguments: {'mne': mne});
              } catch (e) {
                showCustomError(e.toString());
                print(e);
              }
            }, wallet: wallet);
          }),
    ];
    if (wallet.type == 2) {
      list.removeAt(1);
    }
    return TabCard(
      items: list,
    );
  }

  CardItem get addrItem {
    return CardItem(
      label: 'walletAddr'.tr,
      append: CommonText(
        dotString(str: addr),
      ),
    );
  }

  CardItem get passItem {
    return CardItem(
      label: isId ? 'changeIdPass'.tr : 'changePass'.tr,
      onTap: () {
        Get.toNamed(passwordResetPage, arguments: {'wallet': wallet});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'manageWallet'.tr,
      grey: true,
      hasFooter: false,
      body: Padding(
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            isId
                ? TabCard(
                    items: [nameItem, passItem],
                  )
                : TabCard(
                    items: [
                      addrItem,
                      nameItem,
                    ],
                  ),
            SizedBox(
              height: 15,
            ),
            isId
                ? TabCard(
                    items: [
                      CardItem(
                        label: 'walletAddr'.tr,
                        onTap: () {},
                        append: CommonText(
                          dotString(str: addr),
                        ),
                      )
                    ],
                  )
                : exportCard,
            SizedBox(
              height: 15,
            ),
            isId
                ? exportCard
                : TabCard(
                    items: [passItem],
                  )
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
