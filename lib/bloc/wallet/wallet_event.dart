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

class UpdateEthMessageListStateEvent extends WalletEvent{
  String rpc;
  String chainType;
  UpdateEthMessageListStateEvent(this.rpc,this.chainType);
}

class GetEthTransactionReceiptEvent extends WalletEvent{
  String hash;
  GetEthTransactionReceiptEvent(this.hash);
}

class UpdateFileCoinPendingStateEvent extends WalletEvent{
  String rpc;
  String chainType;
  String actor;
  String direction;
  UpdateFileCoinPendingStateEvent(this.rpc, this.chainType,this.actor,this.direction);
}

class GetStoreMessageListEvent extends WalletEvent{
  String rpc;
  String chainType;
  GetStoreMessageListEvent(this.rpc, this.chainType);
}

class SetEnablePullUpEvent extends WalletEvent{
  bool enablePullUp;
  SetEnablePullUpEvent(this.enablePullUp);
}



