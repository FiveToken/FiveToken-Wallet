import 'package:fil/bloc/transfer/transfer_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fil/chain/gas.dart';
import 'package:fil/chain/net.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  group('netBloc',(){
    TransferBloc transferBloc;


    final filNet = Network.filecoinMainNet;
    final address = 'f1bg6okgypafkakdzqe4vnquiqba5a3aniccs44ca';
    final from = 'f17uqrg4ycvx6jrddzcpl7vwoptowp5wr2dzcw33a';
    final ck = 'KZOH/ULAdznRVkQrd5ACp7HlFdb21f5AHWHaKEEl8oQ=';
    final gas = ChainGas.fromJson({
      "gasLimit":3372508,
      "gasPremium":"119823",
      "gasFeeCap":"120162",
    });

    setUp((){
      transferBloc = TransferBloc();
    });

    blocTest(
        'GetNonceEvent',
        build: ()=> transferBloc,
        act: (bloc) => bloc.add(GetNonceEvent(filNet.rpc,filNet.chain,from)),
        expect: ()=> [
          '12'
        ]
    );


    blocTest(
        'SetMetaEvent',
        build: ()=> transferBloc,
        act: (bloc) => bloc.add(SendTransactionEvent(filNet.rpc,filNet.chain,from,address,'1210000000',ck,12,gas,false,null)),
        expect: ()=> [

        ]
    );

    blocTest(
        'ResetSendMessageEvent',
        build: ()=> transferBloc,
        act: (bloc) => bloc.add(ResetSendMessageEvent()),
        expect: ()=> ['']
    );
  });
}