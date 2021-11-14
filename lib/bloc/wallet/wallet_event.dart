part of 'wallet_bloc.dart';

class WalletEvent {
  const WalletEvent();
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
  List storeMessageList;
  UpdateEthMessageListStateEvent(this.rpc,this.chainType,this.storeMessageList);
}

class GetEthTransactionReceiptEvent extends WalletEvent{
  String hash;
  GetEthTransactionReceiptEvent(this.hash);
}

class UpdateFileCoinPendingStateEvent extends WalletEvent{
  String rpc;
  String chainType;
  UpdateFileCoinPendingStateEvent(this.rpc, this.chainType);
}

class GetStoreMessageListEvent extends WalletEvent{
  String rpc;
  String chainType;
  GetStoreMessageListEvent(this.rpc, this.chainType);
}
