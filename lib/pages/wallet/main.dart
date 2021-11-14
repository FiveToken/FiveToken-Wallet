import 'dart:math';
import 'package:fil/bloc/main/main_bloc.dart';
import 'package:fil/bloc/wallet/wallet_bloc.dart';
import 'package:fil/index.dart';
import 'package:fil/models-new/message_pending.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:day/day.dart';
import 'package:fil/chain-new/global.dart';

// import 'package:fil/index.dart';
import 'package:fil/pages/wallet/widgets/messageItem.dart';
import 'package:fil/widgets/icons.dart';
import 'package:fil/widgets/random.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/widgets/scaffold.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/widgets/fresh.dart';
import 'package:web3dart/web3dart.dart' hide AddressType;
import 'package:http/http.dart' as http;
import 'package:fil/models/index.dart';
import 'package:fil/store/store.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/time.dart';
import 'package:fil/chain/provider.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/app.dart';
import 'package:fil/actions/event.dart';

class WalletMainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletMainPageState();
  }
}

class WalletMainPageState extends State<WalletMainPage> with RouteAware {
  static int pageSize = 10;
  Token token = Global.cacheToken;

  bool get showToken => token != null;
  bool enablePullDown = true;
  bool enablePullUp;
  Map<String, List<CacheMessage>> mesMap = {};
  var box = OpenedBox.mesInstance;
  List<CacheMessage> messageList = [];
  num currentNonce;
  Network net = $store.net;
  ChainProvider provider;
  Web3Client client;

  bool get isFil {
    return this.net.addressType == AddressType.filecoin.type;
  }

  @override
  void initState() {
    super.initState();
    enablePullUp = isFil;
    provider = isFil ? FilecoinProvider(net) : EthProvider(net);
    // initList();
    // getNonce();
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
    provider?.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    setList();
  }

  /*
    When the current network is filecoin, the list data is local data,
    and the interface returns the linked data (removing and local duplicate data).
    When the current network is eth, the list data is local data
   */


  Future loadEthLatestMessage() async {
    var pendingList = box.values
        .where((mes) => mes.pending == 1 && mes.rpc == net.rpc)
        .toList();
    if (pendingList.isNotEmpty) {
      try {
        var list = await Future.wait<TransactionReceipt>(
            pendingList.map((mes) => client.getTransactionReceipt(mes.hash)));
        list = list.where((r) => r != null).toList();
        Map<String, TransactionReceipt> map = {};
        for (var i = 0; i < list.length; i++) {
          var t = list[i];
          var mes = pendingList[i];
          if (t != null && t.gasUsed != null) {
            var limit = BigInt.tryParse(mes.gas.gasPrice) ?? BigInt.one;
            mes.fee = (limit * t.gasUsed).toString();
            map[mes.hash] = t;
          }
        }
        if (map.isNotEmpty) {
          // var futures = map.values
          //     .map((t) => client.getBlockByNumber(t.blockNumber.blockNum))
          //     .toList();
          Chain.setRpcNetwork($store.net.rpc, $store.net.addressType);
          var futures = map.values
              .map((t) =>
                  Chain.chainProvider.getBlockByNumber(t.blockNumber.blockNum))
              .toList();
          var mesList = map.keys.toList();
          var blocks = await Future.wait(futures);
          for (var i = 0; i < mesList.length; i++) {
            var block = blocks[i];
            var key = mesList[i];
            var mes = box.get(key);
            if (block.timestamp != null && block.timestamp is int) {
              mes.pending = 0;
              mes.blockTime = block.timestamp;
              mes.height = block.number;
              mes.exitCode = map[key].status ? 0 : 1;
              box.put(key, mes);
            }
          }
          setList();
        }
      } catch (e) {
        print(e);
      }
    }
  }

  Future loadFilecoinOldMessages() async {
    var completeList = messageList.where((mes) => mes.mid != '').toList();
    var mid = completeList.last.mid;
    var lis = await getMessages(direction: 'up', mid: mid);
    if (lis.isNotEmpty) {
      setState(() {
        messageList = getWalletSortedMessages();
        enablePullUp = lis.length == pageSize;
      });
    } else {
      setState(() {
        enablePullUp = false;
      });
    }
  }

  List<CacheMessage> getWalletSortedMessages() {
    var list = <CacheMessage>[];
    var address = $store.wal.addr;
    box.values.forEach((message) {
      if ((message.from == address || message.to == address) &&
          message.rpc == $store.net.rpc) {
        list.add(message);
      }
    });
    list.sort((a, b) {
      if (a.blockTime != null && b.blockTime != null) {
        return b.blockTime.compareTo(a.blockTime);
      } else {
        return 1;
      }
    });
    return list;
  }

  Future<List<CacheMessage>> getMessages(
      {String direction = 'up', String mid}) async {
    try {
      var res = await (provider as FilecoinProvider).getFilecoinMessageList(
          actor: $store.wal.addr, direction: direction, mid: mid);
      if (res.isNotEmpty) {
        List<CacheMessage> messages = [];
        res.forEach((map) {
          var mes = CacheMessage(
              hash: map['cid'],
              to: map['to'],
              from: map['from'],
              value: map['value'],
              blockTime: map['block_time'],
              exitCode: map['exit_code'],
              owner: $store.wal.addr,
              pending: 0,
              rpc: net.rpc,
              height: map['block_epoch'],
              fee: map['gas_fee'],
              mid: map['mid'],
              nonce: map['nonce']);
          messages.add(mes);
        });
        for (var i = 0; i < messages.length; i++) {
          var m = messages[i];
          await box.put(m.hash, m);
        }
        return messages.toList();
      } else {
        return [];
      }
    } catch (e) {
      print(e);
      return [];
    }
  }

  void setList() {
    var list = getWalletSortedMessages();
    setState(() {
      messageList = list;
    });
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

  Future onRefresh() async {
    // getBalance();
    BlocProvider.of<MainBloc>(context).add(GetBalanceEvent(
      $store.net.rpc,
      $store.net.addressType,
      $store.wal.addr,
    ));

    Global.eventBus.fire(RefreshEvent(token: token));
    // await loadLatestMessage();
  }

  Future onLoading() async {
    BlocProvider.of<WalletBloc>(context).add(GetFileCoinMessageListEvent(
      $store.net.rpc, $store.net.addressType, $store.wal.addr,'up',
    )
    );
  }

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<MainBloc>(context).add(GetBalanceEvent(
        $store.net.rpc,
        $store.net.addressType,
        $store.wal.addr
      )
    );
    mesMap = {};
    var today = Day();
    var formatStr = 'YYYY-MM-DD';
    var todayStr = today.format(formatStr);
    var yesterday = today.subtract(1, 'd') as Day;
    var yesterdayStr = yesterday.format(formatStr);

    return BlocProvider(
      create: (ctx) => WalletBloc()
        ..add(GetStoreMessageListEvent($store.net.rpc, $store.net.addressType))
        ..add(GetFileCoinMessageListEvent(
            $store.net.rpc, $store.net.addressType, $store.wal.addr,'down',
            )
        ),
      child: BlocBuilder<WalletBloc, WalletState>(
        builder: (ctx, walletState) {
          return BlocBuilder<MainBloc, MainState>(
            builder: (ctx, state) {
              List messageKeys = walletState.formatMessageList.keys.toList();
              int count = messageKeys.length;
              return CommonScaffold(
                title: title,
                hasFooter: false,
                body: CustomRefreshWidget(
                    enablePullUp: isFil && enablePullUp,
                    onLoading: onLoading,
                    onRefresh: onRefresh,
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
                                              formatCoin(state.balance),
                                              size: 30,
                                              weight: FontWeight.w800,
                                            )
                                          : CommonText(
                                              token.formatBalance,
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
                                  messageKeys.map((item) {
                                    String date = '';
                                    if (item == yesterdayStr) {
                                      date = 'yesterday'.tr;
                                    } else if (item == todayStr) {
                                      date = 'today'.tr;
                                    }
                                    var massageList =
                                        walletState.formatMessageList[item];
                                    return Container(
                                        child: _item(date, massageList));
                                  }).toList(),
                                ),
                              ),
                      ],
                    ),
                    ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _item(date, massageList) {
    return Column(
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
    );
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
