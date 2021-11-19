import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/chain-new/global.dart';
import 'package:fil/models-new/chain_gas.dart';
import 'package:fil/chain/token.dart';
import 'package:meta/meta.dart';
import 'package:fil/store/store.dart';

part 'gas_event.dart';
part 'gas_state.dart';

class GasBloc extends Bloc<GasEvent, GasState> {
  GasBloc() : super(GasState.idle()) {
    on<ResetChainGas>((event,emit){
      var _gas = {
        "gasPrice":'0',
        "gasPremium":'0',
        "gasLimit":0,
        "level":0,
        "rpcType":'',
        "gasFeeCap":'0',
        "maxPriorityFee":'0',
        "maxFeePerGas":'0'
      };
      ChainGas gas = ChainGas.fromJson(_gas);
      $store.setGas(gas);
      emit(state.copyWithGasState(chainGas:gas));
    });
    on<GetGasEvent>((event,emit) async{
      try{
        Chain.setRpcNetwork(event.rpc, event.chainType);
        ChainGas res = await Chain.chainProvider.getGas(to:event.to,isToken:event.isToken,token:event.token);
        String maxPriority = '0';
        String maxFeePerGas = '0';
        if(event.rpcType == 'ethMain'){
          maxPriority = await Chain.chainProvider.getMaxPriorityFeePerGas();
          maxFeePerGas = await Chain.chainProvider.getMaxFeePerGas();

        }
        var _gas = {
          "gasLimit":res.gasLimit,
          "gasPremium":res.gasPremium,
          "gasPrice":res.gasPrice,
          "rpcType":event.rpcType,
          "gasFeeCap":res.gasFeeCap,
          "maxPriorityFee":maxPriority,
          "maxFeePerGas":maxFeePerGas
        };
        ChainGas gas = ChainGas.fromJson(_gas);
        $store.setGas(gas);
        emit(state.copyWithGasState(chainGas:gas));
      }catch(error){
        print(error);
      }
    });
  }
}
