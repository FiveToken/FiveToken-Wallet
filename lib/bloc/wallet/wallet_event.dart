part of 'wallet_bloc.dart';

class WalletEvent {
  const WalletEvent();
}

class GetMessageListEvent extends WalletEvent {
  String rpc;
  String chainType;
  String actor;
  String direction;
  String symbol;
  GetMessageListEvent(this.rpc,this.chainType,this.actor,this.direction,this.symbol);
}

class ResetMessageListEvent extends WalletEvent {
  ResetMessageListEvent();
}

class GetFileCoinMessageListEvent extends WalletEvent {
  String rpc;
  String chainType;
  String actor;
  String direction;
  String symbol;
  GetFileCoinMessageListEvent(this.rpc,this.chainType,this.actor,this.direction,this.symbol);
}

class GetTokenBalanceEvent extends WalletEvent {
  final String rpc;
  final String chainType;
  final String mainAddress;
  final String address;
  GetTokenBalanceEvent(this.rpc,this.chainType,this.mainAddress,this.address);
}

class SetEnablePullUpEvent extends WalletEvent{
  bool enablePullUp;
  SetEnablePullUpEvent(this.enablePullUp);
}



