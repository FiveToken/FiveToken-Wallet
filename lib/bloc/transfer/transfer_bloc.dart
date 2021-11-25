import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/chain/gas.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/nonce.dart';
import 'package:fil/request/global.dart';
import 'package:fil/widgets/toast.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:oktoast/oktoast.dart';

part 'transfer_event.dart';
part 'transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  TransferBloc() : super(TransferState.idle()) {
    on<TransferEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<GetNonceEvent>((event,emit) async{
      Chain.setRpcNetwork(event.rpc, event.chainType);
      String address = event.address;
      var result = await Chain.chainProvider.getNonce(address);
      var now = getSecondSinceEpoch();
      if (result != -1) {
        var nonceBoxInstance = OpenedBox.nonceInsance;
        var key = '$address\_${event.rpc}';
        if (!nonceBoxInstance.containsKey(key)) {
          nonceBoxInstance.put(key, Nonce(time: now, value: result));
        } else {
          Nonce nonceInfo = nonceBoxInstance.get(key);
          var interval = 5 * 60 * 1000;
          if (now - nonceInfo.time > interval) {
            nonceBoxInstance.put(key, Nonce(time: now, value: result));
          }
        }
        var kkk = nonceBoxInstance.get(key);
      }
      emit(state.copyWithTransferState(nonce: result));
    });

    on<SendTransactionEvent>((event,emit) async{
      try{
        showCustomLoading('Loading');
        Chain.setRpcNetwork(event.rpc, event.chainType);
        var result = '';
        if(event.isToken){
          result = await Chain.chainProvider.sendToken(
              event.from,
              event.to,
              event.amount,
              event.privateKey,
              event.gas,
              event.nonce
          );
        }else{
          result = await Chain.chainProvider.sendTransaction(
            event.from,
            event.to,
            event.amount,
            event.privateKey,
            event.gas,
            event.nonce,
          );
        }
        if(result == ''){
          showCustomError('sendFail'.tr);
        }
        dismissAllToast();
        emit(state.copyWithTransferState(transactionHash:result));
      }catch(error){
        dismissAllToast();
        print("================AppOpenEvent=========");
      }
    });

    on<GetOldMessageState>((event,emit) async{
      Chain.setRpcNetwork(event.rpc, event.chainType);
      List param = [];
      param.add({"from":event.from,"nonce":event.nonce});
      var result = await Chain.chainProvider.getMessagePendingState(param);
      String lastMegState = '';
      if(result != null){

      }else{

      }
      emit(state.copyWithTransferState(lastMessageState: lastMegState));
    });




  }
}
