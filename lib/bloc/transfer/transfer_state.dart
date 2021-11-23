part of 'transfer_bloc.dart';

class TransferState extends Equatable{
  final String to;
  final int nonce;
  final String transactionHash;
  final String lastMessageState;
  TransferState({this.to,this.nonce,this.transactionHash,this.lastMessageState});

  @override
  // TODO: implement props
  List<Object> get props => [this.to,this.nonce,this.transactionHash,this.lastMessageState];

  factory TransferState.idle() {
    return TransferState(
      to: '',
      nonce:-1,
      transactionHash:'',
      lastMessageState:''
    );
  }

  TransferState copyWithTransferState({
    String to,
    int nonce,
    String transactionHash,
    String lastMessageState,
  }) {
    return TransferState(
        to: to ?? this.to,
        nonce: nonce ?? this.nonce,
        transactionHash: transactionHash ?? this.transactionHash,
        lastMessageState: lastMessageState ?? this.lastMessageState
    );
  }
}
