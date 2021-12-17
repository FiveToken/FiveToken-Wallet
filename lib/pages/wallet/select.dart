import 'package:fil/bloc/select/select_bloc.dart';
import 'package:fil/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/card.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
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
  var box = OpenedBox.walletInstance;

  @override
  void initState() {
    super.initState();
  }

  void deleteIdWallet(context, state,  String hash) async {
    BlocProvider.of<SelectBloc>(context).add(IdDeleteEvent(hash: hash));
    bool needSwitch = hash == $store.wal.groupHash;
    var box = OpenedBox.walletInstance;
    var keys = box.values
        .where((wal) => wal.groupHash == hash && wal.type == WalletType.id)
        .map((wal) => wal.key);
    box.deleteAll(keys);
    if (box.values.isEmpty) {
      goInit();
    } else {
      deleteAndSwitch(state, needSwitch);
    }
  }

  void deleteImprotWallet(context, state, ChainWallet wal, Network net) async {
   await BlocProvider.of<SelectBloc>(context).add(ImportDeleteEvent(wal: wal, net: net));
    if (box.values.isEmpty) {
      goInit();
    } else {
      bool needSwitch = wal.address == $store.wal.address;
      deleteAndSwitch(state, needSwitch);
    }
  }

  void deleteAndSwitch(state, bool needSwitch) {
    if (needSwitch) {
      if (state.idWalletMap.isNotEmpty) {
        var list = state.idWalletMap.entries.first.value
            .where((wal) => wal.rpc == $store.net.rpc)
            .toList();

        if (list.isNotEmpty) {
          var wallet = list[0];
          $store.setWallet(wallet);
          Global.store.setString('currentWalletAddress', wallet.key);
        }
      } else {
        $store.setWallet(state.importList[0]);
        Global.store.setString('currentWalletAddress', state.importList[0].key);
      }
    }
  }

  void goInit() {
    $store.setNet(Network.filecoinMainNet);
    Global.store.remove('currentWalletAddress');
    Global.store.setString('activeNetwork', Network.filecoinMainNet.rpc);
    Get.offAllNamed(initLangPage);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => SelectBloc()..add(IdDeleteEvent())..add(ImportDeleteEvent()),
        child: BlocBuilder<SelectBloc, SelectState>(
            builder: (context, state){
               var entry = state.idWalletMap.entries.toList();
               return  CommonScaffold(
                   title: 'selectWallet'.tr,
                   grey: true,
                   hasFooter: false,
                   actions: [
                     GestureDetector(
                       child: Padding(
                         padding: EdgeInsets.only(right: 12),
                         child: Icon(Icons.add_circle_outline,color: CustomColor.black ),
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
                                               deleteIdWallet(context, state, hash);
                                             });
                                       },
                                       onSet: () async {
                                         await Get.toNamed(walletIdPage, arguments: {'groupHash': hash});
                                         BlocProvider.of<SelectBloc>(context)..add(IdUpdateEvent());
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
                                         Global.lockFromInit = false;
                                         Get.offAndToNamed(mainPage);
                                         // Navigator.of(context).popUntil(
                                         //         (route) => route.settings.name == mainPage
                                         // );
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
                                 children: List.generate(state.importList.length, (index) {
                                   var wal = state.importList[index];
                                   var net = Network.getNetByRpc(wal.rpc);
                                   return SwiperWidget(
                                     active: $store.wal.key == wal.key,
                                     onDelete: () {
                                       showDeleteDialog(context,
                                           title: 'deleteAddr'.tr,
                                           content: 'confirmDelete'.tr, onDelete: () {
                                             deleteImprotWallet(context, state, wal, net);
                                           });
                                     },
                                     onSet: () async{
                                       await Get.toNamed(walletMangePage,
                                           arguments: {'net': net, 'wallet': wal});
                                       BlocProvider.of<SelectBloc>(context).add(ImportUpdateEvent());
                                     },
                                     onTap: () {
                                       $store.setWallet(wal);
                                       $store.setNet(net);
                                       Global.eventBus.fire(WalletChangeEvent());
                                       Global.store
                                           .setString('currentWalletAddress', wal.key);
                                       Global.store.setString('activeNetwork', net.rpc);
                                       Global.lockFromInit = false;
                                       Get.offAndToNamed(mainPage);
                                       // Navigator.of(context).popUntil(
                                       //         (route) => route.settings.name == mainPage);
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
                           visible: state.importList.isNotEmpty,
                         ),
                       ],
                     ),
                   )
               );
            }
        )
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
