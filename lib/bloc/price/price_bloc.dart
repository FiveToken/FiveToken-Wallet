import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/api/third.dart';
import 'package:fil/chain-new/global.dart';
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
      try{
        var map = {
          'eth': 'ethereum',
          'binance': 'filecoin',
          'filecoin':'filecoin'
        };
        Chain.setRpcNetwork('filecoin', 'https://api.fivetoken.io');
        var res = await Chain.chainProvider.getTokenPrice(map[event.chainType], 'usd');
        if(res != '0'){
          Global.price = CoinPrice.fromJson({
            "usd":double.parse(res),
            "cny":0.0
          });
          String priceTmp = getMarketPrice($store.wal.balance, double.parse(res));
          emit(state.copy(priceMarket: priceTmp));
        }
      }catch(error){
        print('error');
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
