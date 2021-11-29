part of 'connect_bloc.dart';

class ConnectState extends Equatable {
  final WCSession connectedSession;
  final WCMeta meta;

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

  @override
  List<Object> get props => [this.connectedSession,this.meta];

  ConnectState copyWithConnectState({
    WCSession connectedSession,
    WCMeta meta
  }) {
    return ConnectState(
        connectedSession: connectedSession ?? this.connectedSession,
        meta: meta ?? this.meta,
    );
  }



}

