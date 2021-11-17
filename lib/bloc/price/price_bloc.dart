import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/api/third.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/common/global.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/store/store.dart';
import 'package:meta/meta.dart';

part 'price_event.dart';
part 'price_state.dart';

class PriceBloc extends Bloc<PriceEvent, PriceState> {
  CoinPrice price = CoinPrice();
  PriceBloc() : super(PriceState.idle()) {
    on<SetPriceEvent>((event, emit) {
      emit(state.copy(priceMarket:event.marketPrice));
    });
    on<GetPriceEvent>((event, emit) async{
      Network net = event.net;
      var coin = net.chain;
      var map = {'eth': 'eth', 'bnb': 'binance'};
      if (coin == '' && map.containsKey(net.coin.toLowerCase())) {
        coin = map[net.coin.toLowerCase()];
      }
      var res = await getFilPrice(coin);
      Global.price = res;
      if (res.cny != 0) {
        price = res;
        String priceTmp = getMarketPrice($store.wal.balance, res.usd);
        emit(state.copy(priceMarket: priceTmp));
      }
    });
  }

  double get rate {
    var lang = Global.langCode;
    lang = 'en';
    return lang == 'en' ? price.usd : price.cny;
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

}
