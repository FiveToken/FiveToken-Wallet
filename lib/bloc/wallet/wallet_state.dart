
// part of'wallet_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fil/models-new/token.dart';

class WalletState extends Equatable {
  String accountName;
  Token token;

  WalletState({this.accountName,this.token});

  factory WalletState.idle() {
    return WalletState(
      accountName: '',
      token: null,
    );
  }

  get fmtBalance {
    switch (token.tokenType) {
      case 'filecoin':
          return '0';
          break;
      default:
        return '0';
        break;
    }
  }

  @override
  // TODO: implement props
  List<Object> get props => [this.accountName,this.token];

}

// class WalletInitial extends WalletState {
//
//   @override
//   List<Object> get props => [];
// }
