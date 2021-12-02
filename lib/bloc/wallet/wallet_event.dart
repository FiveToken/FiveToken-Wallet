part of 'wallet_bloc.dart';

class WalletEvent {
  const WalletEvent();
}

class GetMessageListEvent extends WalletEvent {
  String rpc;
  String chainType;
  String actor;
  String direction;
  GetMessageListEvent(this.rpc,this.chainType,this.actor,this.direction);
}

class GetFileCoinMessageListEvent extends WalletEvent {
  String rpc;
  String chainType;
  String actor;
  String direction;
  GetFileCoinMessageListEvent(this.rpc,this.chainType,this.actor,this.direction);
}

class SetEnablePullUpEvent extends WalletEvent{
  bool enablePullUp;
  SetEnablePullUpEvent(this.enablePullUp);
}



