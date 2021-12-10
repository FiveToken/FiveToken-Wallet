import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/request/global.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/common/global.dart';// Global
import 'package:fil/store/store.dart'; // $store
import 'package:fil/init/hive.dart'; // OpenedBox
part 'main_state.dart';
part 'main_event.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(MainState.idle()) {
    on<AppOpenEvent>((event, emit) {
      // debugPrint("================AppOpenEvent=========" + event.count.toString());
    });

    on<TestNetIsShowEvent>((event, emit){
      if(event.hideTestnet==null){return;}
      bool hideTestnet = event.hideTestnet;
      List<List<Network>> nets = !hideTestnet ? [Network.netList[0]] : Network.netList;
      Global.store.setBool('hideTestnet', !hideTestnet);
      emit(state.copyWithMainStateHideTestNet(
          hideTestnet:!hideTestnet,
          filterNets:nets
      ));
    });

    on<GetBalanceEvent>((event, emit) async{
      add(ResetBalanceEvent());
      Chain.setRpcNetwork(event.rpc,event.chainType);
      final balance = await Chain.chainProvider.getBalance(event.address);
      var wal = $store.wal;
      if (balance != wal.balance) {
          $store.changeWalletBalance(balance);
          wal.balance = balance;
          OpenedBox.walletInstance.put(wal.key, wal);
      }
      emit(state.copyWithMainState(balance: balance));
    });

    on<ResetBalanceEvent>((event,emit){
      emit(state.copyWithMainState(balance: '0'));
    });
  }
}
