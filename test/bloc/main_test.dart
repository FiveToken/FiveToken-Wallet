import 'package:fil/bloc/connect/connect_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fil/bloc/main/main_bloc.dart';
import 'package:fil/chain/net.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  group('netBloc',(){
    MainBloc mainBloc;
    final filNet = Network.filecoinMainNet;
    final address = 'f17uqrg4ycvx6jrddzcpl7vwoptowp5wr2dzcw33a';

    setUp((){
      mainBloc = MainBloc();
    });


    blocTest(
        'TestNetIsShowEvent',
        build: ()=> mainBloc,
        act: (bloc) => bloc.add(TestNetIsShowEvent(hideTestnet:false)),
        expect: ()=> [false]
    );

    blocTest(
        'GetBalanceEvent',
        build: ()=> mainBloc,
        act: (bloc) => bloc.add(GetBalanceEvent(filNet.rpc,filNet.chain,address)),
        expect: ()=> [false]
    );

    blocTest(
        'ResetBalanceEvent',
        build: ()=> mainBloc,
        act: (bloc) => bloc.add(ResetBalanceEvent()),
        expect: ()=> ['0']
    );


  });
}