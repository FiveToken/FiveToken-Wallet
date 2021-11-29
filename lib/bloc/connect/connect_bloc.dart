import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/common/walletConnect.dart';

part 'connect_event.dart';
part 'connect_state.dart';

class ConnectBloc extends Bloc<ConnectEvent, ConnectState> {
  ConnectBloc() : super(ConnectState.idle()) {

    on<SetConnectedSessionEvent>((event,emit){
      print("+================");
      try {
        emit(state.copyWithConnectState(connectedSession:event.connectedSession));
      }
      catch (e){
        print(e);
      }
    });

    on<SetMetaEvent>((event,emit){
      emit(state.copyWithConnectState(meta:event.meta));
    });

  }
}
