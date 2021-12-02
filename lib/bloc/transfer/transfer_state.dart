part of 'transfer_bloc.dart';

class TransferState extends Equatable{
  final String to;
  final int nonce;
  final String transactionHash;
  final String messageState;
  TransferState({this.to,this.nonce,this.transactionHash,this.messageState});

  @override
  // TODO: implement props
  List<Object> get props => [this.to,this.nonce,this.transactionHash,this.messageState];

  factory TransferState.idle() {
    return TransferState(
      to: '',
      nonce:-1,
      transactionHash:'',
      messageState:'',
    );
  }

  TransferState copyWithTransferState({
    String to,
    int nonce,
    String transactionHash,
    String messageState,
  }) {
    return TransferState(
        to: to ?? this.to,
        nonce: nonce ?? this.nonce,
        transactionHash: transactionHash ?? this.transactionHash,
        messageState: messageState ?? this.messageState,
    );
  }
}
