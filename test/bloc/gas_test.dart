import 'package:fil/bloc/gas/gas_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fil/chain/net.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

class MockClient extends Mock implements http.Client {}

void main() {
  group('netBloc',() async {
    GasBloc gasBloc;

    setUp((){
      gasBloc = GasBloc();
    });

    final filNet = Network.filecoinMainNet;
    final to = 'f17uqrg4ycvx6jrddzcpl7vwoptowp5wr2dzcw33a';

    blocTest(
        'ResetGetGasStateEvent',
        build: ()=> gasBloc,
        act: (bloc) => bloc.add(ResetGetGasStateEvent()),
        expect: ()=> [""]
    );

    blocTest(
        'GetGasEvent',
        build: ()=> gasBloc,
        act: (bloc) => bloc.add(GetGasEvent(filNet.rpc,filNet.chain,to,false,null,'filecoin')),
        expect: ()=> ["success"]
    );

    blocTest(
        'UpdateMessListStateEvent',
        build: ()=> gasBloc,
        act: (bloc) => bloc.add(UpdateMessListStateEvent(filNet.rpc,filNet.chain,"FIL")),
        expect: ()=> [DateTime.now().microsecondsSinceEpoch]
    );

  });
}