import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/request/global.dart';
import 'package:fil/common/global.dart';
import 'package:fil/models/wallet.dart';

part 'price_event.dart';
part 'price_state.dart';

class PriceBloc extends Bloc<PriceEvent, PriceState> {
  CoinPrice price = CoinPrice();
  PriceBloc() : super(PriceState.idle()) {
    on<ResetUsdPriceEvent>((event, emit) {
      emit(state.copy(usdPrice:0));
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
          emit(state.copy(usdPrice: usd));
        }
      }catch(error){
        print('error');
      }
    });
  }
}
