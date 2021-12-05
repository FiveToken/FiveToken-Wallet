part of 'lock_bloc.dart';


class LockState extends Equatable {
  final bool lock;
  final String password;
  LockState({this.lock, this.password});
  @override
  // TODO: implement props
  List<Object> get props => [this.lock, this.password];

  factory LockState.idle() {
    var box = OpenedBox.lockInstance;
    var lock = box.get('lock');
    bool flag = false;
    if(lock!=null && lock.lockscreen){
      flag = true;
    }
    return LockState(
      lock: flag,
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
