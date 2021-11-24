part of 'gas_bloc.dart';

@immutable
class GasEvent {}

class GetGasEvent extends GasEvent {
  final String rpc;
  final String chainType;
  final String to;
  final bool isToken;
  final Token token;
  final String rpcType;
  GetGasEvent(this.rpc,this.chainType,this.to,this.isToken,this.token,this.rpcType);
}

class ResetChainGasEvent extends GasEvent{
  ResetChainGasEvent();
}
