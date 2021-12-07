import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/chain/gas.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/common/utils.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/models/nonce.dart';
import 'package:fil/models/transaction_response.dart';
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
      }
      emit(state.copyWithTransferState(nonce: result));
    });

    on<SendTransactionEvent>((event,emit) async{
      bool isFetch = false;
      try{
        if(isFetch){
          return;
        }
        showCustomLoading('Loading');
        Chain.setRpcNetwork(event.rpc, event.chainType);
        var result = TransactionResponse(
          cid: '',
          message: ''
        );
        if(event.isToken){
          isFetch = true;
          String tokenAddress = event.token.address;
          result = await Chain.chainProvider.sendToken(
              to:event.to,
              amount:event.amount,
              private:event.privateKey,
              gas:event.gas,
              addr:tokenAddress,
              nonce:event.nonce
          );
        }else{
          isFetch = true;
          result = await Chain.chainProvider.sendTransaction(
            event.from,
            event.to,
            event.amount,
            event.privateKey,
            event.gas,
            event.nonce,
          );
        }
        isFetch = false;
        if(result.cid != ''){
          emit(state.copyWithTransferState(
              response:result,
              messageState:'success'
          ));
        }else{
          emit(state.copyWithTransferState(
              response:TransactionResponse(
                cid: '',
                message: result.message
              ),
              messageState:'error')
          );
        }
        dismissAllToast();
      }catch(error){
        isFetch = false;
        emit(state.copyWithTransferState(
            response:TransactionResponse(
                cid: '',
                message: ''
            ),
            messageState:'error')
        );
        dismissAllToast();
      }
    });

    on<ResetSendMessageEvent>((event,emit){
      TransactionResponse res = TransactionResponse(
          cid: '',
          message: ''
      );
      emit(state.copyWithTransferState(response:res,messageState:''));
    });



  }
}
