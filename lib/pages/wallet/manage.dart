import 'package:fil/index.dart';

class WalletManagePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletManagePageState();
  }
}

class WalletManagePageState extends State<WalletManagePage> {
  Wallet wallet;
  TextEditingController controller = TextEditingController();
  var box = Hive.box<Wallet>(addressBox);
  @override
  Widget build(BuildContext context) {
    wallet = Global.cacheWallet;
    var label = wallet.label;
    var mne = wallet.mne;
    var addr = wallet.address;
    var hasMne = mne != '';
    var items = [
      CardItem(
          label: 'pkExport'.tr,
          onTap: () {
            showPassDialog(context, (String pass) async {
              var sk =
                  await getPrivateKey(wallet.addrWithNet, pass, wallet.skKek);
              Get.toNamed(walletPrivatekey, arguments: {'pk': sk});
            });
          }),
      CardItem(
          label: 'mneExport'.tr,
          onTap: () {
            showPassDialog(context, (String pass) async {
              try {
                var ck =
                    await getPrivateKey(wallet.addrWithNet, pass, wallet.skKek);
                var mne = aesDecrypt(wallet.mne, ck);
                Get.toNamed(walletMnePage, arguments: {'mne': mne});
              } catch (e) {
                showCustomError(e.toString());
                print(e);
              }
            });
          }),
    ];
    if (!hasMne) {
      items.removeAt(1);
    }
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
            TabCard(
              items: [
                CardItem(
                  label: 'walletAddr'.tr,
                  onTap: () {},
                  append: CommonText(
                    dotString(str: addr),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 15,
            ),
            TabCard(
              items: [
                CardItem(
                  label: 'walletName'.tr,
                  onTap: () {
                    controller.text = label;
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 20),
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
                                        box.put(addr, wallet);
                                        singleStoreController
                                            .changeWalletName(newLabel);
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
                      CommonText(
                        label,
                      ),
                      ImageAr
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            TabCard(
              items: items,
            ),
            SizedBox(
              height: 15,
            ),
            TabCard(
              items: [
                CardItem(
                  label: 'changePass'.tr,
                  onTap: () {
                    Get.toNamed(passwordResetPage).then((value) {
                      setState(() {});
                    });
                  },
                )
              ],
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
