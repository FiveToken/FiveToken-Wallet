part of 'lock_bloc.dart';

class LockEvent {
  const LockEvent();
}

class setLockEvent extends LockEvent{
  final bool lock;
  final String password;
  setLockEvent({this.lock, this.password});
}