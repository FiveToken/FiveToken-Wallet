part of 'transfer_bloc.dart';

class TransferState extends Equatable{
  final String to;
  final int nonce;
  final TransactionResponse response;
  final String messageState;
  TransferState({this.to,this.nonce,this.response,this.messageState});

  @override
  // TODO: implement props
  List<Object> get props => [this.to,this.nonce,this.response,this.messageState];

  factory TransferState.idle() {
    return TransferState(
      to: '',
      nonce:-1,
      response:TransactionResponse(
        cid: '',
        message: ''
      ),
      messageState:'',
    );
  }

  TransferState copyWithTransferState({
    String to,
    int nonce,
    TransactionResponse response,
    String messageState,
  }) {
    return TransferState(
        to: to ?? this.to,
        nonce: nonce ?? this.nonce,
        response: response ?? this.response,
        messageState: messageState ?? this.messageState,
    );
  }
}
