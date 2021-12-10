import 'dart:async';
import 'dart:convert';
import 'package:fil/bloc/connect/connect_bloc.dart';
import 'package:fil/bloc/home/home_bloc.dart';
import 'package:fil/bloc/main/main_bloc.dart';
import 'package:fil/bloc/price/price_bloc.dart';
import 'package:fil/common/back.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_root_jailbreak/flutter_root_jailbreak.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fbutton/fbutton.dart';
import 'package:fil/pages/home/drawer.dart';
import 'package:fil/pages/home/widgets/net.dart';
import 'package:fil/pages/home/widgets/price.dart';
import 'package:fil/pages/home/widgets/token.dart';
import 'package:oktoast/oktoast.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:wallet_connect/models/ethereum/wc_ethereum_transaction.dart';
import 'package:wallet_connect/models/session/wc_session.dart';
import 'package:wallet_connect/models/wc_peer_meta.dart';
import 'package:wallet_connect/wc_client.dart';
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
  WCClient _wcClient;
  Box<Nonce> nonceBoxInstance;
  final fiveTokenMeta = WCPeerMeta(
    name: "FiveToken",
    url: "https://fivetoken.io/",
    description: "",
    icons: ['https://fivetoken.io/image/ft-logo.png'],
  );

  Widget title(label) {
    return Text(label, style: TextStyle(color: Colors.white));
  }

  final StreamController<bool> _verificationNotifier0 =
      StreamController<bool>.broadcast();

  bool closeFlag = false;

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _verificationNotifier0.close();
    _verificationNotifier0.stream.listen((event) {
      setState(() {
        this.closeFlag = true;
      });
    });
    super.dispose();
  }

  void passwordEnteredCallback(String pass, String enterPassCode) {
    final bool isValid = enterPassCode == pass;
    _verificationNotifier0.add(isValid);
    if (isValid) {
      setState(() {
        this.closeFlag = true;
      });
    }
  }

  bool _openState = false;

  void openLockScreen(pass) async {
    if (_openState == true && Global.lockscreen) return;
    _openState = true;
    await Navigator.push(context,
        PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) {
      return WillPopScope(
        onWillPop: () async {
          return closeFlag;
        },
        child: PasscodeScreen(
          isValidCallback: () {},
          title: title('enterPass'.tr),
          passwordEnteredCallback: (value) =>
              {passwordEnteredCallback(pass, value)},
          cancelButton: title('cancel'.tr),
          deleteButton: title('delete'.tr),
          shouldTriggerVerification: _verificationNotifier0.stream,
        ),
      );
    }));
    _openState = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    var lockBox = OpenedBox.lockInstance;
    var lock = lockBox.get('lock');
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.resumed:
        print('resumed');
        if (lock != null && lock.lockscreen == true) {
          openLockScreen(lock.password);
        }
        break;
      case AppLifecycleState.paused:
        print('paused');
        break;
      case AppLifecycleState.detached:
        print('detached');
        break;
    }
  }

  @override
  void initState() {
    _initWcClient();
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    box = OpenedBox.walletInstance;
    nonceBoxInstance = OpenedBox.nonceInsance;
    if (mounted) {
      if (Global.lockscreen&&Global.lockFromInit) {
        var lockBox = OpenedBox.lockInstance;
        var lock = lockBox.get('lock');
        Future.delayed(Duration.zero)
            .then((value) => openLockScreen(lock.password));
      }
    }
  }

  _initWcClient() async {
    _wcClient = WCClient(
      onSessionRequest: _onSessionRequest,
      onFailure: _onSessionError,
      onDisconnect: _onSessionClosed,
      onConnect: _onConnect,
      // onEthSendTransaction: _onSendTransaction,
      // onCustomRequest: (_, __) {},
    );
  }

  Future onRefresh(BuildContext context) async {
    bool isRoot = await isRooted();
    if (isRoot) {
      rootDialog();
    }
    Global.eventBus.fire(RefreshEvent());
    BlocProvider.of<MainBloc>(context).add(GetBalanceEvent(
      $store.net.rpc,
      $store.net.chain,
      $store.wal.addr,
    ));
    try {
      var wcSession = Global.store.getString('wcSession');
      if(wcSession != null && wcSession != ""){
        WCPeerMeta _session = WCPeerMeta.fromJson(jsonDecode(wcSession));
        BlocProvider.of<ConnectBloc>(context)
          ..add(SetConnectedSessionEvent(connectedSession: _session ));
      }
      BlocProvider.of<PriceBloc>(context)..add(ResetUsdPriceEvent())..add(GetPriceEvent($store.net.chain));
      BlocProvider.of<HomeBloc>(context).add(
          GetTokenListEvent($store.net.rpc, $store.net.chain, $store.wal.addr));
    } catch (e) {
      debugPrint('================');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => HomeBloc())],
      child: BlocBuilder<ConnectBloc, ConnectState>(
        builder: (context, connectState) {
          return BlocBuilder<HomeBloc, HomeState>(
            builder: (context, homeState) {
              return BlocBuilder<PriceBloc,PriceState>(
                  builder: (context,priceState){
                    return WillPopScope(
                        child: Scaffold(
                          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
                          floatingActionButton:Visibility(
                            child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: CustomColor.primary),
                                child:IconButton(
                                    icon: Image(
                                      image: AssetImage('icons/wc.png'),
                                    ),
                                    onPressed:(){
                                      _walletDisconnect(context,connectState);
                                    }
                                ),
                            ),
                            visible: connectState.connectedSession != null,
                          ),
                          appBar: PreferredSize(
                              child: AppBar(
                                actions: [
                                  Padding(
                                    child: GestureDetector(
                                        onTap: _handleScan,
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
                            onRefresh: () => onRefresh(context),
                            enablePullUp: false,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 25,
                                ),
                                GestureDetector(
                                  onTap: () {
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
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 5),
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
                                      onTap: () {
                                        var net = $store.net;
                                        var wal = $store.wal;
                                        Get.toNamed(walletMangePage,
                                            arguments: {'net': net, 'wallet': wal});
                                      },
                                      child: Container(
                                        width: 24,
                                        height: 24,
                                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                        padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                        // alignment:Alignment.center,
                                        decoration: BoxDecoration(
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
                                          ],
                                        ),
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
                                    ))
                              ],
                            ),
                          ),
                        ),
                        onWillPop: () async {
                          AndroidBackTop.backDeskTop();
                          return false;
                        }
                    );
                  }
              );
            },
          );
        }
      ),
    );
  }

  void _handleScan() async {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.Connect})
        .then((value) async {
      bool valid = await isValidChainAddress(value, $store.net);
      if (value != null && valid) {
        Get.toNamed(filTransferPage, arguments: {'to': value});
      } else if (getValidWCLink(value) != '') {
        _handleScanCallback(value);
      }
    });
  }

  void _handleScanCallback(value) {
    showCustomLoading('connecting'.tr);
    final session = WCSession.from(value);
    debugPrint('session $session');
    _wcClient.connectNewSession(session: session, peerMeta: fiveTokenMeta);
  }

  void _onConnect(){}

  void _onSessionClosed(int code, String reason){}

  void _onSessionRequest(int id, WCPeerMeta peerMeta){
    dismissAllToast();
    showCustomModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: CustomRadius.top),
        context: context,
        builder: (BuildContext context){
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 800),
            child: SingleChildScrollView(
                child: Column(
                    children:[
                      Container(
                        width: 100,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Image.network(
                          peerMeta.url,
                          errorBuilder: (BuildContext context, Object object, StackTrace stackTrace) {
                            return Image(
                              image: AssetImage('icons/wc-blue.png'),
                            );
                          },
                        ),
                      ),
                      CommonText.center(peerMeta.name, size: 16, color: Colors.black),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CommonText(peerMeta.description),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Row(
                              children:[
                                Expanded(
                                    child: FButton(
                                      alignment: Alignment.center,
                                      height: 40,
                                      onPressed: () {
                                        Get.back();
                                      },
                                      strokeWidth: .5,
                                      strokeColor: Color(0xffcccccc),
                                      corner: FCorner.all(6),
                                      text: 'cancel'.tr,
                                    )),
                                SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                    child: FButton(
                                      text: 'connect'.tr,
                                      alignment: Alignment.center,
                                      onPressed: () {
                                        try{
                                          _wcClient.approveSession(
                                            accounts: [$store.wal.address],
                                            chainId: int.tryParse($store.net.chainId),
                                          );
                                          var connectSession = jsonEncode(peerMeta);
                                          BlocProvider.of<ConnectBloc>(context)
                                            ..add(SetConnectedSessionEvent(connectedSession: peerMeta ))
                                            ..add(SetMetaEvent(meta: fiveTokenMeta ));
                                          Global.store.setString('wcSession', connectSession);
                                          Get.back();
                                        }catch(error){
                                          print('error');
                                        }
                                      },
                                      height: 40,
                                      style: TextStyle(color: Colors.white),
                                      color: CustomColor.primary,
                                      corner: FCorner.all(6),
                                    )),
                              ]
                          )
                      )
                    ]
                )
            )
          );
        }
    );
  }

  void _onSessionError(dynamic message){}

  void _walletDisconnect(context,state){
    showCustomModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: CustomRadius.top),
        context: context,
        builder: (BuildContext context){
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 800),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Image.network(
                      state.connectedSession.url,
                      errorBuilder: (BuildContext context, Object object, StackTrace stackTrace) {
                        return Image(
                          image: AssetImage('icons/wc-blue.png'),
                        );
                      },
                    ),
                  ),
                  CommonText.center(state.connectedSession.name, size: 16, color: Colors.black),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CommonText(state.connectedSession.description),
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      margin: EdgeInsets.only(bottom: 40),
                      child: FButton(
                        text: 'disConnect'.tr,
                        alignment: Alignment.center,
                        onPressed: () {
                          try {
                            Get.back();
                            Global.store.remove('wcSession');
                            BlocProvider.of<ConnectBloc>(context).add(
                                ResetConnectEvent(connectedSession: null, meta: null));
                            _wcClient.killSession();
                          } catch (error) {
                            print('error');
                          }
                        },
                        height: 40,
                        style: TextStyle(color: Colors.white),
                        color: CustomColor.primary,
                        corner: FCorner.all(6),
                      )
                  )
                ],
              ),
            ),
          );
        }
    );

  }

  void rootDialog() {
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
      bool result = Global.platform == 'android'
          ? await FlutterRootJailbreak.isRooted
          : await FlutterRootJailbreak.isJailBroken;
      return result;
    } catch (e) {
      return false;
    }
  }

}
