import 'dart:math';
import 'package:decimal/decimal.dart';
import 'package:dio_log/dio_log.dart';
import 'package:fil/bloc/main/main_bloc.dart';
import 'package:fil/bloc/wallet/wallet_bloc.dart';
import 'package:fil/utils/decimal_extension.dart';
import 'package:fil/utils/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:day/day.dart';
import 'package:fil/pages/wallet/widgets/messageItem.dart';
import 'package:fil/widgets/icons.dart';
import 'package:fil/widgets/random.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/fresh.dart';
import 'package:fil/models/index.dart';
import 'package:fil/store/store.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/common/global.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/app.dart';

class WalletMainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletMainPageState();
  }
}

class WalletMainPageState extends State<WalletMainPage> with RouteAware {
  Token token = Global.cacheToken;
  bool get showToken => token != null;
  Network net = $store.net;
  String symbol = '';
  bool get isFil {
    return this.net.addressType == AddressType.filecoin.type;
  }

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null) {
      if (Get.arguments['symbol'] != null) {
        symbol = Get.arguments['symbol'];
      }

    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
  }

  CoinIcon get coinIcon {
    var key = $store.net.coin;
    if (CoinIcon.icons.containsKey(key)) {
      return CoinIcon.icons[key];
    } else {
      return CoinIcon(
          bg: CustomColor.primary, border: false, icon: Container());
    }
  }

  String get title => showToken ? token.symbol : $store.net.coin;

  Future onRefresh(BuildContext context) async {
    try{
      if(showToken){
        BlocProvider.of<WalletBloc>(context).add(
            GetTokenBalanceEvent(
                $store.net.rpc,
                $store.net.chain,
                $store.wal.addr,
                token.address
            )
        );
      }else{
        BlocProvider.of<MainBloc>(context).add(GetBalanceEvent(
          $store.net.rpc,
          $store.net.chain,
          $store.wal.addr,
        ));
      }

      BlocProvider.of<WalletBloc>(context)
        ..add(
            ResetMessageListEvent()
        )
        ..add(
          SetEnablePullUpEvent(false)
        )
        ..add(
          GetMessageListEvent($store.net.rpc, $store.net.chain, $store.wal.addr,'down',symbol)
        );
    }catch(error){
      print('error');
    }

  }

  Future onLoading(BuildContext context) async {
    BlocProvider.of<WalletBloc>(context).add(GetFileCoinMessageListEvent(
        $store.net.rpc, $store.net.chain, $store.wal.addr,'up',symbol
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    showDebugBtn(context);

    BlocProvider.of<MainBloc>(context).add(GetBalanceEvent(
        $store.net.rpc,
        $store.net.chain,
        $store.wal.addr
      )
    );
    var today = Day();
    var formatStr = 'YYYY-MM-DD';
    var todayStr = today.format(formatStr);
    var yesterday = today.subtract(1, 'd') as Day;
    var yesterdayStr = yesterday.format(formatStr);
    return BlocProvider(
      create: (ctx) => WalletBloc(),
      child: BlocBuilder<WalletBloc, WalletState>(
        builder: (context, walletState) {
          return BlocBuilder<MainBloc, MainState>(
            builder: (context, state) {
              List messageKeys = walletState.formatMessageList.keys.toList();
              int count = messageKeys.length;
              return WillPopScope(
                onWillPop: () async {
                  Get.toNamed(mainPage);
                  return false;
                },
                child: CommonScaffold(
                  title: title,
                  backFn:(){
                    Navigator.popUntil(context, (route) =>route.settings.name == mainPage);
                  },
                  hasFooter: false,
                  body: CustomRefreshWidget(
                    enablePullUp: isFil && walletState.enablePullUp,
                    onLoading: ()=> onLoading(context),
                    onRefresh: ()=> onRefresh(context),
                    child: CustomScrollView(
                      slivers: [
                        SliverPersistentHeader(
                            pinned: true,
                            delegate: SliverDelegate(
                                child: Container(
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding:
                                        EdgeInsets.fromLTRB(0, 25, 0, 17),
                                        child: showToken
                                            ? RandomIcon(
                                          token.address,
                                          size: 70,
                                        )
                                            : Container(
                                          width: 70,
                                          height: 70,
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: coinIcon.border
                                                      ? .5
                                                      : 0,
                                                  color:
                                                  Colors.grey[400]),
                                              color: coinIcon.bg,
                                              borderRadius:
                                              BorderRadius.circular(
                                                  35)),
                                          child: coinIcon.icon,
                                        ),
                                        alignment: Alignment.center,
                                        width: double.infinity,
                                      ),
                                      !showToken
                                          ? CommonText(
                                        formatCoin(state.balance) + " " + $store.net.coin,
                                        size: 30,
                                        weight: FontWeight.w800,
                                      )
                                          : CommonText(
                                        formatTokenBalance(walletState.tokenBalance),
                                        size: 30,
                                        weight: FontWeight.w800,
                                      ),
                                      SizedBox(
                                        height: 17,
                                      ),
                                      WalletService(walletMainPage),
                                      SizedBox(
                                        height: 25,
                                      ),
                                    ],
                                  ),
                                ),
                                maxHeight: 250,
                                minHeight: 250)),
                        walletState.formatMessageList.isEmpty
                            ? SliverToBoxAdapter(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: (Get.height - 500) / 2,
                                ),
                                Image(
                                    width: 65,
                                    image: AssetImage('icons/record.png')),
                                SizedBox(
                                  height: 25,
                                ),
                                CommonText(
                                  isFil ? 'noData'.tr : 'noActivity'.tr,
                                  color: CustomColor.grey,
                                ),
                                SizedBox(
                                  height: 170,
                                ),
                              ],
                            ))
                            : SliverList(
                          delegate: SliverChildListDelegate(
                            // [
                            //   Container(
                            //     child: Text(walletState.interfaceMessageList.length.toString()),
                            //   )
                            // ]
                            messageKeys.map((item) {
                              String date = '';
                              if (item == yesterdayStr) {
                                date = 'yesterday'.tr;
                              } else if (item == todayStr) {
                                date = 'today'.tr;
                              }else{
                                date = item;
                              }
                              var massageList =
                              walletState.formatMessageList[item];
                              return Container(
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 20,
                                        padding: EdgeInsets.only(left: 12),
                                        width: double.infinity,
                                        alignment: Alignment.centerLeft,
                                        child: CommonText(
                                          date,
                                          size: 10,
                                          color: CustomColor.grey,
                                        ),
                                        color: CustomColor.bgGrey,
                                      ),
                                      Column(
                                        children: List.generate(massageList.length, (i) {
                                          var message = massageList[i];
                                          return MessageItem(message);
                                        }),
                                      )
                                    ],
                                  )
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String formatTokenBalance(balance){
    try{
      var unit = Decimal.fromInt(pow(10, token.precision));
      var balanceNum = Decimal.parse(balance);
      var _value = (balanceNum / unit).toString();
      var _decimal = _value.toDecimal;
      return  _decimal.fmtDown(4) + " " + token.symbol;
    }catch(error){
      print('error');
      return '0' + " " + token.symbol;
    }
  }

}

class WalletService extends StatelessWidget {
  final String page;

  WalletService(this.page);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            IconBtn(
              onTap: () {
                //Get.toNamed(walletMangePage);
                Get.toNamed(walletCodePage);
              },
              path: 'send.png',
              color: CustomColor.primary,
            ),
            CommonText(
              'rec'.tr,
              color: Color(0xffB4B5B7),
              size: 10,
            )
          ],
        ),
        SizedBox(
          width: 34,
        ),
        Column(
          children: [
            IconBtn(
              onTap: () {
                Get.toNamed(filTransferPage, arguments: {'page': page});
              },
              path: 'rec.png',
              color: Color(0xff5C8BCB),
            ),
            CommonText(
              'send'.tr,
              color: Color(0xffB4B5B7),
              size: 10,
            )
          ],
        ),
      ],
    );
  }
}

class IconBtn extends StatelessWidget {
  final Noop onTap;
  final String path;
  final Color color;
  final double size;

  IconBtn({this.onTap, this.path, this.color, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size / 5),
        child: Image(image: AssetImage('icons/$path')),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: color),
      ),
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
    );
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  SliverDelegate({
    @required this.minHeight,
    @required this.maxHeight,
    @required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
