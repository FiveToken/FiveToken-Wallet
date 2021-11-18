part of 'pass_bloc.dart';

class PassEvent {
  const PassEvent();
}

class SetPassEvent extends PassEvent {
  final bool passShow;
  SetPassEvent({this.passShow});
}
