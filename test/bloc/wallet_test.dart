import 'package:bloc_test/bloc_test.dart';
import 'package:fil/bloc/wallet/wallet_bloc.dart';
import 'package:fil/chain/net.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  group('WalletBloc',(){
    WalletBloc walletBloc;
    final filNet = Network.filecoinMainNet;
    final address = 'f17uqrg4ycvx6jrddzcpl7vwoptowp5wr2dzcw33a';
    final binanceTestnet = Network.binanceTestnet;
    final ethAddress = '0x3FB4F280cF531Ba7d88Fe4D0748A451E4D4276AD';
    final contractAddress = '0x9343bc852c04690b239ec733c6f71d8816d436c3';

    setUp((){
      walletBloc = WalletBloc();
    });


    blocTest(
        'GetMessageListEvent',
        build: ()=> walletBloc,
        act: (bloc) => bloc.add(GetMessageListEvent(filNet.rpc,filNet.chain,address,'up',"FIL")),
        expect: ()=> [true]
    );

    blocTest(
        'GetFileCoinMessageListEvent',
        build: ()=> walletBloc,
        act: (bloc) => bloc.add(GetFileCoinMessageListEvent(filNet.rpc,filNet.chain,address,'up',"FIL")),
        expect: ()=> [true]
    );


    blocTest(
        'GetTokenBalanceEvent',
        build: ()=> walletBloc,
        act: (bloc) => bloc.add(GetTokenBalanceEvent(binanceTestnet.rpc,binanceTestnet.chain,ethAddress,contractAddress)),
        expect: ()=> [

        ]
    );


    blocTest(
        'ResetMessageListEvent',
        build: ()=> walletBloc,
        act: (bloc) => bloc.add(ResetMessageListEvent()),
        expect: ()=> [true]
    );


    blocTest(
        'SetEnablePullUpEvent',
        build: ()=> walletBloc,
        act: (bloc) => bloc.add(SetEnablePullUpEvent(true)),
        expect: ()=> [true]
    );

  });
}