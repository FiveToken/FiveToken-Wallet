part of 'connect_bloc.dart';

class ConnectEvent {
  const ConnectEvent();
}

class SetConnectedSessionEvent extends ConnectEvent{
  final WCSession connectedSession;
  SetConnectedSessionEvent({ this.connectedSession });
}

class SetMetaEvent extends ConnectEvent{
  final WCMeta meta;
  SetMetaEvent({ this.meta });
}