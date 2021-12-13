part of 'main_bloc.dart';

class MainEvent {
  const MainEvent();
}

class TestNetIsShowEvent extends MainEvent {
  final bool hideTestnet;
  TestNetIsShowEvent({this.hideTestnet});
}

class GetBalanceEvent extends MainEvent {
  String rpc;
  String chainType;
  String address;
  GetBalanceEvent(this.rpc,this.chainType,this.address);
}

class ResetBalanceEvent extends MainEvent{

}