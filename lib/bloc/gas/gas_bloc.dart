import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/chain-new/global.dart';
import 'package:fil/chain/gas.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/widgets/toast.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:fil/store/store.dart';
import 'package:oktoast/oktoast.dart';

part 'gas_event.dart';
part 'gas_state.dart';

class GasBloc extends Bloc<GasEvent, GasState> {
  GasBloc() : super(GasState.idle()) {
    on<ResetChainGasEvent>((event,emit){
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
      emit(state.copyWithGasState(getGasState:''));
    });
    on<GetGasEvent>((event,emit) async{
      try{
        showCustomLoading('Loading');
        Chain.setRpcNetwork(event.rpc, event.chainType);
        ChainGas res = await Chain.chainProvider.getGas(to:event.to,isToken:event.isToken,token:event.token);
        dismissAllToast();
        if(res.gasLimit != 0){
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
          emit(state.copyWithGasState(getGasState:'success'));
        }else{
          emit(state.copyWithGasState(getGasState:''));
          showCustomError('gasFail'.tr);
        }
      }catch(error){
        add(ResetChainGasEvent());
        showCustomError('gasFail'.tr);
        dismissAllToast();
        print(error);
      }
    });

  }
}
