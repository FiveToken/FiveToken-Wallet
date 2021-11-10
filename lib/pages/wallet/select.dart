
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/card.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
// import 'package:fil/index.dart';
import 'package:fil/store/store.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/dialog.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/actions/event.dart';
import 'package:fil/models/index.dart';

class WalletSelectPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletSelectPageState();
  }
}

class WalletSelectPageState extends State<WalletSelectPage> {
  final ScrollController controller = ScrollController();
  List<ChainWallet> list = [];
  List<List<String>> idWallets = [];
  var box = OpenedBox.walletInstance;

  void setList() {
    List<List<String>> ids = [];
    Map<String, String> map = {};
    box.values.forEach((wal) {
      if (wal.type == 0) {
        map[wal.groupHash] = wal.label;
      }
    });
    map.forEach((key, value) {
      ids.add([key, value]);
    });
    setState(() {
      list = box.values.where((wal) => wal.type != 0).toList();
      idWallets = ids;
    });
  }

  List<ChainWallet> get importWallets {
    return box.values.where((wal) => wal.type != 0).toList();
  }

  Map<String, List<ChainWallet>> get idWalletMap {
    Map<String, List<ChainWallet>> res = {};
    box.values.where((wal) => wal.type == 0).forEach((wal) {
      if (res.containsKey(wal.groupHash)) {
        res[wal.groupHash].add(wal);
      } else {
        res[wal.groupHash] = [wal];
      }
    });
    return res;
  }

  @override
  void initState() {
    super.initState();
    setList();
  }

  void deleteIdWallet(String hash) async {
    bool needSwitch = hash == $store.wal.groupHash;
    var keys = box.values
        .where((wal) => wal.groupHash == hash && wal.type == 0)
        .map((wal) => wal.key);
    await box.deleteAll(keys);
    if (box.values.isEmpty) {
      goInit();
    } else {
      deleteAndSwitch(needSwitch);
    }
  }

  void deleteImprotWallet(ChainWallet wal, Network net) async {
    await box.delete(wal.key);
    if (box.values.isEmpty) {
      goInit();
    } else {
      bool needSwitch = wal.address == $store.wal.address;
      deleteAndSwitch(needSwitch);
    }
  }

  void deleteAndSwitch(bool needSwitch) {
    if (needSwitch) {
      if (idWalletMap.isNotEmpty) {
        var list = idWalletMap.entries.first.value
            .where((wal) => wal.rpc == $store.net.rpc)
            .toList();

        if (list.isNotEmpty) {
          var wallet = list[0];
          $store.setWallet(wallet);
          Global.store.setString('currentWalletAddress', wallet.key);
        }
      } else {
        $store.setWallet(importWallets[0]);
        Global.store.setString('currentWalletAddress', importWallets[0].key);
      }
    }
    setState(() {});
  }

  void goInit() {
    $store.setNet(Network.filecoinMainNet);
    Global.store.remove('currentWalletAddress');
    Global.store.setString('activeNetwork', Network.filecoinMainNet.rpc);
    Get.offAllNamed(initLangPage);
  }

  @override
  Widget build(BuildContext context) {
    var entry = idWalletMap.entries.toList();
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
                              TapItemCard(
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
                              TapItemCard(
                                items: [
                                  CardItem(
                                    label: 'pkImport'.tr,
                                    onTap: () {
                                      Get.back();
                                      Get.toNamed(importIndexPage,
                                          arguments: {'type': 2});
                                    },
                                  ),
                                  CardItem(
                                    label: 'mneImport'.tr,
                                    onTap: () {
                                      Get.back();
                                      Get.toNamed(importIndexPage,
                                          arguments: {'type': 1});
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
        padding: EdgeInsets.fromLTRB(0, 20, 0, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
                visible: entry.isNotEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: CommonText('idMulti'.tr),
                      padding: EdgeInsets.only(left: 12),
                    ),
                    Column(
                      children: List.generate(entry.length, (index) {
                        var hash = entry[index].key;
                        var wals = entry[index].value;
                        return SwiperWidget(
                          active: hash == $store.wal.groupHash,
                          onDelete: () {
                            showDeleteDialog(context,
                                title: 'deleteIdWallet'.tr,
                                content: 'confirmDeleteId'.tr, onDelete: () {
                              deleteIdWallet(hash);
                            });
                          },
                          onSet: () {
                            Get.toNamed(walletIdPage,
                                arguments: {'groupHash': hash}).then((value) {
                              setList();
                            });
                          },
                          onTap: () {
                            if (hash != $store.wal.groupHash) {
                              var wallets = OpenedBox.walletInstance.values
                                  .where((wal) =>
                                      wal.groupHash == hash &&
                                      wal.rpc == $store.net.rpc)
                                  .toList();
                              if (wallets.isNotEmpty) {
                                $store.setWallet(wallets[0]);
                                Global.store.setString(
                                    'currentWalletAddress', wallets[0].key);
                              }
                            }
                            Global.eventBus.fire(WalletChangeEvent());
                            Navigator.of(context).popUntil(
                                (route) => route.settings.name == mainPage);
                          },
                          id: hash,
                          child: Container(
                            height: 70,
                            alignment: Alignment.centerLeft,
                            child:
                                CommonText(wals[0].label, color: Colors.white),
                          ),
                        );
                      }),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                  ],
                )),
            Visibility(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: CommonText('import'.tr),
                    padding: EdgeInsets.only(left: 12),
                  ),
                  Column(
                    children: List.generate(importWallets.length, (index) {
                      var wal = importWallets[index];
                      var net = Network.getNetByRpc(wal.rpc);
                      return SwiperWidget(
                        active: $store.wal.key == wal.key,
                        onDelete: () {
                          showDeleteDialog(context,
                              title: 'deleteAddr'.tr,
                              content: 'confirmDelete'.tr, onDelete: () {
                            deleteImprotWallet(wal, net);
                          });
                        },
                        onSet: () {
                          Get.toNamed(walletMangePage,
                                  arguments: {'net': net, 'wallet': wal})
                              .then((value) {
                            setState(() {});
                          });
                        },
                        onTap: () {
                          $store.setWallet(wal);
                          $store.setNet(net);
                          Global.eventBus.fire(WalletChangeEvent());
                          Global.store
                              .setString('currentWalletAddress', wal.key);
                          Global.store.setString('activeNetwork', net.rpc);
                          Navigator.of(context).popUntil(
                              (route) => route.settings.name == mainPage);
                        },
                        id: wal.address,
                        child: Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CommonText.white(wal.label, size: 15),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  CommonText.white(dotString(str: wal.addr),
                                      size: 12)
                                ],
                              ),
                              CommonText.white(net.label),
                            ],
                          ),
                        ),
                      );
                    }),
                  )
                ],
              ),
              visible: importWallets.isNotEmpty,
            ),
          ],
        ),
      ),
    );
  }
}

class SwiperWidget extends StatelessWidget {
  final String id;
  final Noop onDelete;
  final Noop onSet;
  final Noop onTap;
  final bool showBalance;
  final Widget child;
  final bool active;
  SwiperWidget(
      {this.onDelete,
      this.onSet,
      this.onTap,
      this.id,
      this.child,
      this.active = false,
      this.showBalance = false});
  @override
  Widget build(BuildContext context) {
    return SwipeActionCell(
      key: ValueKey(id),
      trailingActions: [
        SwipeAction(
            color: Colors.transparent,
            content: _getIconButton(
                CustomColor.red,
                Image(
                  image: AssetImage('icons/delete.png'),
                )),
            onTap: (handler) async {
              handler(false);
              onDelete();
            }),
        SwipeAction(
            content: _getIconButton(
                Color(0xffE8CC5C),
                Image(
                  image: AssetImage('icons/set.png'),
                )),
            color: Colors.transparent,
            onTap: (handler) {
              handler(false);
              onSet();
            }),
      ],
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 15, 12, 0),
        child: GestureDetector(
          child: Container(
            height: 70,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: child,
            decoration: BoxDecoration(
                borderRadius: CustomRadius.b8,
                color: active ? CustomColor.primary : Color(0xff8297B0)),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}

Widget _getIconButton(Color color, Widget icon) {
  return Container(
    width: 50,
    height: 50,
    padding: EdgeInsets.all(12),
    margin: EdgeInsets.only(top: 20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25),
      color: color,
    ),
    child: icon,
  );
}
