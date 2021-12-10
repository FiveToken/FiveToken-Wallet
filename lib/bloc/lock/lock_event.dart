part of 'lock_bloc.dart';

class LockEvent {
  const LockEvent();
}

class SetLockEvent extends LockEvent{
  final bool lock;
  final String password;
  final String status;
  SetLockEvent({this.lock, this.password, this.status});
}