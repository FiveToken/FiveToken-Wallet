import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:fil/chain-new/filecoin.dart';
import 'wallet_state.dart';
part 'wallet_event.dart';

class WalletBloc extends Bloc<BalanceEvent, WalletState> {
  WalletBloc() : super(WalletState.idle()) {
    on<BalanceEvent>(_getBalance);
  }
  _getBalance(BalanceEvent event, Emitter<WalletState> emit) async {
    // this.add(BalanceEvent(event.address,event.addresType));
    switch (event.addressType){
      case 'filecoin':
        Filecoin(event.rpc).getBalance(event.address);
    }
  }
}
