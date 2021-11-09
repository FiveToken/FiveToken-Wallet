part of 'main_bloc.dart';

class MainEvent {
  const MainEvent();
}

class AppOpenEvent extends MainEvent {
  final int count;
  AppOpenEvent({this.count});
}

class TestNetIsShowEvent extends MainEvent {
  final bool hideTestnet;
  TestNetIsShowEvent({this.hideTestnet});
}