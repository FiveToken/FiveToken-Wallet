part of 'select_bloc.dart';

class SelectEvent {
  const SelectEvent();
}

class LabelEvent extends SelectEvent{
   final String label;
   LabelEvent(this.label);
}

class IdDeleteEvent extends SelectEvent{
   final String hash;
   IdDeleteEvent({this.hash});
}

class ImportDeleteEvent extends SelectEvent{
   final ChainWallet wal;
   final Network net;
   ImportDeleteEvent({this.wal, this.net});
}

class WalletDeleteEvent extends SelectEvent{
   final ChainWallet wallet;
   final String newLabel;
   WalletDeleteEvent({this.wallet, this.newLabel});
}