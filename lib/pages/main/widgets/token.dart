import 'dart:convert';
import 'dart:async';
import 'package:fil/bloc/home/home_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:fil/chain/token.dart';
import 'package:convert/convert.dart';
import 'package:fil/widgets/icons.dart';
import 'package:fil/widgets/random.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;
import 'package:fil/store/store.dart';
import 'package:fil/widgets/text.dart';
import 'package:fil/common/global.dart';
import 'package:fil/routes/path.dart';
import 'package:fil/widgets/style.dart';
import 'package:fil/actions/event.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/chain/net.dart';


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
    // getBalance();
    nextTick(() {
      sub = Global.eventBus.on<RefreshEvent>().listen((event) {
        if (event.token == null ||
            event.token.address == widget.token.address) {
          // getBalance();
        }
      });
      sub2 = Global.eventBus.on<WalletChangeEvent>().listen((event) {
        // getBalance();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    sub?.cancel();
    sub2?.cancel();
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
  final Web3Client defaultClient;
  TokenList({this.defaultClient});
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
    worker = ever($store.network, (net) {
      if (mounted) {
        BlocProvider.of<HomeBloc>(context).add(GetTokenListEvent($store.wal.addr));
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    worker.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // var list = OpenedBox.tokenInstance.values
    //     .where((token) => token.rpc == $store.net.rpc)
    //     .toList();
    return BlocProvider(
      create: (ctx)=> HomeBloc()..add(GetTokenListEvent($store.wal.addr)),
      child: BlocBuilder<HomeBloc,HomeState>(
          builder: (context,state){
            return Column(
              children: [
                Column(
                  children: List.generate(state.tokenList.length, (index) {
                    return TokenWidget(
                      token: state.tokenList[index],
                      client: client,
                      key: ValueKey(state.tokenList[index].address),
                    );
                  }),
                ),
                SizedBox(
                  height: 30,
                ),
                Visibility(
                    visible: $store.net.chain != 'filecoin',
                    child: GestureDetector(
                      onTap: () async{
                       await Get.toNamed(netTokenAddPage);
                       context.read<HomeBloc>().add(GetTokenListEvent($store.wal.addr));
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
      ),
    );
  }
}

