import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:wallet_connect/models/wc_peer_meta.dart';

part 'connect_event.dart';
part 'connect_state.dart';

class ConnectBloc extends Bloc<ConnectEvent, ConnectState> {
  ConnectBloc() : super(ConnectState.idle()) {

    on<SetConnectedSessionEvent>((event,emit){
      emit(state.copyWithConnectState(connectedSession:event.connectedSession));
    });

    on<SetMetaEvent>((event,emit){
      emit(state.copyWithConnectState(meta:event.meta));
    });

    on<ResetConnectEvent>((event,emit){
      emit(state.resetConnectState( meta:null, connectedSession:null ));
    });

  }
}
