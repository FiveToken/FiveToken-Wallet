part of 'reset_bloc.dart';

@immutable
class ResetEvent {
  const ResetEvent();
}

class SetResetEvent extends ResetEvent{
  final ChainWallet wallet;
  final String password;
  final String newPassword;
  SetResetEvent({this.wallet, this.password, this.newPassword});
}
