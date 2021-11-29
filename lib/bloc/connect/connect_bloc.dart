import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/common/walletConnect.dart';

part 'connect_event.dart';
part 'connect_state.dart';

class ConnectBloc extends Bloc<ConnectEvent, ConnectState> {
  ConnectBloc() : super(ConnectState.idle()) {
    on<ConnectEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<SetConnectedSessionEvent>((event,emit){
      emit(state.copyWithConnectState(connectedSession:event.connectedSession));
    });

    on<SetMetaEvent>((event,emit){
      emit(state.copyWithConnectState(meta:event.meta));
    });

  }
}
