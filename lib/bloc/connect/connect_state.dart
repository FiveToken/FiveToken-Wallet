part of 'connect_bloc.dart';

class ConnectState extends Equatable {
  final WCSession connectedSession;
  final WCMeta meta;

  @override
  List<Object> get props => [this.connectedSession,this.meta];

  ConnectState({
    this.connectedSession,
    this.meta,
  });

  factory ConnectState.idle() {
    return ConnectState(
      connectedSession:null,
      meta:null
    );
  }

  ConnectState copyWithConnectState({
    WCSession connectedSession,
    WCMeta meta
  }) {
    return ConnectState(
        connectedSession: connectedSession ?? this.connectedSession,
        meta: meta ?? this.meta,
    );
  }

  ConnectState resetConnectState({
    WCSession connectedSession,
    WCMeta meta
  }){
    return ConnectState(
      connectedSession: connectedSession ,
      meta: meta,
    );
  }


}
