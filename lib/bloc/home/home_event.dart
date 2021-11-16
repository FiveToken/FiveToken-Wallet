part of 'home_bloc.dart';

class HomeEvent {
  const HomeEvent();
}

class SetConnectedSessionEvent extends HomeEvent{
  final WCSession connectedSession;
  // final WCMeta meta;
  SetConnectedSessionEvent({ this.connectedSession });
}

class SetMetaEvent extends HomeEvent{
  final WCMeta meta;
  SetMetaEvent({ this.meta });
}

class GetTokenListEvent extends HomeEvent{
  final String mainAddress;
  GetTokenListEvent(this.mainAddress);
}