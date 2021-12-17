import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/bloc/wallet/wallet_bloc.dart';
import 'package:fil/chain/gas.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/models/gas_response.dart';
import 'package:fil/request/global.dart';
import 'package:fil/widgets/toast.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:fil/store/store.dart';
import 'package:oktoast/oktoast.dart';

part 'gas_event.dart';
part 'gas_state.dart';

class GasBloc extends Bloc<GasEvent, GasState> {
  GasBloc() : super(GasState.idle()) {
    on<ResetGetGasStateEvent>((event,emit){
      emit(state.copyWithGasState(getGasState:''));
    });
    on<GetGasEvent>((event,emit) async{
      try{
        showCustomLoading('Loading');
        Chain.setRpcNetwork(event.rpc, event.chainType);
        GasResponse res = await Chain.chainProvider.getGas(from:$store.wal.address,to:event.to,isToken:event.isToken,token:event.token);
        dismissAllToast();
        if(res.gasState == "success"){
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
          emit(state.copyWithGasState(getGasState:'error',errorMessage:res.message));
        }
      }catch(error){
        add(ResetGetGasStateEvent());
        dismissAllToast();
      }
    });


    on<UpdateMessListStateEvent>((event,emit) async {
      List storeMessageList = getStoreMsgList(event.symbol).map((e) => e).toList();
      final pendingList = storeMessageList.where((mes) => mes.pending == 1).toList();
      if(pendingList.length > 0){
        if(event.chainType == 'filecoin'){
          Chain.setRpcNetwork(event.rpc, event.chainType);
          List param = [];
          pendingList.forEach((n) async {
            param.add({"from":n.from,"nonce":n.nonce});
          });
          await upDateFileCoinMessageState(event.rpc,event.chainType,pendingList,param);
        }else{
          await updateEthMessageListState(event.rpc,event.chainType,pendingList);
        }
        List _list = getStoreMsgList(event.symbol).map((e) => e).toList();
        emit(state.copyWithGasState(
            timestamp:DateTime.now().microsecondsSinceEpoch
        ));
      }
    });

  }
}
