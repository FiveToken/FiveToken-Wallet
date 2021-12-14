import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/init/hive.dart';
import 'package:fil/utils/enum.dart';

part 'select_event.dart';
part 'select_state.dart';

class SelectBloc extends Bloc<SelectEvent, SelectState> {
  SelectBloc() : super(SelectState.idle()) {
    on<LabelEvent>((event, emit){
      emit(state.copy(label:event.label));
    });
    on<IdDeleteEvent>((event, emit){
      emit(SelectState.idle());
    });
    on<ImportDeleteEvent>((event, emit) async {
        var box = OpenedBox.walletInstance;
        if(event.wal!=null&&event.wal.key!=null){
          await  box.delete(event.wal.key);
        }
        emit(SelectState.idle());
    });

    on<IdUpdateEvent>((event, emit) async{
      emit(state.copy(importList: state.importList.map((e) => ChainWallet.fromJson(e.toJson())).toList()));
    });

    on<ImportUpdateEvent>((event, emit){
      emit(state.copy(importList: state.importList.map((e) => ChainWallet.fromJson(e.toJson())).toList()));
    });
    on<WalletDeleteEvent>((event, emit){
      var box = OpenedBox.walletInstance;
      List<ChainWallet> list = [];
      if(event.wallet==null){return;}
      if (event.wallet.type != WalletType.privateKey) {
        list = OpenedBox.walletInstance.values
            .where((wal) => wal.groupHash == event.wallet.groupHash)
            .toList();
      } else {
        list = [event.wallet];
      }
      list.forEach((wal) {
        wal.label = event.newLabel;
        box.put(wal.key, wal);
      });
      emit(state.copy(importList:state.importList,label: event.wallet.label));
    });
  }
}
