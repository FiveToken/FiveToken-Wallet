part of 'transfer_bloc.dart';

class TransferState extends Equatable{
  final String to;
  TransferState({this.to});

  @override
  // TODO: implement props
  List<Object> get props => [this.to];

  factory TransferState.idle() {
    return TransferState(
      to: '',
    );
  }
}
