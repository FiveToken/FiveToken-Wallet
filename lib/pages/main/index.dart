import 'package:fil/chain/wallet.dart';
import 'package:fil/common/index.dart';
import 'package:fil/index.dart';
import 'package:fil/pages/main/drawer.dart';
import 'package:fil/pages/main/widgets/net.dart';
import 'package:fil/pages/main/widgets/token.dart';
import 'package:fil/pages/transfer/transfer.dart';
import 'package:logger/logger.dart';
import 'package:oktoast/oktoast.dart';
import 'package:web3dart/web3dart.dart';
import './walletConnect.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainPageState();
  }
}

class MainPageState extends State<MainPage> {
  final TextEditingController controller = TextEditingController();
  String balance = $store.wal.balance;
  var box = OpenedBox.walletInstance;
  Timer timer;
  FilPrice price = FilPrice();
  WCSession connectedSession;
  WCMeta meta;
  Box<Nonce> nonceBoxInstance = OpenedBox.nonceInsance;
  final Web3Client client = Web3Client($store.net.rpc, Client());
  ChainProvider provider;
  Worker worker;
  void getPrice() async {
    var res = await getFilPrice();
    Global.price = res;
    if (res.cny != 0) {
      setState(() {
        price = res;
      });
    }
  }

  double get rate {
    var lang = Global.langCode;
    lang = 'en';
    return lang == 'en' ? price.usd : price.cny;
  }

  String get marketPrice {
    return getMarketPrice(balance, rate);
  }

  @override
  void initState() {
    super.initState();
    getPrice();
    var isCreate = false;
    if (Get.arguments != null && Get.arguments['create'] != null) {
      isCreate = Get.arguments['create'] as bool;
    }
    var show = Get.arguments != null && isCreate == true;
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

  List<JsonRpc Function(WCSession, JsonRpc)> get transcationCallback {
    return [
      (WCSession session, JsonRpc rpc) {
        var params = rpc.params;
        if (params != null && params is List && params.isNotEmpty) {
          try {
            var p = params[0] as Map<String, dynamic>;
            var to = p['to'] as String;
            var value = p['value'] as String;
            // ignore: unused_local_variable
            var valueNum = double.parse(value);
            if (to != null && value != null) {
              handleTransaction(
                  session: session, rpc: rpc, to: to, value: value);
            } else {
              showCustomError('errorParams'.tr);
            }
          } catch (e) {
            showCustomError(e.toString());
          }
        } else {
          showCustomError('errorParams'.tr);
        }
        return rpc;
      }
    ];
  }

  List<JsonRpc Function(WCSession, JsonRpc)> get signMessageCallback {
    return [
      (WCSession session, JsonRpc rpc) {
        var params = rpc.params;
        if (params != null && params is List && params.isNotEmpty) {
          try {
            var p = params[0] as Map<String, dynamic>;
            var msg = TMessage.fromJson(p);
            if (msg.valid) {
              var maxFee = getMaxFee(
                  ChainGas(gasPrice: msg.gasFeeCap, gasLimit: msg.gasLimit));
              showCustomModalBottomSheet(
                  shape: RoundedRectangleBorder(borderRadius: CustomRadius.top),
                  context: context,
                  builder: (BuildContext context) {
                    return ConfirmMessageSheet(
                      address: msg.from,
                      to: msg.to,
                      value: msg.value,
                      session: session,
                      rpc: rpc,
                      maxFee: maxFee,
                      onApprove: () {
                        showPassDialog(context, (String pass) async {
                          var wal = $store.wal;
                          var ck =
                              await getPrivateKey(wal.address, pass, wal.skKek);
                          signMessage(msg, ck: ck, session: session, rpc: rpc);
                        });
                      },
                      onReject: () {
                        session.sendResponse(rpc.id, 'fil_signMessage',
                            error: {'message': 'Reject'});
                      },
                    );
                  });
              //(context: null, builder: null);
            } else {
              showCustomError('errorParams'.tr);
            }
          } catch (e) {
            showCustomError(e.toString());
          }
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
              'fil_sendTransaction': transcationCallback,
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
                          wallet.label = v;
                          box.put(wallet.address, wallet);
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
      if (value != null && isValidAddress(value)) {
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
      'fil_sendTransaction': transcationCallback
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
    if ($store.wal.type == '1') {
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
      {String ck,
      Gas gas,
      int nonce,
      WCSession session,
      JsonRpc rpc,
      String value,
      String to,
      ChainWallet wallet}) async {
    var from = wallet.address;
    var realNonce = max(nonce, nonceBoxInstance.get(from).value);
    var msg = TMessage(
        version: 0,
        method: 0,
        nonce: realNonce,
        from: from,
        to: to,
        params: "",
        value: fil2Atto(value),
        gasFeeCap: gas.feeCap,
        gasLimit: gas.gasLimit,
        gasPremium: gas.premium);
    String sign = '';
    num signType;
    var cid = await Flotus.messageCid(msg: jsonEncode(msg));
    if (wallet.type == '1') {
      signType = SignTypeSecp;
      sign = await Flotus.secpSign(ck: ck, msg: cid);
    } else {
      signType = SignTypeBls;
      sign = await Bls.cksign(num: "$ck $cid");
    }
    var sm = SignedMessage(msg, Signature(signType, sign));
    showCustomLoading('sending'.tr);
    String res = await pushSignedMsg(sm.toLotusSignedMessage());
    dismissAllToast();
    if (res != '') {
      showCustomToast('sended'.tr);
      var cacheGas = ChainGas(
          gasPrice: gas.feeCap,
          gasLimit: gas.gasLimit,
          gasPremium: gas.premium);
      OpenedBox.gasInsance.put('$from\_$realNonce', cacheGas);
      OpenedBox.messageInsance.put(
          res,
          StoreMessage(
              pending: 1,
              from: from,
              to: to,
              value: fil2Atto(value),
              owner: from,
              nonce: realNonce,
              signedCid: res,
              blockTime:
                  (DateTime.now().millisecondsSinceEpoch / 1000).truncate()));
      var oldNonce = nonceBoxInstance.get(from);
      nonceBoxInstance.put(
          from, Nonce(value: realNonce + 1, time: oldNonce.time));
      session.sendResponse(rpc.id, 'fil_sendTransaction',
          result: {'signed_cid': res});
    } else {
      showCustomError('sendFail'.tr);
    }
  }

  void handleTransaction(
      {WCSession session, JsonRpc rpc, String to, String value}) {
    var controller = $store;
    var wallet = controller.wal;
    var address = wallet.address;
    var now = DateTime.now().millisecondsSinceEpoch;
    Future.wait([getGasDetail(to: to), getNonce(wallet)]).then((res) {
      var gas = res[0] as ChainGas;
      var nonce = res[1] as int;
      if (gas.gasPrice == '0') {
        showCustomError('errorSetGas'.tr);
        return;
      }
      if (nonce == null || nonce == -1) {
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
      var maxFee = getMaxFee(gas);
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
                  gas: maxFee,
                  value: value,
                  footer: Row(
                    children: [
                      Expanded(
                          child: FButton(
                        alignment: Alignment.center,
                        height: 40,
                        onPressed: () {
                          Get.back();
                          session.sendResponse(rpc.id, 'fil_sendTransaction',
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
                            var ck = await getPrivateKey(
                                wal.address, pass, wal.skKek);
                            // pushMsg(
                            //     ck: ck,
                            //     value: value,
                            //     gas: gas,
                            //     wallet: wallet,
                            //     rpc: rpc,
                            //     to: to,
                            //     session: session,
                            //     nonce: nonce);
                            //onConfirm(ck);
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
                'url': 'https://filecoinwallet.com/',
                'icons': ['https://filecoinwallet.com/logo.jpg']
              },
              [$store.wal.address],
              approved,
              chainId: 1)
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
            return ConectedWallet(
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
    if (res != wal.balance) {
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
                          return ConectedWallet(
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
                backgroundColor: Color(FColorWhite),
                elevation: NavElevation,
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
                CommonText(
                  marketPrice,
                  size: 30,
                  weight: FontWeight.w800,
                ),
                SizedBox(
                  height: 12,
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
                WalletService(),
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
