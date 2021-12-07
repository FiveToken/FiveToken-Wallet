import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/chain/lock.dart';
import 'package:fil/index.dart';
import 'package:fil/init/hive.dart';
import 'package:meta/meta.dart';

part 'lock_event.dart';
part 'lock_state.dart';

class LockBloc extends Bloc<LockEvent, LockState> {
  LockBloc() : super(LockState.idle()) {
    on<LockEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<setLockEvent>((event, emit){
      emit(state.copyWithLockState(event.lock, event.password, event.status));
      var lockBox = OpenedBox.lockInstance;
      LockBox lock = LockBox.fromJson({'lockscreen': event.lock, 'password':event.password, 'status': event.status});
      lockBox.put('lock', lock);

    });
  }
}
