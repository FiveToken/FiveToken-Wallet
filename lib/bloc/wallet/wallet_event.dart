part of 'wallet_bloc.dart';

class WalletEvent {
  const WalletEvent();
}

class BalanceEvent extends WalletEvent {
  String rpc;
  String address;
  String addressType;
  BalanceEvent(this.rpc,this.address,this.addressType);
}