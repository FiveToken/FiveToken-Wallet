part of 'lock_bloc.dart';


class LockState extends Equatable {
  final bool lock;
  final String password;
  final String status;
  LockState({this.lock, this.password, this.status});
  @override
  // TODO: implement props
  List<Object> get props => [this.lock, this.password, this.status];

  factory LockState.idle() {
    var box = OpenedBox.lockInstance;
    var lock = box.get('lock');
    bool flag = false;
    if(lock!=null && lock.lockscreen==true){
      flag = true;
    }
    return LockState(
      lock: flag,
      password: '',
      status: 'create'
    );
  }
  LockState copyWithLockState(
    bool lock,
    String password,
    String status
  ){
    return LockState(
      lock: lock ?? this.lock,
      password: password ?? this.password,
      status: status?? this.status
    );
  }

}