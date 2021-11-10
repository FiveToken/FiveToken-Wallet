import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/common/global.dart';// Global
import 'package:flutter/material.dart';
part 'main_state.dart';
part 'main_event.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(MainState.idle()) {
    on<AppOpenEvent>((event, emit) {
      // TODO: implement event handler
      // debugPrint("================AppOpenEvent=========" + event.count.toString());
    });
    on<TestNetIsShowEvent>((event, emit){
      bool hideTestnet = event.hideTestnet;
      List<List<Network>> nets = !hideTestnet ? [Network.netList[0]] : Network.netList;
      Global.store.setBool('hideTestnet', !hideTestnet);
      emit(state.copyWithMainStateHideTestNet(
          hideTestnet:!hideTestnet,
          filterNets:nets
      ));
    });
  }
}
