import 'package:fil/bloc/main/main_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/utils.dart';
import 'dart:math';
import 'package:fil/widgets/text.dart';
import 'package:fil/models/index.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    worker.dispose();
  }

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
            getUsdPrce(mainState.balance,mainState.usd),
            size: 30,
            weight: FontWeight.w800,
          );
        }
    );

  }

  String getUsdPrce(String balance,num usd){
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
