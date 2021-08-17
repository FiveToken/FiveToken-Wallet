import 'package:day/day.dart';
import 'package:fil/index.dart';
import 'package:fil/pages/wallet/widgets/messageList.dart';
import 'package:fil/widgets/icons.dart';
import 'package:fil/widgets/random.dart';
import 'package:web3dart/web3dart.dart' hide AddressType;
import 'package:http/http.dart' as http;

class WalletMainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return WalletMainPageState();
  }
}

class WalletMainPageState extends State<WalletMainPage> with RouteAware {
  // String price;
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
    deleteExtraList();
    initList();
    // getNonce();
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

  void initList() {
    var list = getWalletSortedMessages();
    if (list.isEmpty) {
      if (isFil) {
        getMessages().then((lis) {
          setState(() {
            messageList = lis;
            enablePullUp = lis.length == 80;
          });
        });
      } else {
        client = Web3Client(net.rpc, http.Client());
      }
    } else {
      setState(() {
        messageList = list;
      });
      if (isFil) {
        loadFilecoinLatestMessages();
      } else {
        client = Web3Client(net.rpc, http.Client());
      }
    }
  }

  Future loadLatestMessage() async {
    if (isFil) {
      await loadFilecoinLatestMessages();
    } else {
      await loadEthLatestMessage();
    }
  }

  Future getNonce() async {
    var res = await provider.getNonce();
    if (res != -1) {
      this.currentNonce = res;
    }
  }

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
          var futures = map.values
              .map((t) => client.getBlockByNumber(t.blockNumber.blockNum))
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

  Future loadFilecoinLatestMessages() async {
    var list = messageList;
    num time;
    if (list.isNotEmpty) {
      for (var i = 0; i < list.length; i++) {
        if (list[i].pending != 1) {
          time = list[i].blockTime;
          break;
        }
      }
    }

    var lis = await getMessages(time: time, direction: 'down', count: 400);

    if (lis.isNotEmpty) {
      if (mounted) {
        setState(() {
          messageList = getWalletSortedMessages();
        });
      }
    }
  }

  Future loadFilecoinOldMessages() async {
    var list = messageList;
    num time;
    if (list.isNotEmpty) {
      for (var i = list.length - 1; i > 0; i--) {
        var current = list[i];
        if (current.pending != 1) {
          time = current.blockTime;
          break;
        }
      }
    }
    var lis = await getMessages(time: time, direction: 'up');
    if (lis.isNotEmpty) {
      setState(() {
        messageList = getWalletSortedMessages();
        enablePullUp = lis.length == 80;
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
      if ((message.owner == address) && message.rpc == $store.net.rpc) {
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
      {num time, String direction = 'up', num count = 80}) async {
    try {
      var res = await getMessageList(
          address: $store.wal.addr,
          direction: direction,
          time: time,
          count: count);
      if (res.isNotEmpty) {
        List<CacheMessage> messages = [];
        res.forEach((map) {
          var mes = CacheMessage(
              hash: map['signed_cid'],
              to: map['to'],
              from: map['from'],
              value: map['value'],
              blockTime: map['block_time'],
              exitCode: map['exit_code'],
              owner: $store.wal.addr,
              pending: 0,
              rpc: net.rpc,
              height: map['height'],
              nonce: map['nonce']);
          if (map['method_name'] == 'transfer' ||
              map['method_name'] == 'send') {
            messages.add(mes);
          }
        });
        // var nonce = this.currentNonce;
        // var pendingList = box.values.where((mes) => mes.pending == 1).toList();
        // if (pendingList.isNotEmpty) {
        //   for (var k = 0; k < pendingList.length; k++) {
        //     var mes = pendingList[k];
        //     if (mes.nonce < nonce) {
        //       await box.delete(mes.hash);
        //     }
        //   }
        // }
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

  void deleteExtraList() async {
    var allList = OpenedBox.mesInstance.values
        .where((mes) => mes.from == $store.wal.addr && mes.rpc == net.rpc);
    List<CacheMessage> pendingList = [];
    List<CacheMessage> resolvedList = [];
    allList.forEach((mes) {
      if (mes.pending == 1) {
        pendingList.add(mes);
      } else {
        resolvedList.add(mes);
      }
    });
    if (resolvedList.isNotEmpty && pendingList.isNotEmpty) {
      List<num> shouldDeleteNonce = [];
      var pendingNonce = pendingList.map((mes) => mes.nonce);
      resolvedList.forEach((mes) {
        if (pendingNonce.contains(mes.nonce)) {
          shouldDeleteNonce.add(mes.nonce);
        }
      });
      if (shouldDeleteNonce.isNotEmpty) {
        var deleteKeys = pendingList
            .where((mes) => shouldDeleteNonce.contains(mes.nonce))
            .map((mes) => mes.hash);
        box.deleteAll(deleteKeys);
      }
    }
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
    // if (this.currentNonce == null) {
    //   await getNonce();
    // }
    getBalance();
    Global.eventBus.fire(RefreshEvent(token: token));
    await loadLatestMessage();
  }

  Future onLoading() async {
    await loadFilecoinOldMessages();
  }

  @override
  Widget build(BuildContext context) {
    mesMap = {};
    var filterList = messageList;
    var today = Day();
    var formatStr = 'YYYY-MM-DD';
    var todayStr = today.format(formatStr);
    var yestoday = today.subtract(1, 'd') as Day;
    var yestodayStr = yestoday.format(formatStr);
    filterList.forEach((mes) {
      var time = formatTimeByStr(mes.blockTime, str: formatStr);

      var item = mesMap[time];
      if (item == null) {
        mesMap[time] = [];
      }
      mesMap[time].add(mes);
    });
    var keys = mesMap.keys.toList();
    var noData = filterList.isEmpty;
    return CommonScaffold(
      title: title,
      hasFooter: false,
      body: CustomRefreshWidget(
          enablePullUp: isFil,
          onLoading: onLoading,
          child: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverDelegate(
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.fromLTRB(0, 25, 0, 17),
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
                                              width: coinIcon.border ? .5 : 0,
                                              color: Colors.grey[400]),
                                          color: coinIcon.bg,
                                          borderRadius:
                                              BorderRadius.circular(35)),
                                      child: coinIcon.icon,
                                    ),
                              alignment: Alignment.center,
                              width: double.infinity,
                            ),
                            !showToken
                                ? Obx(() => CommonText(
                                      formatCoin($store.wal.balance),
                                      size: 30,
                                      weight: FontWeight.w800,
                                    ))
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
              noData
                  ? SliverToBoxAdapter(
                      child: Column(
                      children: [
                        SizedBox(
                          height: (Get.height - 500) / 2,
                        ),
                        Image(width: 65, image: AssetImage('icons/record.png')),
                        SizedBox(
                          height: 25,
                        ),
                        CommonText(
                          'noData'.tr,
                          color: CustomColor.grey,
                        ),
                        SizedBox(
                          height: 170,
                        ),
                      ],
                    ))
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                      var date = keys[index];
                      var l = mesMap[date];
                      if (date == yestodayStr) {
                        date = 'yestoday'.tr;
                      } else if (date == todayStr) {
                        date = 'today'.tr;
                      }
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
                            children: List.generate(l.length, (i) {
                              var message = l[i];
                              return MessageItem(message);
                            }),
                          )
                        ],
                      );
                    }, childCount: keys.length)),
            ],
          ),
          onRefresh: onRefresh),
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

class NoData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacer(),
        Image(width: 65, image: AssetImage('icons/record.png')),
        SizedBox(
          height: 25,
        ),
        CommonText(
          'noData'.tr,
          color: CustomColor.grey,
        ),
        SizedBox(
          height: 170,
        ),
      ],
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
