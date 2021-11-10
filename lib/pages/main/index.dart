import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/common/index.dart';
// import 'package:fil/index.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fbutton/fbutton.dart';
import 'package:fil/pages/main/drawer.dart';
import 'package:fil/pages/main/widgets/net.dart';
import 'package:fil/pages/main/widgets/price.dart';
import 'package:fil/pages/main/widgets/token.dart';
import 'package:fil/pages/transfer/transfer.dart';
import 'package:logger/logger.dart';
import 'package:oktoast/oktoast.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import './walletConnect.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/toast.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/dialog.dart';
import 'package:fil/widgets/bottomSheet.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/field.dart';
import 'package:fil/widgets/fresh.dart';
import 'package:fil/actions/event.dart';
import 'package:fil/models/index.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/init/hive.dart';
import 'package:flotus/flotus.dart';
import 'package:bls/bls.dart';
import 'package:fil/chain/provider.dart';
import 'package:fil/chain/gas.dart';
import 'package:fil/pages/wallet/main.dart';
import 'package:fil/pages/other/scan.dart';
import 'package:fil/widgets/index.dart';
import 'package:http/http.dart';


typedef WCCallback = List<JsonRpc Function(WCSession, JsonRpc)> Function(
    String type);

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainPageState();
  }
}

class MainPageState extends State<MainPage> {
  final TextEditingController controller = TextEditingController();
  var box = OpenedBox.walletInstance;
  Timer timer;
  WCSession connectedSession;
  WCMeta meta;
  Box<Nonce> nonceBoxInstance = OpenedBox.nonceInsance;
  final Web3Client client = Web3Client($store.net.url, Client());
  ChainProvider provider;
  Worker worker;

  @override
  void initState() {
    super.initState();

    // var isCreate = false;
    // if (Get.arguments != null && Get.arguments['create'] != null) {
    //   isCreate = Get.arguments['create'] as bool;
    // }
    var show = $store.wal.label == DefaultWalletName;
    if (show) {
      showChangeNameDialog();
    }
    if (Get.arguments != null && Get.arguments['url'] != null) {
      var url = Get.arguments['url'] as String;
      nextTick(() {
        connectWallet(url);
      });
    }
    reConnect();
    Global.eventBus.on<WalletChangeEvent>().listen((event) {
      print('wallet change');
      getBalance();
    });
  }

  @override
  void dispose() {
    super.dispose();
    worker?.dispose();
  }

  List<JsonRpc Function(WCSession, JsonRpc)> genCallback(String type) {
    var callback = (WCSession session, JsonRpc rpc) {
      if ($store.net.addressType != type) {
        showCustomError('wrongNet'.tr);
        session.sendResponse(rpc.id, '$type\_sendTransaction',
            error: {'message': 'Reject'});
      }
      var params = rpc.params;
      if (params != null && params is List && params.isNotEmpty) {
        try {
          var p = params[0] as Map<String, dynamic>;
          var to = p['to'] as String;
          var value = p['value'] as String;
          BigInt valueNum;
          if (value.startsWith('0x')) {
            valueNum = hexToInt(value);
          } else {
            valueNum = BigInt.tryParse(value);
          }
          if (to != null && value != null) {
            handleTransaction(
                session: session,
                rpc: rpc,
                to: to,
                value: valueNum,
                type: type);
          } else {
            showCustomError('errorParams'.tr);
          }
        } catch (e) {
          showCustomError(e.toString());
          session.sendResponse(rpc.id, '$type\_sendTransaction',
              error: {'message': 'Reject'});
        }
      } else {
        showCustomError('errorParams'.tr);
      }
      return rpc;
    };
    return [callback];
  }

  List<JsonRpc Function(WCSession, JsonRpc)> get sessionUpdateCallback {
    return [
      (WCSession session, JsonRpc rpc) {
        if (!session.isConnected) {
          Global.store.remove('wcSession');
          setState(() {
            this.connectedSession = null;
            this.meta = null;
          });
        }
        return rpc;
      }
    ];
  }

  void reConnect() {
    var wcSession = Global.store.getString('wcSession');
    if (wcSession != null) {
      try {
        var m = jsonDecode(wcSession) as Map<String, dynamic>;
        var wc = WCSession(
            ourPeerId: m['ourPeerId'],
            bridgeUrl: m['bridgeUrl'],
            logger: Logger(),
            keyHex: m['keyHex'],
            eventHandler: {
              'fil_sendTransaction': genCallback('filecoin'),
              'eth_sendTransaction': genCallback('eth'),
              'wc_sessionUpdate': sessionUpdateCallback,
            });
        wc.isConnected = wc.isActive = true;
        wc.theirPeerId = m['theirPeerId'];
        var meta = m['theirMeta'];
        if (meta is Map) {
          this.meta = WCMeta.fromJson(meta);
        }
        print(m['theirMeta']);
        wc.connect().then((value) {
          setState(() {
            connectedSession = wc;
          });
        });
      } catch (e) {}
    }
  }

  void showChangeNameDialog() {
    Future.delayed(Duration.zero).then((value) {
      controller.text = $store.wal.label;
      showCustomDialog(
          context,
          Container(
            child: Column(
              children: [
                CommonTitle(
                  'makeName'.tr,
                  showDelete: true,
                ),
                Container(
                  child: Column(
                    children: [
                      Container(
                        child: Field(
                          autofocus: true,
                          controller: controller,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(
                        height: 1,
                      ),
                      GestureDetector(
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.center,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: CommonText(
                            'sure'.tr,
                            color: CustomColor.primary,
                          ),
                        ),
                        onTap: () {
                          var v = controller.text;
                          v = v.trim();
                          if (v == "") {
                            showCustomError('enterName'.tr);
                            return;
                          }
                          if (v.length > 20) {
                            showCustomError('nameTooLong'.tr);
                            return;
                          }
                          var wallet = $store.wal;
                          var list = box.values.where(
                              (wal) => wal.groupHash == wallet.groupHash);
                          list.forEach((wal) {
                            wal.label = v;
                            box.put(wal.key, wal);
                          });
                          $store.changeWalletName(v);
                          Get.back();
                          showCustomToast('createSucc'.tr);
                        },
                        behavior: HitTestBehavior.opaque,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.only(top: 20),
                )
              ],
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color(0xfff8f8f8),
            ),
          ));
    });
  }

  void handleScan() async {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.Connect})
        .then((value) async {
      if (value != null && isValidChainAddress(value, $store.net)) {
        Get.toNamed(filTransferPage, arguments: {'to': value});
      } else if (getValidWCLink(value) != '') {
        connectWallet(value);
      }
    });
  }

  void connectWallet(String uri, {bool newConnect = true}) {
    if (newConnect) {
      showCustomLoading('connecting'.tr);
      Future.delayed(Duration(seconds: 20)).then((value) {
        dismissAllToast();
      });
    }
    WCSession.connectSession(uri, jsonRpcHandler: {
      'wc_sessionRequest': [
        (WCSession session, JsonRpc rpc) {
          dismissAllToast();
          handleConnect(session, rpc, uri);
          return rpc;
        }
      ],
      'wc_sessionUpdate': sessionUpdateCallback,
      'fil_sendTransaction': genCallback('filecoin'),
      'eth_sendTransaction': genCallback('eth'),
    });
  }

  void signMessage(
    TMessage message, {
    String ck,
    WCSession session,
    JsonRpc rpc,
  }) async {
    String sign = '';
    num signType;
    var cid = await Flotus.messageCid(msg: jsonEncode(message));
    if ($store.wal.addr[1] == '1') {
      signType = SignTypeSecp;
      sign = await Flotus.secpSign(ck: ck, msg: cid);
    } else {
      signType = SignTypeBls;
      sign = await Bls.cksign(num: "$ck $cid");
    }
    var sm = SignedMessage(message, Signature(signType, sign));
    session.sendResponse(rpc.id, 'fil_signMessage',
        result: sm.toLotusSignedMessage());
  }

  void pushMsg(
      {String private,
      ChainGas gas,
      int nonce,
      WCSession session,
      JsonRpc rpc,
      BigInt value,
      String to,
      String type,
      ChainWallet wallet}) async {
    var from = wallet.addr;
    var net = $store.net;
    var nonceKey = '$from\_${net.rpc}';
    var realNonce = max(nonce, nonceBoxInstance.get(from).value);
    var res = await provider.sendTransaction(
        to: to,
        amount: value.toString(),
        private: private,
        gas: gas,
        nonce: realNonce);
    if (res != '') {
      showCustomToast('sended'.tr);
      session.sendResponse(rpc.id, '$type\_sendTransaction', result: res);
      var cacheGas = ChainGas(
          gasPrice: $store.gas.gasPrice,
          gasLimit: $store.gas.gasLimit,
          gasPremium: $store.gas.gasPremium);
      OpenedBox.gasInsance
          .put('$from\_$realNonce\_${$store.net.rpc}', cacheGas);
      $store.setGas(ChainGas());
      OpenedBox.mesInstance.put(
          res,
          CacheMessage(
              pending: 1,
              from: from,
              to: to,
              value: value.toString(),
              owner: from,
              nonce: realNonce,
              hash: res,
              rpc: net.rpc,
              gas: cacheGas,
              fee: (BigInt.from(cacheGas.gasLimit) *
                          BigInt.tryParse(cacheGas.gasPrice) ??
                      0)
                  .toString(),
              blockTime:
                  (DateTime.now().millisecondsSinceEpoch / 1000).truncate()));
      var oldNonce = nonceBoxInstance.get(nonceKey);
      nonceBoxInstance.put(
          nonceKey, Nonce(value: realNonce + 1, time: oldNonce.time));
    } else {
      showCustomError('sendFail'.tr);
    }
  }

  void handleTransaction(
      {WCSession session, JsonRpc rpc, String to, BigInt value, String type}) {
    var controller = $store;
    var wallet = controller.wal;
    var address = wallet.addr;
    var now = DateTime.now().millisecondsSinceEpoch;
    Future.wait([provider.getGas(to: to), provider.getNonce()]).then((res) {
      var gas = res[0] as ChainGas;
      var nonce = res[1] as int;
      if (gas.gasPrice == '0') {
        showCustomError('errorSetGas'.tr);
        return;
      }
      if (nonce == -1) {
        showCustomError("errorGetNonce".tr);
        return;
      }
      if (!nonceBoxInstance.containsKey(address)) {
        nonceBoxInstance.put(address, Nonce(time: now, value: nonce));
      } else {
        Nonce nonceInfo = nonceBoxInstance.get(address);
        var interval = 5 * 60 * 1000;
        if (now - nonceInfo.time > interval) {
          nonceBoxInstance.put(address, Nonce(time: now, value: nonce));
        }
      }
      showCustomModalBottomSheet(
          shape: RoundedRectangleBorder(borderRadius: CustomRadius.top),
          context: context,
          builder: (BuildContext context) {
            return ConstrainedBox(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 30),
                child: ConfirmSheet(
                  from: address,
                  to: to,
                  gas: gas.maxFee,
                  value: getChainValue(value.toString()),
                  footer: Row(
                    children: [
                      Expanded(
                          child: FButton(
                        alignment: Alignment.center,
                        height: 40,
                        onPressed: () {
                          Get.back();
                          session.sendResponse(rpc.id, '$type\_sendTransaction',
                              error: {'message': 'Reject'});
                        },
                        strokeWidth: .5,
                        strokeColor: Color(0xffcccccc),
                        corner: FCorner.all(6),
                        text: 'reject'.tr,
                      )),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                          child: FButton(
                        text: 'approve'.tr,
                        alignment: Alignment.center,
                        onPressed: () {
                          Get.back();
                          showPassDialog(context, (String pass) async {
                            var wal = controller.wal;
                            var private = await wal.getPrivateKey(pass);
                            pushMsg(
                                private: private,
                                value: value,
                                gas: gas,
                                wallet: wallet,
                                rpc: rpc,
                                to: to,
                                type: type,
                                session: session,
                                nonce: nonce);
                            // onConfirm(ck);
                          });
                        },
                        height: 40,
                        style: TextStyle(color: Colors.white),
                        color: CustomColor.primary,
                        corner: FCorner.all(6),
                      )),
                    ],
                  ),
                ),
              ),
              constraints: BoxConstraints(maxHeight: 800),
            );
          });
    });
  }

  void handleConnect(WCSession session, JsonRpc rpc, String uri) {
    var rawMeta = session.theirMeta;
    var handle = (bool approved) {
      session
          .sendSessionRequestResponse(
              rpc,
              'FiveToken',
              {
                'description': '',
                'name': 'FiveToken',
                'url': 'https://fivetoken.io/',
                'icons': ['https://fivetoken.io/image/ft-logo.png']
              },
              [$store.wal.addr],
              approved,
              chainId: int.tryParse($store.net.chainId))
          .then((value) {
        if (approved) {
          var s = session.toString();
          setState(() {
            connectedSession = session;
            this.meta = WCMeta.fromJson(rawMeta);
          });
          Global.store.setString('wcSession', s);
        }
      });
    };
    if (rawMeta != null) {
      var meta = WCMeta.fromJson(rawMeta);
      showCustomModalBottomSheet(
          shape: RoundedRectangleBorder(borderRadius: CustomRadius.top),
          context: context,
          builder: (BuildContext context) {
            return ConnectWallet(
              meta: meta,
              onCancel: () {
                handle(false);
              },
              onConnect: () {
                handle(true);
              },
            );
          });
    }
  }

  Future onRefresh() async {
    Global.eventBus.fire(RefreshEvent());
    await getBalance();
  }

  ChainProvider initProvider() {
    if ($store.net.addressType == 'eth') {
      return EthProvider($store.net);
    } else {
      return FilecoinProvider($store.net);
    }
  }

  Future getBalance() async {
    var wal = $store.wal;
    provider = initProvider();
    var res = await provider.getBalance(wal.addr);
    if (res != wal.balance && res != '0') {
      $store.changeWalletBalance(res);
      wal.balance = res;
      OpenedBox.walletInstance.put(wal.key, wal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: Visibility(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: CustomColor.primary),
              child: IconButton(
                  icon: Image(
                    image: AssetImage('icons/wc.png'),
                  ),
                  onPressed: () {
                    showCustomModalBottomSheet(
                        shape: RoundedRectangleBorder(
                            borderRadius: CustomRadius.top),
                        context: context,
                        builder: (BuildContext context) {
                          return ConnectWallet(
                            meta: meta,
                            footer: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              margin: EdgeInsets.only(bottom: 40),
                              child: FButton(
                                text: 'disConnect'.tr,
                                alignment: Alignment.center,
                                onPressed: () {
                                  Get.back();
                                  this.connectedSession.destroy();
                                  Global.store.remove('wcSession');
                                  setState(() {
                                    this.connectedSession = null;
                                  });
                                },
                                height: 40,
                                style: TextStyle(color: Colors.white),
                                color: CustomColor.primary,
                                corner: FCorner.all(6),
                              ),
                            ),
                          );
                        });
                  }),
            ),
            visible: connectedSession != null,
          ),
          appBar: PreferredSize(
              child: AppBar(
                actions: [
                  Padding(
                    child: GestureDetector(
                        onTap: handleScan,
                        child: Image(
                          width: 20,
                          image: AssetImage('icons/scan.png'),
                        )),
                    padding: EdgeInsets.only(right: 10),
                  )
                ],
                backgroundColor: Colors.white,
                elevation: .5,
                leading: Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      icon: IconList,
                      alignment: NavLeadingAlign,
                    );
                  },
                ),
                title: NetSelect(),
                centerTitle: true,
              ),
              preferredSize: Size.fromHeight(NavHeight)),
          drawer: Drawer(
            child: DrawerBody(),
          ),
          backgroundColor: Colors.white,
          body: CustomRefreshWidget(
            onRefresh: onRefresh,
            enablePullUp: false,
            child: Column(
              children: [
                SizedBox(
                  height: 25,
                ),
                CoinPriceWidget(),
                SizedBox(
                  height: 8,
                ),
                Obx(
                  () => CommonText(
                    $store.wal.label,
                    size: 14,
                    color: Color(0xffB4B5B7),
                  ),
                ),
                SizedBox(
                  height: 18,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 25,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      child: Obx(() => CommonText(
                            dotString(str: $store.wal.addr),
                            size: 14,
                            color: Color(0xffB4B5B7),
                          )),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color(0xfff8f8f8)),
                    ),
                    SizedBox(
                      width: 14,
                    ),
                    GestureDetector(
                      onTap: () {
                        copyText($store.wal.addr);
                        showCustomToast('copyAddr'.tr);
                      },
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: CustomColor.primary,
                            borderRadius: BorderRadius.circular(5)),
                        child: Image(
                            fit: BoxFit.fitWidth,
                            width: 17,
                            height: 17,
                            image: AssetImage('icons/copy-w.png')),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 18,
                ),
                WalletService(mainPage),
                SizedBox(
                  height: 40,
                ),
                MainTokenWidget(),
                Expanded(
                    child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [TokenList()],
                  ),
                )),
              ],
            ),
          ),
        ),
        onWillPop: () async {
          AndroidBackTop.backDeskTop();
          return false;
        });
  }
}

String getMarketPrice(String balance, double rate) {
  try {
    var b = double.parse(balance) / pow(10, 18);
    //var code=Global.langCode;
    var code = 'en';
    var unit = code == 'en' ? '\$' : '¥';
    return rate == 0
        ? ''
        : ' $unit ${formatDouble((rate * b).toStringAsFixed(2))}';
  } catch (e) {
    return '';
  }
}
