import 'package:day/day.dart';
import 'package:fil/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:web3dart/web3dart.dart' hide AddressType;
import 'package:http/http.dart' as http;

class MessageListWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CommonOnlineWidgetState();
  }
}

class CommonOnlineWidgetState extends State<MessageListWidget> with RouteAware {
  bool enablePullDown = true;
  bool enablePullUp;
  Map<String, List<CacheMessage>> mesMap = {};
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var box = OpenedBox.mesInstance;
  List<CacheMessage> messageList = [];
  num currentNonce;
  StreamSubscription sub;
  Network net = $store.net;
  ChainProvider provider;
  Web3Client client;
  bool get isFil {
    return this.net.addressType == AddressType.filecoin.type;
  }

  void _onRefresh() async {
    if (this.currentNonce == null) {
      await getNonce();
    }
    await loadLatestMessage();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await loadFilecoinOldMessages();
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    enablePullUp = isFil;
    provider = isFil ? FilecoinProvider(net) : EthProvider(net);
    sub = Global.eventBus.on<AppStateChangeEvent>().listen((event) {
      updateBalance().then((value) {
        loadFilecoinLatestMessages();
      });
    });
    deleteExtraList();
    initList();
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
    sub.cancel();
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
      // updateBalance();
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

  Future<void> updateBalance() async {
    var wal = $store.wal;
    var res = await getBalance($store.wal);
    if (res.nonce != -1) {}
    wal.balance = res.balance;
    $store.changeWalletBalance(res.balance);
    this.currentNonce = res.nonce;
    OpenedBox.walletInstance.put(wal.address, wal);
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
    return noData
        ? NoData()
        : Column(
            children: [
              Column(
                children: [],
              ),
              Expanded(
                  child: SmartRefresher(
                enablePullDown: enablePullDown,
                enablePullUp: enablePullUp,
                header: WaterDropHeader(
                  waterDropColor: CustomColor.primary,
                  complete: Text('finish'.tr),
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
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
                  },
                  itemCount: keys.length,
                ),
              ))
            ],
          );
  }
}

class MessageItem extends StatelessWidget {
  final CacheMessage mes;
  MessageItem(this.mes);
  bool get isSend {
    return mes.from == $store.wal.address;
  }

  bool get fail {
    return mes.exitCode != 0;
  }

  bool get pending {
    return mes.pending == 1;
  }

  String get addr {
    var pre = isSend ? 'to'.tr : 'from'.tr;
    var address = isSend ? mes.to : mes.from;
    return '$pre ${dotString(str: address)}';
  }

  bool get isToken => mes.token != null;
  String get value {
    var v =
        isToken ? mes.token.getFormatBalance(mes.value) : formatCoin(mes.value);
    var unit = isToken ? $store.net.coin : mes.token?.symbol;
    if (v == '0') {
      return '0 $unit';
    } else {
      return '${pending || fail ? '' : (isSend ? '-' : '+')} $v';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Get.toNamed(filDetailPage, arguments: mes);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
        child: Row(
          children: [
            IconBtn(
              size: 32,
              color: Color(pending
                  ? 0xffE8CC5C
                  : (fail
                      ? 0xffB4B5B7
                      : isSend
                          ? 0xff5C8BCB
                          : 0xff5CC1CB)),
              path: (pending
                  ? 'pending.png'
                  : (fail ? 'fail.png' : (isSend ? 'rec.png' : 'send.png'))),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Layout.colStart([
                CommonText.main(
                  pending
                      ? 'pending'.tr
                      : (fail
                          ? 'fail'.tr
                          : isSend
                              ? 'sended'.tr
                              : 'reced'.tr),
                  size: 15,
                ),
                CommonText.grey(addr, size: 10),
              ]),
            ),
            CommonText(
              value,
              size: 15,
              color: CustomColor.primary,
              weight: FontWeight.w500,
            )
          ],
        ),
      ),
    );
  }
}