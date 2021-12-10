import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/request/global.dart';
import 'package:fil/common/global.dart';
import 'package:fil/models/wallet.dart';
import 'package:fil/widgets/toast.dart';
import 'package:oktoast/oktoast.dart';

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
        showCustomLoading('Loading');
        var map = {
          'eth': 'ethereum',
          'binance': 'binancecoin',
          'filecoin':'filecoin'
        };
        List param = [
          {
            "id":map[event.chainType],
            "vs":"usd"
          }
        ];
        Chain.setRpcNetwork(Network.filecoinMainNet.chain, Network.filecoinMainNet.rpc);
        var res = await Chain.chainProvider.getTokenPrice(param);
        dismissAllToast();
        if(res.length > 0){
          double usd = 0;
          double cny = 0;
          res.forEach((n) {
            if(n["vs"] == 'usd'){
              usd = double.parse((n["price"]).toString());
            }
            if(n["vs"] == 'cny'){
              cny = double.parse((n["price"]).toString());
            }
          });
          Global.price = CoinPrice.fromJson({
            "usd":usd,
            "cny":cny
          });
          emit(state.copy(usdPrice: usd));
        }else{
          print('error');
        }
      }catch(error){
        dismissAllToast();
        print('error');
      }
    });
  }
}
