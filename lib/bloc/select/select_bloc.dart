import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/chain/net.dart';
import 'package:fil/chain/wallet.dart';
import 'package:fil/index.dart';
import 'package:fil/init/hive.dart';
import 'package:meta/meta.dart';

part 'select_event.dart';
part 'select_state.dart';

class SelectBloc extends Bloc<SelectEvent, SelectState> {
  SelectBloc() : super(SelectState.idle()) {
    on<IdDeleteEvent>((event, emit){
      var box = OpenedBox.walletInstance;
      var keys = box.values
          .where((wal) => wal.groupHash == event.hash && wal.type == 0)
          .map((wal) => wal.key);
      box.deleteAll(keys);
      emit(SelectState.idle());
    });
    on<ImportDeleteEvent>((event, emit) async {
        var box = OpenedBox.walletInstance;
        if(event.wal!=null&&event.wal.key!=null){
          await  box.delete(event.wal.key);
        }
        emit(SelectState.idle());
    });

    on<WalletDeleteEvent>((event, emit){
      var box = OpenedBox.walletInstance;
      List<ChainWallet> list = [];
      if (event.wallet.type != 2) {
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
    });

  }
}
