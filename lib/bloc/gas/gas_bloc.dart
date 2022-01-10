import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/bloc/wallet/wallet_bloc.dart';
import 'package:fil/chain/gas.dart';
import 'package:fil/chain/token.dart';
import 'package:fil/config/config.dart';
import 'package:fil/models/gas_response.dart';
import 'package:fil/request/global.dart';
import 'package:fil/utils/enum.dart';
import 'package:fil/widgets/toast.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:meta/meta.dart';
import 'package:fil/store/store.dart';
import 'package:oktoast/oktoast.dart';

part 'gas_event.dart';

part 'gas_state.dart';

class GasBloc extends Bloc<GasEvent, GasState> {
  GasBloc() : super(GasState.idle()) {
    on<ResetGetGasStateEvent>((event, emit) {
      emit(state.copyWithGasState(getGasState: ''));
    });
    on<GetGasEvent>((event, emit) async {
      try {
        showCustomLoading('Loading');
        Chain.setRpcNetwork(event.rpc, event.chainType);
        GasResponse res = await Chain.chainProvider.getGas(
          from: $store.wal.address,
          to: event.to,
          isToken: event.isToken,
          token: event.token,
        );
        dismissAllToast();
        if (res.gasState == "success") {
          String maxPriorityFee = '0';
          String maxFeePerGas = '0';
          String baseFeePerGas = '0';
          String baseMaxPriorityFee = '0';

          if (event.rpcType == RpcType.ethereumMain) {
            baseMaxPriorityFee =
                await Chain.chainProvider.getMaxPriorityFeePerGas();
            maxPriorityFee = getMaxPriorityFee(
                baseMaxPriorityFee, Config.middleMaxPriorityFeePerGas);

            baseFeePerGas = await Chain.chainProvider.getBaseFeePerGas();
            maxFeePerGas = getMaxFeePerGas(baseFeePerGas, maxPriorityFee);
          }
          var _gas = {
            "gasLimit": res.gasLimit,
            "gasPremium": res.gasPremium,
            "gasPrice": res.gasPrice,
            "rpcType": event.rpcType,
            "maxPriorityFee": maxPriorityFee,
            "maxFeePerGas": maxFeePerGas,
            "gasFeeCap": res.gasFeeCap,
            "baseFeePerGas": baseFeePerGas,
            "baseMaxPriorityFee": baseMaxPriorityFee,
          };
          ChainGas gas = ChainGas.fromJson(_gas);
          $store.setGas(gas);
          emit(state.copyWithGasState(getGasState: 'success'));
        } else {
          emit(state.copyWithGasState(
              getGasState: 'error', errorMessage: res.message));
        }
      } catch (error) {
        add(ResetGetGasStateEvent());
        dismissAllToast();
      }
    });

    on<UpdateMessListStateEvent>((event, emit) async {
      List storeMessageList =
          getStoreMsgList(event.symbol).map((e) => e).toList();
      final pendingList =
          storeMessageList.where((mes) => mes.pending == 1).toList();
      if (pendingList.length > 0) {
        if (event.chainType == 'filecoin') {
          Chain.setRpcNetwork(event.rpc, event.chainType);
          List param = [];
          pendingList.forEach((n) async {
            param.add({"from": n.from, "nonce": n.nonce});
          });
          await upDateFileCoinMessageState(
              event.rpc, event.chainType, pendingList, param);
        } else {
          await updateEthMessageListState(
              event.rpc, event.chainType, pendingList);
        }
        List _list = getStoreMsgList(event.symbol).map((e) => e).toList();
        emit(state.copyWithGasState(
            timestamp: DateTime.now().microsecondsSinceEpoch));
      }
    });

    on<UpdateTabsEvent>((event, emit) async {
      emit(state.copyWithGasState(tab: event.tab));
    });

    on<UpdateGasGearEvent>((event, emit) async {
      emit(state.copyWithGasState(gear: event.gear));
    });

    on<UpdateHandlingFeeEvent>((event, emit) async {
      emit(state.copyWithGasState(handlingFee: event.handlingFee));
    });
  }
}

String getMaxPriorityFee(String maxPriority, double times) {
  try {
    var bigNum = (BigInt.parse(maxPriority) *
        BigInt.from(times * 100) /
        BigInt.from(100));
    var _maxInt = bigNum.toInt();
    return _maxInt.toString();
  } catch (error) {
    return '0';
  }
}

String getMaxFeePerGas(String baseFee, String maxPriorityFee) {
  try {
    return (BigInt.parse(baseFee) + BigInt.parse(maxPriorityFee)).toString();
  } catch (error) {
    return '0';
  }
}
