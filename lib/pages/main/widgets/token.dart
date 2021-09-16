import 'package:fil/chain/token.dart';
import 'package:fil/index.dart';
import 'package:fil/widgets/icons.dart';
import 'package:fil/widgets/random.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class TokenWidget extends StatefulWidget {
  final Token token;
  final Web3Client client;
  final Key key;
  TokenWidget({this.token, this.client, this.key});
  @override
  State<StatefulWidget> createState() {
    return TokenWidgetState();
  }
}

class TokenWidgetState extends State<TokenWidget> {
  String balance;
  StreamSubscription sub;
  StreamSubscription sub2;
  @override
  void initState() {
    super.initState();
    balance = widget.token.balance ?? "0";
    getBalance();
    nextTick(() {
      sub = Global.eventBus.on<RefreshEvent>().listen((event) {
        if (event.token == null ||
            event.token.address == widget.token.address) {
          getBalance();
        }
      });
      sub2 = Global.eventBus.on<WalletChangeEvent>().listen((event) {
        getBalance();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    sub?.cancel();
    sub2?.cancel();
  }

  void getBalance() async {
    var abi = ContractAbi.fromJson(Contract.abi, 'bnb');
    var con =
        DeployedContract(abi, EthereumAddress.fromHex(widget.token.address));
    try {
      var list = await widget.client.call(
          contract: con,
          function: con.function('balanceOf'),
          params: [EthereumAddress.fromHex($store.wal.addr)]);
      if (list.isNotEmpty) {
        var numStr = list[0];
        var t = widget.token;
        if (numStr is BigInt && numStr.toString() != t.balance) {
          t.balance = numStr.toString();
          OpenedBox.tokenInstance.put(t.address + t.rpc, t);
        }
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var token = widget.token;
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
            border:
                Border(bottom: BorderSide(color: Colors.grey[200], width: .5))),
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            RandomIcon(token.address),
            SizedBox(
              width: 10,
            ),
            CommonText(
              token.symbol,
              color: CustomColor.primary,
            ),
            Spacer(),
            CommonText(
              widget.token.formatBalance,
              color: CustomColor.primary,
            ),
          ],
        ),
      ),
      onTap: () {
        Global.cacheToken = token;
        Get.toNamed(
          walletMainPage,
        );
      },
    );
  }
}

class TokenList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TokenListState();
  }
}

class TokenListState extends State<TokenList> {
  Worker worker;
  Web3Client client;
  @override
  void initState() {
    super.initState();
    initClient($store.net);
    worker = ever($store.network, (net) {
      initClient(net);
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    worker.dispose();
  }

  void initClient(Network net) {
    client = Web3Client(net.url, http.Client());
  }

  @override
  Widget build(BuildContext context) {
    var list = OpenedBox.tokenInstance.values
        .where((token) => token.rpc == $store.net.rpc)
        .toList();
    return Column(
      children: [
        Column(
          children: List.generate(list.length, (index) {
            return TokenWidget(
              token: list[index],
              client: client,
              key: ValueKey(list[index].address),
            );
          }),
        ),
        SizedBox(
          height: 30,
        ),
        Visibility(
            visible: $store.net.chain != 'filecoin',
            child: GestureDetector(
              onTap: () {
                Get.toNamed(netTokenAddPage).then((value) {
                  setState(() {});
                });
              },
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [Icon(Icons.add), CommonText('addToken'.tr)],
                ),
              ),
            ))
      ],
    );
  }
}

class MainTokenWidget extends StatelessWidget {
  CoinIcon get coinIcon {
    var net = $store.net;
    var key = net.coin;
    if (CoinIcon.icons.containsKey(key)) {
      return CoinIcon.icons[key];
    } else {
      var key = '${net.chainId}${net.browser}${net.rpc}${net.chain}';
      var addr = hex.encode(utf8.encode(key));
      return CoinIcon(
          bg: Colors.transparent, border: false, icon: RandomIcon(addr));
    }
  }

  String get label {
    var map = {'eth': 'Ethereum', 'binance': 'Binance'};
    return $store.net.chain == ''
        ? $store.net.coin
        : map.containsKey($store.net.chain)
            ? map[$store.net.chain]
            : $store.net.chain;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
            border:
                Border(bottom: BorderSide(color: Colors.grey[200], width: .5))),
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Obx(() => Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      padding: EdgeInsets.all(coinIcon.border ? 2 : 0),
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: coinIcon.border ? .5 : 0,
                              color: Colors.grey[400]),
                          color: coinIcon.bg,
                          borderRadius: BorderRadius.circular(15)),
                      child: coinIcon.icon,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    CommonText(
                      label,
                      color: CustomColor.primary,
                    ),
                  ],
                )),
            Spacer(),
            Obx(() => CommonText(
                  $store.wal.formatBalance,
                  color: CustomColor.primary,
                )),
          ],
        ),
      ),
      onTap: () {
        Get.toNamed(walletMainPage);
      },
    );
  }
}
