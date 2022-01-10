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

class ResetGetGasStateEvent extends GasEvent{
  ResetGetGasStateEvent();
}

class UpdateMessListStateEvent extends GasEvent{
  final String rpc;
  final String chainType;
  final String symbol;
  UpdateMessListStateEvent(this.rpc,this.chainType,this.symbol);
}

class UpdateTabsEvent extends GasEvent{
  final String tab;
  UpdateTabsEvent(this.tab);
}

class UpdateGasGearEvent extends GasEvent{
  final String gear;
  UpdateGasGearEvent(this.gear);
}

class UpdateHandlingFeeEvent extends GasEvent{
  final String handlingFee;
  UpdateHandlingFeeEvent(this.handlingFee);
}

