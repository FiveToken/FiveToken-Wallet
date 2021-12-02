part of 'lock_bloc.dart';


class LockState extends Equatable {
  final bool lock;
  final String password;
  LockState({this.lock, this.password});
  @override
  // TODO: implement props
  List<Object> get props => [this.lock, this.password];

  factory LockState.idle() {
    return LockState(
      lock: false,
      password: ''
    );
  }
  LockState copyWithLockState(
    bool lock,
    String password,
  ){
    return LockState(
      lock: lock ?? this.lock,
      password: password ?? this.password
    );
  }

}
