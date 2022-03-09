
import 'package:bloc_test/bloc_test.dart';
import 'package:fil/bloc/wallet/wallet_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  group('WalletBloc',(){
    WalletBloc walletBloc;

    setUp((){
      walletBloc = WalletBloc();
    });

    blocTest(
        'SetConnectedSessionEvent',
        build: ()=> walletBloc,
        act: (bloc) => bloc.add(ResetMessageListEvent())
    );

  });
}