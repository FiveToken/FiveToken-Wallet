part of 'connect_bloc.dart';

class ConnectEvent {
  const ConnectEvent();
}

class SetConnectedSessionEvent extends ConnectEvent{
  final WCPeerMeta connectedSession;
  SetConnectedSessionEvent({ this.connectedSession });
}

class SetMetaEvent extends ConnectEvent{
  final WCPeerMeta meta;
  SetMetaEvent({ this.meta });
}

class ResetConnectEvent extends ConnectEvent{
  final WCPeerMeta meta;
  final WCPeerMeta connectedSession;
  ResetConnectEvent({ this.meta,this.connectedSession });
}