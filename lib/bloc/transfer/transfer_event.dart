part of 'transfer_bloc.dart';

@immutable
class TransferEvent {
  const TransferEvent();
}

class GetNonceEvent extends TransferEvent{
  final String rpc;
  final String chainType;
  final String address;
  GetNonceEvent(this.rpc,this.chainType,this.address);
}

class SendTransactionEvent extends TransferEvent{
  final String rpc;
  final String chainType;
  final String from;
  final String to;
  final String amount;
  final String privateKey;
  final int nonce;
  final ChainGas gas;
  final bool isToken;
  final Token token;
  SendTransactionEvent(
      this.rpc,
      this.chainType,
      this.from,
      this.to,
      this.amount,
      this.privateKey,
      this.nonce,
      this.gas,
      this.isToken,
      this.token
  );
}

class ResetSendMessageEvent extends TransferEvent{
  ResetSendMessageEvent();
}

