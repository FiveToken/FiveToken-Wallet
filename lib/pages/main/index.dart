import 'dart:async';
import 'package:fil/bloc/home/home_bloc.dart';
import 'package:fil/bloc/main/main_bloc.dart';
import 'package:fil/bloc/wallet/wallet_bloc.dart';
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

class MainPageState extends State<MainPage>  {
  final TextEditingController controller = TextEditingController();
  var box;
  Timer timer;
  WCSession connectedSession;
  WCMeta meta;
  Box<Nonce> nonceBoxInstance;

  @override
  void initState() {
    super.initState();
    box = OpenedBox.walletInstance;
    nonceBoxInstance = OpenedBox.nonceInsance;
    if (Get.arguments != null && Get.arguments['url'] != null) {
      var url = Get.arguments['url'] as String;
      // nextTick(() {
      //   connectWallet(url);
      // });
    }
    // reConnect();
  }

  @override
  void dispose() {
    super.dispose();
  }


  List<JsonRpc Function(WCSession, JsonRpc)> get sessionUpdateCallback {
    return [
      (WCSession session, JsonRpc rpc) {
        if (!session.isConnected) {
          Global.store.remove('wcSession');
          BlocProvider.of<HomeBloc>(context).add(SetMetaEvent(meta:null));
          BlocProvider.of<HomeBloc>(context).add(SetConnectedSessionEvent(connectedSession: null));
        }
        return rpc;
      }
    ];
  }

  void handleScan() async {
    Get.toNamed(scanPage, arguments: {'scene': ScanScene.Connect})
        .then((value) async {
          bool valid = await isValidChainAddress(value, $store.net);
      if (value != null && valid) {
        Get.toNamed(filTransferPage, arguments: {'to': value});
      }
      // else if (getValidWCLink(value) != '') {
      //   connectWallet(value);
      // }
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
          BlocProvider(create: (context)=> WalletBloc()),
          BlocProvider(create: (context)=>HomeBloc())
        ],
        child:BlocBuilder<WalletBloc,WalletState>(
            builder:(context,state){
              return BlocProvider(
                create: (ctx)=> HomeBloc(),
                child: BlocBuilder<HomeBloc,HomeState>(
                  builder: (context,state){
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
                                                  state.connectedSession.destroy();
                                                  Global.store.remove('wcSession');
                                                  BlocProvider.of<HomeBloc>(context).add(SetConnectedSessionEvent(connectedSession: null));
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
                ),
              );
            }
        )
    );
  }
}
