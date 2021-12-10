import 'package:fil/bloc/add/add_bloc.dart';
import 'package:fil/request/global.dart';
import 'package:fil/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:fil/chain/net.dart';
import 'dart:convert' as convert;
import 'package:fbutton/fbutton.dart';
import 'package:oktoast/oktoast.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:fil/widgets/toast.dart';
import 'package:fil/widgets/field.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/index.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/utils/enum.dart';

class NetAddPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NetAddPageState();
  }
}

class NetAddPageState extends State<NetAddPage> {
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController rpcCtrl = TextEditingController();
  TextEditingController chainCtrl = TextEditingController();
  TextEditingController symbolCtrl = TextEditingController();
  TextEditingController browserCtrl = TextEditingController();

  Network net;
  Web3Client client;
  bool readonly = false;
  bool loading = false;
  var box = OpenedBox.netInstance;

  void submit(BuildContext context) async {
    // get controller text
    var name = nameCtrl.text.trim();
    var rpc = rpcCtrl.text.trim();
    var chain = chainCtrl.text.trim();
    var symbol = symbolCtrl.text.trim();
    var browser = browserCtrl.text.trim();

    // text not null
    if (name == '') {
      showCustomError('enterNet'.tr);
      return;
    }
    if (rpc == '') {
      showCustomError('enterRpc'.tr);
      return;
    }
    if(!isValidUrl(rpc)){
      showCustomError('invalidRpc'.tr);
      return;
    }
    if (symbol == '') {
      showCustomError('enterTokenName'.tr);
      return;
    }

    // rpc in supportNet or in netInstance but not edit
    if ((Network.supportNets.map((net) => net.rpc).contains(rpc) ||
        OpenedBox.netInstance.containsKey(rpc)) &&
        !edit) {
      showCustomError('netExist'.tr);
      return;
    }

    client = Web3Client(rpc, http.Client());
    if (this.loading) {
      return;
    }
    // browser not null
    if (browser != '') {
      if (!isValidUrl(browser)) {
        showCustomError('wrongBrowser'.tr);
        return;
      }
      if (browser[browser.length - 1] == '/') {
        browser = browser.substring(0, browser.length - 1);
      }
    }
    this.loading = true;
    try {
      showCustomLoading('Loading');
      Chain.setRpcNetwork(rpc, 'customer');
      var id = await Chain.chainProvider.getNetworkId();
      this.loading = false;
      dismissAllToast();
      // chain
      if (id != chain && chain.trim()!='') {
        showCustomError('errorChainId'.tr);
        return;
      }
      var walletBox = OpenedBox.walletInstance;

      // edit and rpc not in net

      if (edit && net.rpc != rpc) {
        box.delete(net.rpc);
        walletBox.values
            .where((wal) => wal.rpc == net.rpc)
            .toList()
            .forEach((wallet) {
          var wal = wallet.copyWith();
          wal.rpc = rpc;
          walletBox.delete(wallet.key);
          walletBox.put(wal.key, wal);
        });
      }

      // not edit
      if (!edit) {
        //add id wallet for new network
        var wallets = walletBox.values
            .where((wal) => wal.type == WalletType.id && wal.addressType == 'eth')
            .toList();
        Map<String, ChainWallet> map = {};
        for (var wallet in wallets) {
          map[wallet.groupHash] = wallet;
        }
        map.forEach((key, value) {
          var wal = value.copyWith();
          wal.rpc = rpc;
          walletBox.put(wal.key, wal);
        });
      }

      BlocProvider.of<AddBloc>(context)..add(AddListEvent(
          rpc:rpc,
          network: Network(
          name: name,
          addressType: 'eth',
          rpc: rpc,
          netType: 2,
          browser: browser,
          chainId: chain,
          coin: symbol)
      ));
      Get.back();
    } catch (e) {
      this.loading = false;
      dismissAllToast();
      showCustomError('invalidRpc'.tr);
    }
  }

  bool get edit => net != null && net.netType == 2;
  @override
  void initState() {
    super.initState();

    if (Get.arguments != null && Get.arguments['net'] != null) {
      net = Get.arguments['net'] as Network;
      readonly = net.netType != 2;
      nameCtrl.text = net.label;
      browserCtrl.text = net.browser;
      symbolCtrl.text = net.coin;
      chainCtrl.text = net.chainId;
      rpcCtrl.text = net.rpc;
    }
  }

  @override
  void dispose() {
    super.dispose();
    client?.dispose();
  }


  @override
  Widget build(BuildContext context) {
    var kH = MediaQuery.of(context).viewInsets.bottom;
    return BlocProvider(
        create: (context) => AddBloc()..add(AddListEvent())..add(DeleteListEvent()),
        child: BlocBuilder<AddBloc, AddState>(builder: (context, data) {
          return CommonScaffold(
              grey: true,
              title: edit ? 'editNet'.tr : 'net'.tr,
              footerText: 'add'.tr,
              onPressed: ()=>{submit(context)},
              hasFooter: kH == 0 && (net == null || net.netType == 2),
              resizeToAvoidBottomInset: kH != 0,
              footer: edit
                  ? Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                        child: FButton(
                          height: 45,
                          strokeColor: Colors.grey[200],
                          corner: FCorner.all(6),
                          alignment: Alignment.center,
                          text: 'deleteNet'.tr,
                          color: Colors.white,
                          style: TextStyle(color: Colors.black),
                          onPressed:() {
                            showDeleteDialog(
                                context,
                                title: 'deleteNet'.tr,
                                content: 'confimrDeleteNet'.tr, onDelete: () {
                              // OpenedBox.netInstance.delete(net.rpc);
                              BlocProvider.of<AddBloc>(context)..add(DeleteListEvent(rpc: net.rpc));
                              Network network= Network.filecoinMainNet;
                              Network currentNet = $store.network.value;
                              if(currentNet!=null&&net!=null){
                                if(currentNet.chain == net.chain && currentNet.rpc == net.rpc && currentNet.net==net.net ){
                                  $store.setNet(network);
                                }
                              }
                              Get.back();
                            });
                          },
                        )),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                        child: FButton(
                          height: 45,
                          corner: FCorner.all(6),
                          alignment: Alignment.center,
                          color: CustomColor.primary,
                          style: TextStyle(color: Colors.white),
                          text: 'changeNet'.tr,
                          onPressed: ()=>{submit(context)},
                        )),
                  ],
                ),
              )
                  : null,
              body: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  child:
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Visibility(
                        child: CommonText('newRpc'.tr),
                        visible: !readonly,
                    ),
                    Visibility(
                        child: CommonText('byRpc'.tr),
                        visible: !readonly,
                    ),
                    Field(
                      label: 'netName'.tr,
                      placeholder: 'netName'.tr,
                      controller: nameCtrl,
                      enabled: !readonly,
                      selectable: readonly,
                    ),
                    Field(
                      label: 'RPC URL',
                      placeholder: 'newRpc'.tr,
                      controller: rpcCtrl,
                      enabled: !readonly,
                      selectable: readonly,
                    ),
                    Field(
                      label: 'chainId'.tr,
                      placeholder: 'placeholderChainId'.tr,
                      controller: chainCtrl,
                      enabled: !readonly,
                      selectable: readonly,
                    ),
                    Field(
                      label: 'symbol'.tr,
                      placeholder: 'curNetToken'.tr,
                      controller: symbolCtrl,
                      enabled: !readonly,
                      selectable: readonly,
                    ),
                    Field(
                      label: 'browser'.tr,
                      placeholder: 'browserOptional'.tr,
                      controller: browserCtrl,
                      enabled: !readonly,
                      selectable: readonly,
                    ),
                    SizedBox(
                      height: 70,
                    )
                  ]
                  )
              )
          );
        }
        )
    );
  }
}
