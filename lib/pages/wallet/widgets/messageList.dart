import 'package:day/day.dart';
import 'package:fil/index.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CommonOnlineWallet extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CommonOnlineWidgetState();
  }
}

class CommonOnlineWidgetState extends State<CommonOnlineWallet>
    with RouteAware, WidgetsBindingObserver {
  bool enablePullDown = true;
  bool enablePullUp = true;
  StoreController controller = Get.find();
  Map<String, List<StoreMessage>> mesMap = {};
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var box = Hive.box<StoreMessage>(messageBox);
  List<StoreMessage> messageList = [];
  Timer timer;
  num currentNonce;
  void _onRefresh() async {
    await updateBalance();
    await getMessagesAfterFirstCompletedMessage();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    await getMessagesBeforeLastCompletedMessage();
    _refreshController.loadComplete();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    var list = getWalletSortedMessages();
    if (list.isEmpty) {
      getMessages().then((lis) {
        setState(() {
          messageList = lis;
          enablePullUp = lis.length == 80;
        });
      });
    } else {
      setState(() {
        messageList = list;
      });
      updateBalance();
      getMessagesAfterFirstCompletedMessage();
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
    setList();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) {
    super.didChangeAppLifecycleState(appLifecycleState);
    if (appLifecycleState == AppLifecycleState.resumed) {
      if (timer == null) {
        timer = Timer(Duration(milliseconds: 100), () async {
          updateBalance().then((value) {
            timer = null;
            getMessagesAfterFirstCompletedMessage();
          });
        });
      } else {
        timer.cancel();
      }
    }
  }

  Future<void> updateBalance() async {
    var wal = singleStoreController.wal;
    var res = await getBalance(singleStoreController.wal);
    if (res.nonce != -1) {}
    wal.balance = res.balance;
    singleStoreController.changeWalletBalance(res.balance);
    this.currentNonce = res.nonce;
    OpenedBox.addressInsance.put(wal.address, wal);
  }

  Future getMessagesAfterFirstCompletedMessage() async {
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

  Future getMessagesBeforeLastCompletedMessage() async {
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

  List<StoreMessage> getWalletSortedMessages() {
    var list = <StoreMessage>[];
    var address = controller.wal.address;
    box.values.forEach((element) {
      var message = element;
      if (message.from == address || message.to == address) {
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

  Future<List<StoreMessage>> getMessages(
      {num time, String direction = 'up', num count = 80}) async {
    try {
      var res = await getMessageList(
          address: controller.wal.address,
          direction: direction,
          time: time,
          count: count);
      if (res.isNotEmpty) {
        var messages = res.map((e) {
          var mes = StoreMessage.fromJson(e);
          mes.pending = 0;
          mes.owner = controller.wal.address;
          return mes;
        }).toList();
        var nonce = this.currentNonce;
        var pendingList = box.values.where((mes) => mes.pending == 1).toList();
        if (pendingList.isNotEmpty) {
          for (var k = 0; k < pendingList.length; k++) {
            var mes = pendingList[k];
            if (mes.nonce < nonce) {
              await box.delete(mes.signedCid);
            }
          }
        }
        for (var i = 0; i < messages.length; i++) {
          var m = messages[i];
          await box.put(m.signedCid, m);
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
                            var args = message.args;
                            if (args != null && args != 'null') {
                              var decodeArgs = jsonDecode(args);
                              if (decodeArgs != null &&
                                  (decodeArgs is Map) &&
                                  decodeArgs['AmountRequested'] != null) {
                                message.value = decodeArgs['AmountRequested'];
                              }
                            }
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
  final StoreMessage mes;
  MessageItem(this.mes);
  bool get isSend {
    return mes.from == singleStoreController.wal.address;
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

  String get value {
    var v = atto2Fil(mes.value);
    if (v == '0') {
      return '0 FIL';
    } else {
      return '${pending || fail ? '' : (isSend ? '-' : '+')}${atto2Fil(mes.value)} FIL';
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
