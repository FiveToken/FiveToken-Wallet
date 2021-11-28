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
        var chainType = $store.net.chain;
        BlocProvider.of<PriceBloc>(_context)..add(ResetUsdPriceEvent())..add(GetPriceEvent(chainType));
      });
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => PriceBloc()..add(ResetUsdPriceEvent())..add(GetPriceEvent($store.net.chain)),
        child: BlocBuilder<PriceBloc, PriceState>(builder: (context, state){
          return CommonText(
            getUsdPrce($store.wal.balance,state.usdPrice),
            size: 30,
            weight: FontWeight.w800,
          );
        })
    );
  }

  String getUsdPrce(String balance,double usd){
    String unit = '\$';
    try{
      if(usd > 0){
        var _balance = double.parse(balance) / pow(10, 18);
        var usdPrice = formatDouble((usd * _balance).toStringAsFixed(2));
        return '$unit ${usdPrice}';
      }else{
        return unit + ' 0';
      }
    }catch(error){
      return unit + ' 0';
    }
  }

}
