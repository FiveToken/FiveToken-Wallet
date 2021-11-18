// import 'package:fil/index.dart';
import 'package:fil/bloc/price/price_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/utils.dart';
import 'dart:math';
import 'package:fil/widgets/text.dart';
import 'package:fil/models/index.dart';
import 'package:fil/store/store.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/api/third.dart';

class CoinPriceWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CoinPriceState();
  }
}

class CoinPriceState extends State<CoinPriceWidget> {
  CoinPrice price = CoinPrice();
  Worker worker;
  String marketPrice = '';
  BuildContext _context;
  // StreamSubscription sub;
  @override
  void initState() {
    super.initState();
    if(mounted){
      worker = ever($store.wallet, (ChainWallet wal) {
        var net = Network.getNetByRpc(wal.rpc);
        if (net.hasPrice) {
          getPrice(context, net);
          // BlocProvider.of<PriceBloc>(_context)..add(GetPriceEvent(net: net));
        }
      });
      // sub = Global.eventBus.on<RefreshEvent>().listen((event) {
      //   getPrice($store.net);
      // });
      getPrice(context, $store.net);
      // BlocProvider.of<PriceBloc>(_context)..add(GetPriceEvent(net: $store.net));
    }
  }

  @override
  void dispose() {
    super.dispose();
    worker.dispose();
    // sub.cancel();
  }

  double get rate {
    var lang = Global.langCode;
    lang = 'en';
    return lang == 'en' ? price.usd : price.cny;
  }

  void getPrice(context, Network net) async {
    var coin = net.chain;
    var map = {'eth': 'eth', 'bnb': 'binance'};
    if (coin == '' && map.containsKey(net.coin.toLowerCase())) {
      coin = map[net.coin.toLowerCase()];
    }
    var res = await getFilPrice(coin);
    Global.price = res;
    if (res.cny != 0) {
      if (mounted) {
        price = res;
        String priceTmp = getMarketPrice($store.wal.balance, res.usd);
        BlocProvider.of<PriceBloc>(_context)..add(SetPriceEvent(marketPrice:priceTmp ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => PriceBloc()..add(SetPriceEvent()),
        child: BlocBuilder<PriceBloc, PriceState>(builder: (ctx, state){
          _context = ctx;
          return Obx(
              () => Visibility(
                child: CommonText(
                  state.priceMarket,
                  size: 30,
                  weight: FontWeight.w800,
                ),
                visible: $store.net.hasPrice,
              )
          );
        })
    );
  }
}

String getMarketPrice(String balance, double rate) {
  try {
    var b = double.parse(balance) / pow(10, 18);
    //var code=Global.langCode;
    var code = 'en';
    var unit = code == 'en' ? '\$' : '¥';
    return rate == 0
        ? ''
        : ' $unit ${formatDouble((rate * b).toStringAsFixed(2))}';
  } catch (e) {
    return '';
  }
}
