
import 'package:fil/index.dart';

class WalletSelectPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletSelectPageState();
  }
}

class WalletSelectPageState extends State<WalletSelectPage> {
  final ScrollController controller = ScrollController();
  List<Wallet> list = [];
  var box = Hive.box<Wallet>(addressBox);
  void setList() {
    setState(() {
      list = box.values.where((wal) => wal.address!='').toList();
      print(list);
    });
  }

  @override
  void initState() {
    super.initState();
    setList();
  }

  void handleDelete(Wallet wal, int index) {
    var keys = OpenedBox.messageInsance.values
        .where((mes) => mes.owner == wal.addr)
        .map((mes) => mes.signedCid)
        .toList();
    OpenedBox.messageInsance.deleteAll(keys);
    box.delete(wal.addr);
    list.removeAt(index);
    if (list.isEmpty) {
      Global.store.remove('currentWalletAddress');
      singleStoreController.setWallet(Wallet());
      Get.offAllNamed(initLangPage);
    } else {
      var wal = list[0];
      singleStoreController.setWallet(wal);
      Global.store.setString('currentWalletAddress', wal.addrWithNet);
      setList();
      showCustomToast('deleteSucc'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      title: 'selectWallet'.tr,
      grey: true,
      hasFooter: false,
      actions: [
        GestureDetector(
          child: Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.add_circle_outline),
          ),
          onTap: () {
            showModalBottomSheet(
                shape: RoundedRectangleBorder(borderRadius: CustomRadius.top),
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonTitle(
                          'addWallet'.tr,
                          showDelete: true,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TabCard(
                                items: [
                                  CardItem(
                                    label: 'createWallet'.tr,
                                    onTap: () {
                                      Get.back();
                                      Get.toNamed(createWarnPage);
                                    },
                                  )
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(0, 20, 0, 15),
                                child: CommonText(
                                  'importWallet'.tr,
                                  color: CustomColor.primary,
                                ),
                              ),
                              TabCard(
                                items: [
                                  CardItem(
                                    label: 'pkImport'.tr,
                                    onTap: () {
                                      Get.back();
                                      Get.toNamed(importPrivateKeyPage);
                                    },
                                  ),
                                  CardItem(
                                    label: 'mneImport'.tr,
                                    onTap: () {
                                      Get.back();
                                      Get.toNamed(importMnePage);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  );
                });
          },
        )
      ],
      body: SingleChildScrollView(
        //padding: EdgeInsets.only(top: 20),
        child: Column(
          children: List.generate(list.length, (index) {
            var wal = list[index];
            return SwiperItem(
              onTap: () {
                Global.store.setString('currentWalletAddress', wal.address);
                singleStoreController.setWallet(wal);
                Get.offAllNamed(mainPage);
              },
              showBalance: true,
              wallet: wal,
              onDelete: () {
                showDeleteDialog(context,
                    title: 'deleteAddr'.tr,
                    content: 'confirmDelete'.tr, onDelete: () {
                  handleDelete(wal, index);
                });
              },
              onSet: () {
                Global.cacheWallet = wal;
                Get.toNamed(walletMangePage).then((value) {
                  setList();
                });
              },
            );
          }),
        ),
      ),
    );
  }
}
