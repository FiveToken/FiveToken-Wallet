part of 'main_bloc.dart';

class MainEvent {
  const MainEvent();
}

class AppOpenEvent extends MainEvent {
  final int count;
  AppOpenEvent({this.count});
}