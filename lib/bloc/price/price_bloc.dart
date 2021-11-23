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
          'binance': 'binancecoin',
          'filecoin':'filecoin'
        };
        List param = [
          {
            "id":map[event.chainType],
            "vs":"usd"
          },
          {
            "id":map[event.chainType],
            "vs":"cny"
          }
        ];
        Chain.setRpcNetwork('filecoin', 'https://api.fivetoken.io');
        var res = await Chain.chainProvider.getTokenPrice(param);
        if(res.length > 0){
          double usd = 0;
          double cny = 0;
          res.forEach((n) {
            if(n["vs"] == 'usd'){
              usd = n["price"];
            }
            if(n["vs"] == 'cny'){
              cny = n["price"];
            }
          });
          Global.price = CoinPrice.fromJson({
            "usd":usd,
            "cny":cny
          });
          String priceTmp = getMarketPrice($store.wal.balance, usd);
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
