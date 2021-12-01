import 'dart:async';
import 'package:fil/bloc/connect/connect_bloc.dart';
import 'package:fil/bloc/home/home_bloc.dart';
import 'package:fil/bloc/main/main_bloc.dart';
import 'package:fil/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_root_jailbreak/flutter_root_jailbreak.dart';
import 'package:get/get.dart';
import 'package:fil/common/index.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fbutton/fbutton.dart';
import 'package:fil/pages/main/drawer.dart';
import 'package:fil/pages/main/widgets/net.dart';
import 'package:fil/pages/main/widgets/price.dart';
import 'package:fil/pages/main/widgets/token.dart';
import 'package:logger/logger.dart';
import 'package:oktoast/oktoast.dart';
import 'package:web3dart/crypto.dart';
import './walletConnect.dart';
import 'package:fil/store/store.dart';
import 'package:fil/widgets/toast.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/bottomSheet.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/fresh.dart';
import 'package:fil/actions/event.dart';
import 'package:fil/models/index.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/pages/wallet/main.dart';
import 'package:fil/pages/other/scan.dart';
import 'package:fil/widgets/index.dart';


typedef WCCallback = List<JsonRpc Function(WCSession, JsonRpc)> Function(
    String type);

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainPageState();
  }
}

class MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final TextEditingController controller = TextEditingController();
  var box;
  Timer timer;
  // wcc
  // WCSession connectedSession;
  // WCMeta meta;
  Box<Nonce> nonceBoxInstance;


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    print(state);
    switch(state){
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        print(AppLifecycleState.resumed);
        break;
      case AppLifecycleState.paused:
        break;
      case  AppLifecycleState.detached:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    box = OpenedBox.walletInstance;
    nonceBoxInstance = OpenedBox.nonceInsance;
    if (Get.arguments != null && Get.arguments['url'] != null) {
      var url = Get.arguments['url'] as String;
      nextTick(() {
        connectWallet(url);
      });
    }
    reConnect();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  List<JsonRpc Function(WCSession, JsonRpc)> get sessionUpdateCallback {
    return [
      (WCSession session, JsonRpc rpc) {
        if (!session.isConnected) {
          Global.store.remove('wcSession');
          BlocProvider.of<ConnectBloc>(context).add(SetMetaEvent(meta:null));
          BlocProvider.of<ConnectBloc>(context).add(SetConnectedSessionEvent(connectedSession: null));
        }
        return rpc;
      }
    ];
  }

  Future onRefresh(context) async {
    bool isRoot = await isRooted();
    if(isRoot){
      rootDialog();
    }
    Global.eventBus.fire(RefreshEvent());
    BlocProvider.of<MainBloc>(context).add(GetBalanceEvent(
      $store.net.rpc,
      $store.net.chain,
      $store.wal.addr,
    ));
    try {
      BlocProvider.of<HomeBloc>(context).add(GetTokenListEvent(
          $store.net.rpc,
          $store.net.chain,
          $store.wal.addr
      ));
    }catch (e){
      debugPrint('================');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers:[
          BlocProvider(create: (context)=>HomeBloc())
        ],
      child: BlocBuilder<ConnectBloc,ConnectState>(
          builder:(context,connectState){
            return BlocBuilder<HomeBloc,HomeState>(
              builder: (context,homeState){
                return WillPopScope(
                    child: Scaffold(
                      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
                      floatingActionButton:_walletConnectBody(connectState,context),
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
                        onRefresh: ()=>onRefresh(context),
                        enablePullUp: false,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 25,
                            ),
                            GestureDetector(
                              onTap: (){
                                Get.toNamed(walletSelectPage);
                              },
                              child: Column(
                                children: [
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
                                ],
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
                                ),
                                GestureDetector(
                                  onTap: (){
                                    var net = $store.net;
                                    var wal =$store.wal;
                                    Get.toNamed(walletMangePage,arguments: {'net': net, 'wallet': wal});
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                    // alignment:Alignment.center,
                                    decoration:BoxDecoration(
                                        color: CustomColor.primary,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        CommonText(
                                          '...',
                                          size: 14,
                                          color: Colors.white,
                                        )
                                      ],),
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
                                )
                            )
                          ],
                        ),
                      ),
                    ),
                    onWillPop: () async {
                      AndroidBackTop.backDeskTop();
                      return false;
                    });
              },
            );
          }
      ),
    );
  }

  Widget _walletConnectBody(state,context){
    return  Visibility(
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
                      meta: state.meta,
                      footer: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        margin: EdgeInsets.only(bottom: 40),
                        child: FButton(
                          text: 'disConnect'.tr,
                          alignment: Alignment.center,
                          onPressed: () {
                            try{
                              Get.back();
                              Global.store.remove('wcSession');
                              BlocProvider.of<ConnectBloc>(context).add(ResetConnectEvent(connectedSession: null,meta: null));
                            }catch(error){
                              print('error');
                            }
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
      visible: state.connectedSession != null,
    );
  }


  void handleScan() async {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.Connect})
        .then((value) async {
      bool valid = await isValidChainAddress(value, $store.net);
      if (value != null && valid) {
        Get.toNamed(filTransferPage, arguments: {'to': value});
      } else if (getValidWCLink(value) != '') {
        connectWallet(value);
      }
    });
  }

  void rootDialog(){
    showCustomDialog(
        context,
        Column(
          children: [
            CommonTitle(
              'rootTitle'.tr,
              showDelete: true,
            ),
            Container(
              child: Text(
                'rootTips'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              padding: EdgeInsets.symmetric(horizontal: 57, vertical: 28),
            ),
            Divider(
              height: 1,
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: CommonText(
                  'know'.tr,
                  color: CustomColor.primary,
                ),
                padding: EdgeInsets.symmetric(vertical: 8),
              ),
              onTap: () {
                Get.back();
              },
            ),
          ],
        ));
  }

  Future<bool> isRooted() async {
    try {
      bool result = Global.platform == 'android' ? await FlutterRootJailbreak.isRooted : await FlutterRootJailbreak.isJailBroken;
      return result;
    }catch (e){
      return false;
    }
  }

  void connectWallet(String uri, {bool newConnect = true}) {
    if (newConnect) {
      showCustomLoading('connecting'.tr);
      // Future.delayed(Duration(seconds: 20)).then((value) {
      //   dismissAllToast();
      // });
    }
    WCSession.connectSession(uri, jsonRpcHandler: {
      'wc_sessionRequest': [
          (WCSession session, JsonRpc rpc) {
              try{
                dismissAllToast();
                handleConnect(session, rpc, uri);
                return rpc;
              }catch(error){
                print('error');
                return rpc;
              }
          }
      ],
      'wc_sessionUpdate': sessionUpdateCallback,
      'fil_sendTransaction': genCallback('filecoin'),
      'eth_sendTransaction': genCallback('eth'),
    });
  }

  void handleConnect(WCSession session, JsonRpc rpc, String uri) {
    try{
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
            try{
              var connectSession = session.toString();
              BlocProvider.of<ConnectBloc>(context)
                ..add(SetMetaEvent(meta:WCMeta.fromJson(rawMeta)))
                ..add(SetConnectedSessionEvent(connectedSession: session));
              Global.store.setString('wcSession', connectSession);
            }catch(error){
              print('error');
            }
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
            }
        );
      }
    }catch(error){
      print('12312');
    }

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
          var from = p['from'] as String;
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
                from:from,
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


  void reConnect() {
    var wcSession = Global.store.getString('wcSession');
    if (wcSession != null && wcSession != "") {
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
          BlocProvider.of<ConnectBloc>(context).add(SetMetaEvent(meta:WCMeta.fromJson(meta)));
        }
        wc.connect().then((value) {
          BlocProvider.of<ConnectBloc>(context).add(SetConnectedSessionEvent(connectedSession: wc));
        });
      } catch (error) {
        print('error');
      }
    }
  }


  void handleTransaction({WCSession session, JsonRpc rpc,String from, String to, BigInt value, String type}) {
    showCustomModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: CustomRadius.top),
        context: context,
        builder: (BuildContext context){
          return SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 30),
              child:_confirmBody()
          );
        }
    );
  }

  Widget  _confirmBody(){
    final EdgeInsets padding = EdgeInsets.symmetric(horizontal: 12, vertical: 14);
    return Column(
      children: [
        CommonTitle(
          'sendConfirm'.tr,
          showDelete: true,
        ),
        Container(
            padding: EdgeInsets.fromLTRB(12, 15, 12, 20),
            color: CustomColor.bgGrey,
            child: Column(
                children:[
                  Container(
                    padding: padding,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText.grey('from'.tr),
                            Container(
                              width: 50,
                            ),
                            Expanded(
                                child: Text(
                                  "from",
                                  textAlign: TextAlign.right,
                                )),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText.grey('to'.tr),
                            Container(
                              width: 50,
                            ),
                            Expanded(
                                child: Text(
                                  "to",
                                  textAlign: TextAlign.right,
                                )),
                          ],
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: CustomRadius.b8),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    padding: padding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonText.grey('amount'.tr),
                        CommonText(
                          'value symbol',
                          size: 18,
                          color: CustomColor.primary,
                          weight: FontWeight.w500,
                        )
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: CustomRadius.b8),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    padding: padding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonText.grey('fee'.tr),
                        CommonText.main('gas')
                      ],
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: CustomRadius.b8),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    width: double.infinity,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(const Radius.circular(8)),
                      color: CustomColor.primary,
                    ),
                    child: FlatButton(
                      child: Text(
                        'send'.tr,
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Get.back();
                        showPassDialog(context, (String pass) async {
                          var wal = $store.wal;
                          var ck = await wal.getPrivateKey(pass);
                          confirmPushMessage(ck);
                        });
                      },
                      //color: Colors.blue,
                    ),
                  )
                ]
            )
        )
      ],
    );
  }


  confirmPushMessage(pk){}

}
