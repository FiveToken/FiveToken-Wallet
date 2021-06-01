import 'package:fil/common/index.dart';
import 'package:fil/index.dart';
import 'package:fil/pages/main/drawer.dart';
import 'package:fil/pages/transfer/transfer.dart';
import 'package:logger/logger.dart';
import 'package:oktoast/oktoast.dart';
import './walletConnect.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainPageState();
  }
}

class MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final TextEditingController controller = TextEditingController();
  String balance = singleStoreController.wal.balance;
  var box = Hive.box<Wallet>(addressBox);
  Timer timer;
  FilPrice price = FilPrice();
  WCSession connectedSession;
  WCMeta meta;
  Box<Nonce> nonceBoxInstance = OpenedBox.nonceInsance;
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
    updateBalance();
    var isCreate = false;
    if (Get.arguments != null && Get.arguments['create'] != null) {
      isCreate = Get.arguments['create'] as bool;
    }
    WidgetsBinding.instance.addObserver(this);
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
              showCustomError('wrong params');
            }
          } catch (e) {
            showCustomError(e.toString());
          }
        } else {
          showCustomError('wrong params');
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
            eventHandler: {'fil_sendTransaction': transcationCallback});
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
      controller.text = singleStoreController.wal.label;
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
                          var wallet = singleStoreController.wal;
                          wallet.label = v;
                          box.put(wallet.address, wallet);
                          singleStoreController.changeWalletName(v);
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

  void updateBalance() async {
    var wal = singleStoreController.wal;
    var res = await getBalance(wal);
    wal.balance = res.balance;
    timer = null;
    singleStoreController.changeWalletBalance(res.balance);
    OpenedBox.addressInsance.put(wal.address, wal);
    if (mounted) {
      setState(() {
        this.balance = res.balance;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) {
    super.didChangeAppLifecycleState(appLifecycleState);
    if (appLifecycleState == AppLifecycleState.resumed) {
      if (timer == null) {
        timer = Timer(Duration(milliseconds: 100), () async {
          updateBalance();
        });
      } else {
        timer.cancel();
      }
    }
  }

  void handleScan() async {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.Connect})
        .then((link) async {
      if (getValidWCLink(link) != '') {
        connectWallet(link);
      }
    });
  }

  void connectWallet(String uri, {bool newConnect = true}) {
    if (newConnect) {
      showCustomLoading('connecting');
    }
    WCSession.connectSession(uri, jsonRpcHandler: {
      'wc_sessionRequest': [
        (WCSession session, JsonRpc rpc) {
          dismissAllToast();
          handleConnect(session, rpc, uri);
          return rpc;
        }
      ],
      'wc_sessionUpdate': [
        (WCSession session, JsonRpc rpc) {
          print(session.isConnected);
          return rpc;
        }
      ],
      'fil_sendTransaction': [
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
                showCustomError('wrong params');
              }
            } catch (e) {
              showCustomError(e.toString());
            }
          } else {
            showCustomError('wrong params');
          }
          return rpc;
        }
      ]
    });
  }

  void pushMsg(
      {String ck,
      Gas gas,
      int nonce,
      WCSession session,
      JsonRpc rpc,
      String value,
      String to,
      Wallet wallet}) async {
    var from = wallet.addrWithNet;
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
      var cacheGas = CacheGas(
          cid: res,
          feeCap: gas.feeCap,
          gasLimit: gas.gasLimit,
          premium: gas.premium);
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
    var controller = singleStoreController;
    var wallet = controller.wal;
    var address = wallet.addrWithNet;
    var now = DateTime.now().millisecondsSinceEpoch;
    Future.wait([getGasDetail(to: to), getNonce(wallet)]).then((res) {
      var gas = res[0] as Gas;
      var nonce = res[1] as int;
      if (gas.feeCap == '0') {
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
                        text: 'Approve',
                        alignment: Alignment.center,
                        onPressed: () {
                          Get.back();
                          showPassDialog(context, (String pass) async {
                            var wal = controller.wal;
                            var ck = await getPrivateKey(
                                wal.addrWithNet, pass, wal.skKek);
                            pushMsg(
                                ck: ck,
                                value: value,
                                gas: gas,
                                wallet: wallet,
                                rpc: rpc,
                                to: to,
                                session: session,
                                nonce: nonce);
                            //onConfirm(ck);
                          });
                        },
                        height: 40,
                        style: TextStyle(color: Colors.white),
                        color: CustomColor.primary,
                        corner: FCorner.all(6),
                      )),
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                          child: FButton(
                        alignment: Alignment.center,
                        height: 40,
                        onPressed: () {
                          Get.back();
                          session.sendResponse(rpc.id, 'fil_transfer',
                              error: {'message': 'Reject'});
                        },
                        style: TextStyle(color: Colors.white),
                        corner: FCorner.all(6),
                        color: Colors.red,
                        text: 'Reject',
                      ))
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
          .sendSessionRequestResponse(rpc, 'Filecoin Wallet', rawMeta,
              ['0xCe855cd625A5C04F93998c80e4388C8c11832Ad7'], approved,
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
                              margin: EdgeInsets.only(bottom: 20),
                              child: FButton(
                                text: 'DisConnect',
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
                        // onTap: () {
                        //   Get.toNamed(scanPage,
                        //           arguments: {'scene': ScanScene.Address})
                        //       .then((value) {
                        //     if (value != null && isValidAddress(value)) {
                        //       Get.toNamed(filTransferPage,
                        //           arguments: {'to': value});
                        //     }
                        //   });
                        // },
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
                title: CommonText(
                  'wallet'.tr,
                  size: 18,
                  weight: FontWeight.w500,
                ),
                centerTitle: true,
              ),
              preferredSize: Size.fromHeight(NavHeight)),
          drawer: Drawer(
            child: DrawerBody(),
          ),
          backgroundColor: Colors.white,
          body: Column(
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
                  singleStoreController.wal.label,
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
                          dotString(str: singleStoreController.wal.addr),
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
                      copyText(singleStoreController.wal.addr);
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
              GestureDetector(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            color: CustomColor.primary,
                            borderRadius: BorderRadius.circular(20)),
                        child: Image(
                          image: AssetImage('icons/fil-w.png'),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                'Filecoin',
                                size: 15,
                                weight: FontWeight.w500,
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              CommonText(
                                marketPrice,
                                color: CustomColor.grey,
                                size: 12,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          CommonText(
                            formatDouble(balance, truncate: true, size: 4) +
                                ' FIL',
                            color: CustomColor.primary,
                          )
                        ],
                      ))
                    ],
                  ),
                ),
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Get.toNamed(walletMainPage,
                      arguments: {'marketPrice': marketPrice}).then((value) {
                    setState(() {
                      balance = singleStoreController.wal.balance;
                    });
                  });
                },
              )
            ],
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
    var b = double.parse(balance);
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
