
import 'package:fil/bloc/main/main_bloc.dart';
import 'package:fil/models/wallet.dart' show CoinPrice;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/utils.dart';
import 'dart:math';
import 'package:fil/widgets/text.dart';

class CoinPriceWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CoinPriceState();
  }
}
// widget of coin price
class CoinPriceState extends State<CoinPriceWidget> {
  CoinPrice price = CoinPrice();
  Worker worker;
  String marketPrice = '';
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    worker.dispose();
  }

  // get price rate
  double get rate {
    var lang = Global.langCode;
    lang = 'en';
    return lang == 'en' ? price.usd : price.cny;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainBloc,MainState>(
        builder: (context, mainState){
          return CommonText(
            getUsdPrice(mainState.balance,mainState.usd),
            size: 30,
            weight: FontWeight.w800,
          );
        }
    );

  }

  // get price of USD
  String getUsdPrice(String balance,num usd){
    String unit = '\$';
    try{
      if(usd > 0){
        var _balance = num.parse(balance) / pow(10, 18);
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
