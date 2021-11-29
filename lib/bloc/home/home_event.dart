part of 'home_bloc.dart';

class HomeEvent {
  const HomeEvent();
}

class GetTokenListEvent extends HomeEvent{
  final String rpc;
  final String chainType;
  final String mainAddress;
  GetTokenListEvent(this.rpc,this.chainType,this.mainAddress);
}